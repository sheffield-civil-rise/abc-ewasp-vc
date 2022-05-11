%% verify_solar_angles - verification of the solar_angles function
%% Function Call
%  [v, s] = verify_solar_angles(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%  save_sim_ref - optional flag to save new simulation reference
%         false : do not save a new reference simulation scenario
%         true  : save a new reference simulation scenario
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  Verification of the solar_angles m-function in the Carnot Toolbox
%  by comparing the results to the initial simulation, the incidence angle
%  of equations from [Duffie 2006] and the longitudinal and transversal
%  incidence angle from [ISO 9806:2017]. The solar position is calculated
%  by the carlib functions. 
%  The verification is done for the 23nd of march. The angles are compared 
%  for every full hour of the day.                                                             
%  Literature: 
%   Duffie, Beckman: Solar Engineering of Thermal Processes, ed. 1988 and 2006         
%   https://en.wikipedia.org/wiki/Solar_azimuth_angle (access 26jan2020)
%  see also verification_carnot, verify_sunangles

function [v, s] = verify_solar_angles(varargin)
%% Calculations
% check input arguments
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
    error('verify_solar_angles:%s',' too many input arguments')
end

%% set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.25;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

%% set model file or function name ------------------------------
functionname = 'solar_angles';

%  function parameters
Deg2Rad = pi/180;
Rad2Deg = 180/pi;
lat = 45;                       % reference input values for latitude
lst = 0;                        % reference meridian
local = 0;                      % local meridian
nsec = date2sec([7 23 0 0 0]);  % calculate for 23nd of July
standardtime = (0:24)';         % calculate 1 day
t0 =  standardtime*3600+nsec; 
t0(end) = t0(end)-1;            % stay on the same day, calculate till 23:59:59
nday = t0/24/3600;       

%%  set literature reference values
%  Equations from Duffie  1988
latirad = lat*Deg2Rad;
b = ((nday-81)*360/364)*Deg2Rad;
E = (9.87*sin(2*b)-7.53*cos(b)-1.5*sin(b))/60;
solartime = standardtime+E+(lst-local)/15;
decl = 23.45*sin((360*(nday+284)/365)*Deg2Rad); % solar declination angle in °
delrad = decl*Deg2Rad;
wdegree = (solartime-12)*15;                    % solar hour angle
idx = logical(wdegree < -180);
wdegree(idx) = wdegree(idx)+360;                % avoid angles below -180
idx = logical(wdegree > 180);
wdegree(idx) = wdegree(idx)-360;                % avoid angles above 180
wrad = wdegree*Deg2Rad;
zencos = sin(delrad).*sin(latirad) + cos(delrad).*cos(latirad).*cos(wrad);
zenrad = acos(zencos);
zenith = zenrad*Rad2Deg;
elevation = 90-zenith;
% equation from https://en.wikipedia.org/wiki/Solar_azimuth_angle
azirad = sign(wrad).*acos((sin(latirad).*zencos - sin(delrad))./ ...
    (cos(latirad).*sin(zenrad)));
azimuth = azirad*Rad2Deg;
y0 = [decl, elevation, zenith, azimuth, wdegree];

%%  call the function
[dec,elev,zen,azi,hh] = solar_angles(t0,lat,lst,local);
y2 = [dec,elev,zen,azi,hh];                             % store current resuls in y2

%%  set reference values of the initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_solar_angles.mat','y1');
else
    y1 = importdata('simRef_solar_angles.mat'); % result from call at creation of function
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
    sx = 'time in h';                       % x-axis label
    st = 'm-Function verification';         % title
    sy1 = 'angles in degree';               % y-axis label in the upper plot
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
    x(:) = t0/3600;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1, ye2, ye3]; 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
end

%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% Copyright (c) 1998-2021, Solar-Institute Juelich of the FH Aachen.
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
% 7.1.0     hf      created                                     26jan2020
% 7.1.1     hf      corrected help and comments                 20jul2021
% 7.2.0     hf      limiting hour angle to -pi..pi              21jul2021
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
