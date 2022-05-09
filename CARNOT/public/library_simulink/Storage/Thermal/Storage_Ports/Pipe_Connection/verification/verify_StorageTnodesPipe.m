%% verify_StorageTnodesPipe - verification of the pipe connection for StorageTnodes block in Carnot
%% Function Call
%  [v, s] = verify_StorageTnodesPipe(varargin)
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
%  Validation of the pipe connection for the StorageTnodes block in the 
%  Carnot Toolbox by checking: 
%  1) the internal energy balance of the storage with the external balance 
%     of the water flow
%  2) the outlet temperatures of the pipe connection
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_StorageTnodesPipe(varargin)
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
    error('verify_StorageTnodesPipe:%s',' too many input arguments')
end

%% set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.02;       % max error between internal and external balance in kWh
max_simu_error = 1e-7;  % max error between initial and current simu in J

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodesPipe_mdl';
functionnamedisp = strrep(functionname,'_',' ');

t0 = 0:300:4*3600;

%%  -------------- simulate the model or call the function -----------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2i = yt.data(:,1);     % internal energy balance
y2e = yt.data(:,2);     % external energy balance
y2t = yt.data(:,3:end); % outlet temperatures
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation ---------------
if (save_sim_ref)
    y1i = y2i;   % determinded data
    y1t = y2t;
    save('simRef_StorageTnodesPipe.mat','y1i','y1t');
else
    load('simRef_StorageTnodesPipe.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0i = y1i;
y0t = y1t;
disp('verify_Pipe_stratified_discharge.m: using simulation data as reference data')


%% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error in the energy balance
% error between current internal balance and reference
[e1, ye1] = calculate_verification_error(y0i, y2i, r, s);
% error between current internal balance and initial internal balance
[e2, ye2] = calculate_verification_error(y1i, y2i, r, s);
% error between current internal and current external balance
[e3, ye3] = calculate_verification_error(y2i, y2e, r, s);
e3 = e3/36e5;  % J to kWh
ye3 = ye3/36e5;

% ------------- decide if verification is ok --------------------------------
if e1 > max_simu_error
    v = false;
    s = sprintf('validate internal balance %s with 1st calculation FAILED: error %3.5g J > allowed error %3.5g J', ...
        functionnamedisp, e1, max_error);
    show = true;
elseif e2 > max_simu_error
    v = false;
    s = sprintf('validate exernal balance %s with 1st calculation FAILED: error %3.5g J > allowed error %3.5g J', ...
        functionnamedisp, e2, max_simu_error);
    show = true;
elseif e3 > max_error
    v = false;
    s = sprintf('validate internal and external energy balance of %s FAILED: error %3.5g kWh%% > allowed error %3.5g kWh', ...
        functionnamedisp, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('validate %s OK: error %3.5g kWh%', functionnamedisp, e3);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'time in h';               % x-axis label
    st = 'Validation pipe connection and storage model';       % title
    sy1 = 'Energy in kWh';          % y-axis label in the upper plot
    sy2 = 'Difference';             % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference initial','internal initial','internal current','external current'};
    % lower legend
    sleg2 = {'internal reference vs current','internal initial vs current','current internal vs external'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0i, y1i, y2i y2e], [ye1,ye2,ye3], ...
        st, sx, sy1, sleg1, sy2, sleg2, s)
end

% error in the outlet temperatures
if v == true         % evaluate only if energy balance is ok
    % error between reference and initial simulation
    [e1, ye1] = calculate_verification_error(y0t, y1t, r, s);
    % error between current and initial simulation
    [e2, ye2] = calculate_verification_error(y1t, y2t, r, s);
    % error between current and reference simulation
    [e3, ye3] = calculate_verification_error(y0t, y2t, r, s);
    
    % ------------- decide if verification is ok --------------------------------
    if e1 > max_simu_error
        v = false;
        s = sprintf('validate outlet temperatures %s reference with 1st sim FAILED: error %3.5g J > allowed error %3.5g J', ...
            functionnamedisp, e1, max_error);
        show = true;
    elseif e2 > max_simu_error
        v = false;
        s = sprintf('validate outlet temperatures %s 1st sim with current sim FAILED: error %3.5g J > allowed error %3.5g J', ...
            functionnamedisp, e2, max_simu_error);
        show = true;
    elseif e3 > max_error
        v = false;
        s = sprintf('validate outlet temperatures of %s reference with current sim FAILED: error %3.5g %% > allowed error %3.5g ', ...
            functionnamedisp, e3, max_simu_error);
        show = true;
    else
        v = true;
        s = sprintf('validate %s OK: error %3.5g °C%', functionnamedisp, e3);
    end
    
    % diplay and plot if required
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        sx = 'time in h';               % x-axis label
        st = 'Validation pipe connection and storage model';       % title
        sy1 = 'Temperature in °C';      % y-axis label in the upper plot
        sy2 = 'Difference in K';        % y-axis label in the lower plot
        % upper legend
        sleg1 = {'reference','initial','current'};
        % lower legend
        sleg2 = {'refernce vs inital','initial vs current','reference vs current'};
        %   y - matrix with y-values (reference values and result of the function call)
        %   ye - matrix with error values for each y-value
        display_verification_error(t0/3600, [y0t, y1t, y2t], [ye1,ye2,ye3], ...
            st, sx, sy1, sleg1, sy2, sleg2, s)
    end
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
%  $Revision: 81 $
%  $Author: goettsche $
%  $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     12dec2014
%  6.1.1    hf      filename validate_ replaced by verify_      09jan2015
%  6.1.2    hf      close system without saving it              16may2016
%  6.1.3    hf      adapted calculation, save_sim_ref added     10oct2017
%  6.1.1    hf      comments adapted to publish function        07nov2017
%  6.2.0    hf      added temperature comparision               09sep2018
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
