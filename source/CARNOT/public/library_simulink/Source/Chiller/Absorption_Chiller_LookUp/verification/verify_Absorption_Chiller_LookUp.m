%% verify_Absorption_Chiller_LookUp - verification of the absorption chiller model in Carnot 
%% Function Call
%  [v, s] = verify_Absorption_Chiller_LookUp(varargin)
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
%  Verification of the absorption chiller model in Carnot in the Carnot 
%  Toolbox.
%                                                                          
%  Literature:   Validation_Report_absorption_chiller_Yazaki_WFC-SC5.pdf
%  see also verification_carnot

function [v, s] = verify_Absorption_Chiller_LookUp(varargin)
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
    error('verify_Absorption_Chiller_LookUp:%s',' too many input arguments')
end

%% set specific model or function parameters
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;            % max error between simulation and reference
max_simu_error = eps(100);  % max error between initial and current simu

%% set model file or function name ------------------------------
functionname = 'verify_Absorption_Chiller_LookUp_mdl';

%% set the literature reference values -------------------
% u0 = 1:10;                  % reference input values
t0 = 0:120:3600;            % reference time vector

%% simulate the model or call the function
% y2 = zeros(length(t0),length(u0));
% y2 = zeros(1,length(u0));
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
% y2(n) = yy(end);       % in this example, only the final value is interesting
% y2(:,n) = yt.data;     % in this example, the timedepandant output is interesting
y2 = yt.data;           % the timedepandant output is interesting
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Absorption_Chiller_LookUp.mat','y1');
else
    y1 = importdata('simRef_Absorption_Chiller_LookUp.mat');  % result from call at creation of function
end

% use simulation data as reference
y0 = y1;
disp('verify_Absorption_Chiller_LookUp: Using simulation data as reference')

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
    s = sprintf('verification %s with 1st calculation FAILED: error %3.5e > allowed error %3.5e', ...
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
    sx = 'time in s';                       % x-axis label
    st = 'Simulink block verification';     % title
    sy1 = 'cooling power in W';             % y-axis label in the upper plot
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
    x = reshape(t0,length(t0),1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    % y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    % ye = [ye1, ye2, ye3]; 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
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
%  $Revision: 1 $
%  $Author: goettsche $
%  $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     22dec2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *