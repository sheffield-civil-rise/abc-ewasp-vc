%% verify_legaltime2solartime - verification of the legaltime2solartime function in Carnot
%% Function Call
%  [v, s] = verify_legaltime2solartime(varargin)
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
%  verification of the legaltime2solartime function in Carnot
%                                                                          
%  Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006
%  see also template_verify_mFunction, template_verify_SimulinkBlock,
%  verification_carnot, legaltime2solartime

function [v, s] = verify_legaltime2solartime(varargin)
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
    error('verify_legaltime2solartime:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 44;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functin name -------------------------------
functionname = 'legaltime2solartime';

%% simulate the model or call the function -----------------
u0 = 3600*(12+24*(1:30:365));           % legal time is noon at different days
y2 = legaltime2solartime(u0,0,0)-u0;    % reference simu solar time

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_legal2solartime.mat','y1');
else
    y1 = importdata('simRef_legal2solartime.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
n = u0./(24*3600);
b = ((n-81)*360/364);
b = b*pi/180;
% y0 is difference between solar and legal time in s
y0 = (9.87*sin(2*b)-7.53*cos(b)-1.5*sin(b))*60;

%---------------------- source code of carlib -----------------------
%     time = u0;
%     SECONDSPERDAY = 24/3600;
%     timezone = 0;
%     longitude = 0;
%     time_in_days = floor(time/SECONDSPERDAY);
%     b = 1.992384990861107e-7*time;
%     e = 13752.0*(0.000075 + 0.001868*cos(b) - 0.032077*sin(b) ...
%         - 0.014615*cos(2.0*b) - 0.04089*sin(2.0*b));
%     y3 = (e + 240.0*(timezone-longitude) + (time - (SECONDSPERDAY*time_in_days)));
% ------------------ end of source code carlib ----------------------------


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
    s = sprintf('verification %s with reference FAILED: error %3.3f s > allowed error %3.3f s', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3f s > allowed error %3.3f s', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3f s', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error ', num2str(e1), ' s'])
    sx = 'x-label';
    sy1 = 'y-label up';
    sy2 = 'Difference';
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, functionname, sx, sy1, sleg1, sy2, sleg2, s)
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/time_functions/legaltime2solartime/verification/verify_legaltime2solartime.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     25mar2014
%  6.1.1    hf      variable number of input arguments          02apr2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    hf      filename validate_ replaced by verify_      09jan2015
%  6.3.0    hf      comments adapted to publish function        01nov2017
%                   added save_sim_ref as 2nd input argument
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
