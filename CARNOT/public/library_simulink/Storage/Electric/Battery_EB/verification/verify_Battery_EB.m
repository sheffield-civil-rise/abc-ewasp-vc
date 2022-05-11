%% verify_Battery_EB - verification of the Battery_EB model in Carnot 
%% Function Call
%  [v, s] = verify_Battery_EB(varargin)
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
%  Template for Simulink-Block verification in the Carnot 
%  Toolbox. If your Block uses functions which may also be used as m-functions,
%  please use this template for both calls (Simulink-Block and m-function).
%  Change the name of the function to "verfiy_YourBlockName" otherwise it
%  will not be found be the verification_carnot.m skript in the version_manager
%  folder.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Battery_EB(varargin)
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
    error('verify_Battery_EB:%s',' too many input arguments')
end

%% set specific model or function parameters
% ----- set error tolerances ----------------------------------------------
max_error = 1e-3;           % max error between simulation and reference
max_simu_error = 1e-7;      % max error between initial and current simu

%% set model file or function name ------------------------------
functionname = 'verify_Battery_EB_mdl';

% m_function = true; % set to 'true' if it is an m-function
% functionname = 'myM_Function_verificationDemo';

%% set the literature reference values -------------------
% P = [0 100 -100 10000 -10000 -10000]   charge/discharge power
% t = [0 5e5  6e5 7e5      8e5    9e5]   time vector for P
C = 5e6;  % battery capacity in J
t1 = C/(10/0.9);            % discharging with standby power
t2 = C/((100-10)*0.9);      % charging with 100 W - standby power
t3 = C/((100+10)/0.9);      % discharging with 100 W + standby power
t4 = C/1000;                % charging power limit 1 kW
t5 = C/1000;                % discharging power limit 1 kW
t0 = [0     t1/2    t1      5e5     5e5+t2/2    5e5+t2  6e5     6e5+t3/2    6e5+t3  7e5         7e5+t4/2    7e5+t4  8e5     8e5+t5/2    8e5+t5  9e5]';
y0 = [5e6   5e6/2   0       0       5e6/2       5e6     5e6     5e6/2       0       0           5e6/2       5e6     5e6     5e6/2       0       0; ... % energy in battery
      0,0,0,0,90,0,0,0,0,0,1111.11111111111,0,0,0,0,0;                          ... % charging power AC
      0,-10,-10,0,0,0,0,-110.000000000000,-110.000000000000,0,0,0,0,-900,0,0;   ... % discharging power AC
      0,0,0,0,0,90,0,0,0,8878.88888888889,8878.88888888889,9990,0,0,0,0;        ... % P over
      0,0,0,0,0,0,0,0,0,0,0,0,-9110,-9110,-10010,-10010]';                          % P under
    
 
%% simulate the model or call the function
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout');        % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout');        % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
y2 = yt.data;              % the timedepandant output is interesting
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_BatteryEB.mat','y1');
else
    y1 = importdata('simRef_BatteryEB.mat');  % result from call at creation of function
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
    sx = 'x-label';                         % x-axis label
    st = 'Simulink block verification';     % title
    sy1 = 'y-label up';                     % y-axis label in the upper plot
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
    x = repmat(t0,5,1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [reshape(y0,numel(y0),1), reshape(y1,numel(y1),1), reshape(y2,numel(y2),1)];
    % y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [reshape(ye1,numel(ye1),1), reshape(ye2,numel(ye2),1), reshape(ye3,numel(ye3),1)];
    % ye = [ye1, ye2, ye3]; 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
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
%  $Revision: 81 $
%  $Author: goettsche $
%  $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created, based on MasterVerification.m      09nov2019
%  7.1.1    hf      enlarged max_simu_error eps(100) to 1e-7    19feb2022
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
