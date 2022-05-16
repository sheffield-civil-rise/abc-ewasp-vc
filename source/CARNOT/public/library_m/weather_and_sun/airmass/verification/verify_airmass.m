%% function to validate the function 'airmass'
%% Function Call
%  [v, s] = verify_airmass(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%  save_sim_ref
%         false : do not save a new reference simulation scenario
%         true  : save a new reference simulation scenario
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  validate the function 'airmass'
%                                                                          
% Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006
%  see also template_verify_mFunction, verification_carnot

function [v, s] = verify_airmass(varargin)
%% Calculations
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
    error('verify_airmass:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.07;      % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functin name -------------------------------
% initial values and constants
t = 3600*(12+24*(1:30:365));        % legal time is noon at different days
u0 = t/24/3600;                     % input for plots
latitude = 50;
longitude = 0;
longitude0 = 0;
functionname = 'airmass';

% ----------------- set the literature reference values -------------------
n = t./(24*3600);
del=23.45*sin((360*(n+284)/365)*pi/180);
delrad=del*pi/180;
wdegree = time2hourangle(t);
wrad=wdegree*(pi/180);
zenith=(180/pi)*acos(sin(delrad).*sin(latitude*pi/180) + ...
    cos(delrad).*cos(latitude*pi/180).*cos(wrad));
y0 = 1./(cos(zenith*pi/180));

idx70 = logical(zenith >= 70.0);
if sum(idx70) > 0   % at least one index not zero
    a = 90-zenith(idx70);
    a = 614*sin(a*pi/180);
    y0(idx70) = sqrt(1229+a.^2) - a;
end

y0=y0';

%% simulate the model or call the function
y2 = airmass(t, latitude, longitude, longitude0);    % simu

%% set reference values initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_templateVerifySimulink.mat','y1');
else
    y1 = importdata('simRef_templateVerifySimulink.mat');  % result from call at creation of function
end

% ------------- decide if verification is ok --------------------------------
% -------- calculate the errors -------------------------------------------
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
    s = sprintf('verification %s with reference FAILED: error %3.5f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.5f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: absolute error %3.5f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error', num2str(e1)])
    sx = 'Day';
    sy1 = 'Airmass';
    sy2 = 'Difference';
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, functionname, sx, sy1, sleg1, sy2, sleg2, s)
    % display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, stxt)
    %   x - vector with x values for the plot
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    %   st - string with title for upper window
    %   sx  - string for the x-axis label
    %   sy1  - string for the y-axis label in the upper window
    %   sleg1 - strings for the upper legend (number of strings must be equal to
    %          number of columns in y-Matrix, e.g. {'firstline','secondline'}
    %   sy2 - string for the y-label of the lower window
    %   sleg2 - strings for the lower legend (number of strings must be equal to
    %          number of columns in y-Matrix, e.g. {'firstline','secondline'}
    %   stxt - string with the verification result information
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
%  Version  Author   Changes                                     Date
%  6.1.0    hf       created                                     25mar2014
%  6.1.1    hf       variable number of input arguments          02apr2014
%  6.2.0    hf       return argument is [v, s]                   03oct2014
%  6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
