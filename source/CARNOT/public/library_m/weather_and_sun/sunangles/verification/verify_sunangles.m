%% verify_sunangles - verification of the sunangles function in Carnot
%% Function Call
%  [v, s] = verify_sunangles(varargin)
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
%  Verification of the sunangles function in Carnot by comparing the
%  results to Meteonorm calculations for the location Potsdam. The
%  calculation is done for a timestep of 1 h over one year.
%                                                                          
%  Literature:   Meteonorm Version 7.0
%  see also template_verify_mFunction, template_verify_SimulinkBlock,
%  verification_carnot, Meteonorm2wformat

function [v, s] = verify_sunangles(varargin)
% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
    save_sim_ref = false;
elseif nargin == 1
    show = varargin{1};
    save_sim_ref = false;
elseif nargin == 2
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
else
    error('verify_sunangles:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.8;            % max error between simulation and reference
max_simu_error = eps(1e4);  % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'sunangles';

%% ----------------- set the literature reference values -------------------
Potsdam = importdata('Potsdam.mat');
% station name:  Potsdam   country: Germany
% geographical positon: longitude: 52.400000 , latitude: -13.100000
% reference meridian for time (example: 0� = Greenwich Mean Time): -13.100000
% Data from Meteonorm 7.0
% col   description                                       units
% 1     time                                                h
% 2     zenith angle of sun (at time, not averaged)         degree
%       (continue at night to get time of sunrise by
%       linear interpolation)
% 3     azimuth angle of sun (0�=south, east negative)      degree
%       (at time, not average in timestep)
y0 = Potsdam(:,2:3);
time = Potsdam(:,1)*3600-1800;     % time in s at the middle of timestep
latitude = 52.4;
longitude = -13.10;
longitude_timezone = -15;


%%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
% [Declination Altitude Zenith Azimut HourAngle] = sunangles(...)
[~ , Altitude, ~, Azimut, ~] = ...
    sunangles(time, latitude, longitude, longitude_timezone);
y2 = [max(0, Altitude), Azimut];

%% ----------------- set reference values initial simulation ---------------
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_SunAngles.mat','y1');
else
    y1 = importdata('simRef_SunAngles.mat');  % result from call at creation of function
end

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
    sx = 'time in h';                        % x-axis label
    sy1 = 'angles in �';                     % y-axis label in the upper plot
    sy2 = 'Difference in �';                 % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference','initial simu','current simu'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};

    st = 'verification of solar altitude angle';   % title
    %   y - matrix with solar altitude (reference values and result of the function call)
    y = [y0(:,1), y1(:,1), y2(:,1)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    display_verification_error(time/3600, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)

    st = 'verification of solar azimut angle';   % title
    %   y - matrix with solar altitude (reference values and result of the function call)
    y = [y0(:,2), y1(:,2), y2(:,2)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,2), ye2(:,2), ye3(:,2)]; 
    display_verification_error(time/3600, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
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
%  $Revision: 372 $
%  $Author: carnot-wohlfeil $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/sunangles/verification/verify_sunangles.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     19sep2015
%  6.2.0    hf      added save_sim_ref as 2nd input argument    10oct2017
%  6.2.1    hf      comments adapted to publish function        01nov2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *