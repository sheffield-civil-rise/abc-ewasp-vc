function [v, s] = verify_dwd2wdb(varargin)
% verify_dwd2wdb: validation of the conversion of DWWD try 2016 format
%% Description
% [v, s] = verify_dwd2wdb([show], [save_sim_ref])
% Validation of the correct conversion of a DWD test reference year (TRY) 
% 2016 format to Carnot WDB format.
% Inputs:   show - optional flag for display 
%               false : show results only if verification fails
%               true  : show results allways
%           save_sim_ref
%               false : do not save a new reference simulation scenario
%               true  : save a new reference simulation scenario
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   --
% see also dwd2wdb, try2wdb

%% check input arguments ----------------------------------------------
if nargin == 0
    show = false;
    save_sim_ref = false;
elseif nargin == 1
    show = logical(varargin{1});
    save_sim_ref = false;
elseif nargin == 2
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
else
    error('verify_dwd2wdb:%s',' too many input arguments')
end

%% set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

%% set model file or function name ------------------------------
functionname = 'dwd2wdb';

%%  simulate the model or call the function
infile = 'TRY2015_523938130651_Jahr.dat';
outfile = 'tempfile.dat';                   % file will be deleted after verification
lat = 52.393800;                            % latitude of Potsdam (see infile)
long = -13.065100;                          % longitude of Potsdam (see infile)
long0 = -15;
station = 'Potsdam';
country = 'Germany';
comment = 'Data converted from Test Reference Year. DWD local TRY 2016';
y2 = dwd2wdb(infile, outfile,  lat, long, long0, station, country, comment);

%% set the literature reference values -------------------
%  1    RW Rechtswert                                                    [m]       {3670500;3671500..4389500}
%  2    HW Hochwert                                                      [m]       {2242500;2243500..3179500}
%  3    MM Monat                                                                   {1..12}
%  4    DD Tag                                                                     {1..28,30,31}
%  5    HH Stunde (MEZ)                                                            {1..24}
%  6    t  Lufttemperatur in 2m Hoehe ueber Grund                        [GradC]
%  7    p  Luftdruck in Standorthoehe                                    [hPa]
%  8    WR Windrichtung in 10 m Hoehe ueber Grund                        [Grad]    {0..360;999}
%  9    WG Windgeschwindigkeit in 10 m Hoehe ueber Grund                 [m/s]
% 10    N  Bedeckungsgrad                                                [Achtel]  {0..8;9}
% 11    x  Wasserdampfgehalt, Mischungsverhaeltnis                       [g/kg]
% 12    RF Relative Feuchte in 2 m Hoehe ueber Grund                     [Prozent] {1..100}
% 13    B  Direkte Sonnenbestrahlungsstaerke (horiz. Ebene)              [W/m^2]   abwaerts gerichtet: positiv
% 14    D  Diffuse Sonnenbetrahlungsstaerke (horiz. Ebene)               [W/m^2]   abwaerts gerichtet: positiv
% 15    A  Bestrahlungsstaerke d. atm. Waermestrahlung (horiz. Ebene)    [W/m^2]   abwaerts gerichtet: positiv
% 16    E  Bestrahlungsstaerke d. terr. Waermestrahlung                  [W/m^2]   aufwaerts gerichtet: negativ
% 17    IL Qualitaetsbit bezueglich der Auswahlkriterien                           {0;1;2;3;4}
inmat = txt2mat(infile);            % read infile
% time information in dwd try is the average of the last hour
t0 = (0.5:1:8759.5)*3600;           % time vector
% solar postion from carlib since TRY have no sun information
[~,~,zenith,azimuth,~] = sunangles(t0,lat,long,long0);
fb = max(cos(pi/180*zenith),0.001); % factor for normal beam radiation is cos
y0 = zeros(size(inmat,1),19);
y0(:,1) = t0;                       % time in s
y0(:,3) = zenith;                   % zenith from carlib calculation
y0(:,4) = azimuth;                  % azimuth from carlib calculation
y0(:,5) = min(1350,inmat(:,13)./fb);% I_dir_norm: 13 B  Direkte Sonnenbestrahlungsstaerke (horiz. Ebene) [W/m^2] abwaerts gerichtet: positiv
y0(:,6) = inmat(:,14); 				% I_dfu_hor:  14 D  Diffuse Sonnenbetrahlungsstaerke (horiz. Ebene)  [W/m^2] abwaerts gerichtet: positiv
y0(:,7) = inmat(:,6);				% Tamb:        6 t  Lufttemperatur in 2m Hoehe ueber Grund    [GradC]
y0(:,8) = skytemperature(y0(:,7),inmat(:,12),inmat(:,10)/8); % skytemperature(Tamb,hum,cloud)
y0(:,9) = inmat(:,12);				% rel.humid.: 12 RF Relative Feuchte in 2 m Hoehe ueber Grund [Prozent] {1..100}
y0(:,10) = -9999;               	% precipitation is not known
y0(:,11) = min(1, inmat(:,10)/8);	% cloud idx:  10 N  Bedeckungsgrad [Achtel]  {0..8;9}
y0(:,12) = inmat(:,7)*100;		    % pressure:    7 p  Luftdruck in Standorthoehe [hPa]
y0(:,13) = inmat(:,9);			    % wind speed:  9 WG Windgeschwindigkeit in 10 m Hoehe ueber Grund [m/s]
y0(:,14) = inmat(:,8);			    % wind dir.:   8 WR Windrichtung in 10 m Hoehe ueber Grund [Grad] {0..360;999}
y0(:,15) = zenith;					% collector incidence is zenith angle
y0(:,16) = -9999;					% teta rise is not known
y0(:,17) = -9999;					% teta head is not known
y0(:,18) = inmat(:,13);             % Idir on horizontal surface 
y0(:,19) = inmat(:,14);             % Idfu on surface
% duplicate first and last row to be conform with length of TRY
y0 = [y0(1,:); y0; y0(end,:)];   
y0(1,1) = 0;                        % start is 0 s
y0(end,1) = 3600*8760;              % end is 8760*3600 s
y0(:,2) = tvalue(y0(:,1),2016);     % now the time column is correct, set time comment

%% set reference values initial simulation ---------------
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_dwd2wdb.mat','y1');
else
    y1 = importdata('simRef_dwd2wdb.mat');  % result from call at creation of function
end

%% calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
% r = 'relative'; 
s = 'max';
% s = 'sum';
% s = 'mean';

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.5f > allowed error %3.5f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.5f > allowed error %3.5f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.5f', functionname, e2);
end

%% diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'hour';                            % x-axis label
    st = 'verification of dwd2wdb.m';       % title
    sy1 = 'data';                           % y-axis label in the upper plot
    if strcmp(r,'relative')                 % y-axis label in the lower plot
        sy2 = 'relative error';         
    elseif strcmp(r,'absolute')
        sy2 = 'absolute error';
    else
        sy2 = 'Difference';
    end
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = y0(:,1)/3600;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1, ye2, ye3]; 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
else
    close gcf
    close gcf    % close the last two figures, they were created by dwd2wdb function
end

delete tempfile.dat     % delete temporary file

%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% 
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 7.1.0     hf      created                                     31dec2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
