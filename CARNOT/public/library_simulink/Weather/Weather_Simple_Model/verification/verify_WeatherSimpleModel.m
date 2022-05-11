%% verify_WeatherSimpleModel - verification of the Weather_Simple_Model block in Carnot
%% Function Call
%  [v, s] = verify_WeatherSimpleModel(varargin)
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
%  verification of the Weather_Simple_Model block in the Carnot Toolbox by
%  comparing the simulation resuls with the initial simulation.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_WeatherSimpleModel(varargin)
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
    error('verify_WeatherSimpleModel:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'WeatherSimpleModel';
modelfile = 'verify_WeatherSimpleModel_mdl';

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(modelfile)
simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
y2 = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
u0 = simOut.get('tout')/3600; % get the whole time vector from simu
close_system(modelfile, 0)   % close system, but do not save it

% data columns in weather data bus, description from file "wdb_format.m"
%  1        time in s, this data is not copied to y2
%  2        timevalue (comment line) format YYYYMMDDHHMM; Y is the year, M the month, D the day, H the hour
%  3        zenith angle of sun (at time, not averaged)         degree       (continue at night to get time of sunrise by   linear interpolation)
%  4        azimuth angle of sun (0°=south, east negative)      degree      (at time, not average in timestep)
%  5        direct beam solar radiation on a normal surface     W/m^2
%  6        diffuse solar radiation on a horizontal surface     W/m^2
%  7        ambient temperature                                 degree Celsius
%  8        radiation temperature of sky                        degree Celsius
%  9        relative humidity                                   percent
% 10        precipitation                                       m/s
% 11        cloud index (0=no cloud, 1=covered sky)             -
% 12        station pressure                                    Pa
% 13        mean wind speed                                     m/s
% 14        wind direction (north=0° west=270°)                 degree
% 15        incidence angle on surface (0° = vertical)          degree
% 16        incidence angle in a vertical plane on the collecor degree  orientation of the plane is parallel to the risers,   referred as longitudinal plane in EN 12975
% 17        incidence angle in a vertical plane on the collecor degree   orientation of the plane is parallel to the headers, referred as transversal plane in EN 12975%           (= -9999, if surface orientation is unknown)
% 18        direct solar radiation on surface                   W/m^2
% 19        diffuse solar radiation on surface                  W/m^2

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_WeatherSimpleMod.mat','y1');
else
    y1 = importdata('simRef_WeatherSimpleMod.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = y1;
disp('verify_WeatherSimpleModel.m: using simulation data as reference data')


%% -------- calculate the errors -------------------------------------------
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
    s = sprintf('verification %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Time in h';                         % x-axis label
    st = 'Simulink block verification';   % title
    sy1 = 'Outputs';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    %   x - vector with x values for the plot
    x = reshape(u0,length(u0),1);
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};

    %  7        ambient temperature                                 degree Celsius
    %  8        radiation temperature of sky                        degree Celsius
    %  9        relative humidity                                   percent
    % 10        precipitation                                       m/s
    % 11        cloud index (0=no cloud, 1=covered sky)             -
    % 13        mean wind speed                                     m/s
    % 14        wind direction (north=0° west=270°)                 degree
    co = [7:11 13, 14]-1;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,co), y1(:,co), y2(:,co)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,co), ye2(:,co), ye3(:,co)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)

    %  3        zenith angle of sun (at time, not averaged)         degree       (continue at night to get time of sunrise by   linear interpolation)
    %  4        azimuth angle of sun (0°=south, east negative)      degree      (at time, not average in timestep)
    % 15        incidence angle on surface (0° = vertical)          degree
    % 16        incidence angle in a vertical plane on the collecor degree  orientation of the plane is parallel to the risers,   referred as longitudinal plane in EN 12975
    % 17        incidence angle in a vertical plane on the collecor degree   orientation of the plane is parallel to the headers, referred as transversal plane in EN 12975%           (= -9999, if surface orientation is unknown)
    co = [3, 4, 15:17]-1;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,co), y1(:,co), y2(:,co)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,co), ye2(:,co), ye3(:,co)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)

    %  5        direct beam solar radiation on a normal surface     W/m^2
    %  6        diffuse solar radiation on a horizontal surface     W/m^2
    % 18        direct solar radiation on surface                   W/m^2
    % 19        diffuse solar radiation on surface                  W/m^2
    co = [5, 6, 18, 19]-1;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,co), y1(:,co), y2(:,co)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,co), ye2(:,co), ye3(:,co)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
    
    %  2        timevalue (comment line) format YYYYMMDDHHMM; Y is the year, M the month, D the day, H the hour
    % 12        station pressure                                    Pa
    co = [2, 12]-1;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,co), y1(:,co), y2(:,co)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,co), ye2(:,co), ye3(:,co)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2019, Solar-Institute Juelich of the FH Aachen.
%  Additional Copyright for this file see list auf authors.
%  All rights reserved.
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are 
%  met:
%  1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
%  2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%  3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
%  THE POSSIBILITY OF SUCH DAMAGE.
%  
%  ************************************************************************
%  VERSIONS
%  $Revision$
%  $Author$
%  $Date$
%  $HeadURL$
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     29aug2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    hf      filename validate_ replaced by verify_      09jan2015
%  6.2.2    hf      close system without saving it              16may2016
%  6.1.1    hf      comments adapted to publish function        09nov2017
%                   reference y1 does not overwrite y2
%  7.1.0    hf      new reference with 24 h calculation         17apr2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
