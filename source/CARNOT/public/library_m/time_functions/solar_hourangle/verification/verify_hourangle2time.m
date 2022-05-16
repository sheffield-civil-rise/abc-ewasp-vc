%% verification of the hourangle2time function in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_hourangle2time(varargin)
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
%  verification of the hourangle2time function in the Carnot Toolbox
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, verification_carnot

function [v, s] = verify_hourangle2time(varargin)
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
    error('verify_hourangle2time:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functin name -------------------------------
functionname = 'hourangle2time';

%% simulate the model or call the function -----------------
u0 = 0;           % reference hour angle is 0�
y2 = hourangle2time(u0);    % current result initialized a matrix of zeros

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_hourangle2time.mat','y1');
else
    y1 = importdata('simRef_hourangle2time.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = 12*3600;     % time is solar noon

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
    s = sprintf('verification %s with reference FAILED: error %5.3g > allowed error %3.3g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %5.3g > allowed error %3.3g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %5.3g', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error ', num2str(e1)])
    sx = 'Hour Angle';
    sy1 = 'Time in s';
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/time_functions/solar_hourangle/verification/verify_hourangle2time.m $
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