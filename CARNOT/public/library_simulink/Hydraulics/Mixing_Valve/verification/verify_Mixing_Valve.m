%% verify_Mixing_Valve - verification of the Mixing_Valve block in Carnot
%% Function Call
%  [v, s] = verify_ValveTable(varargin)
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
%  Verification of the Mixing_Valve block in the Carnot Toolbox by
%  comparing the simulation to the initial simulation and a reference
%  model from Thamo 6.2.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Mixing_Valve(varargin)
% ---- check input arguments ----------------------------------------------
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
    error('verify_Mixing_Valve:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 7e-3;        % max error between simulation and reference
max_simu_error = 4e-5;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Mixing_Valve_mdl';

% % reference time vector
t0 = 0:5:600;

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout');        % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout');        % get the whole time vector from simu
tsy = timeseries(yy,tt);        % timeseries for the columns
tx = resample(tsy,t0);          % resample with t0
y2 = tx.data(:,[3,4]);          % simulation model results
y0 = tx.data(:,[1,2]);          % reference model results
y2(:,1) = y2(:,1)/1e5;          % Pa to bar
y0(:,1) = y0(:,1)/1e5;          % Pa to bar
close_system(functionname, 0)   % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Mixing_Valve.mat','y2');
else
    y1 = importdata('simRef_Mixing_Valve.mat');  % result from call at creation of function
end


%% -------- calculate the errors ------------------------------------------
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

% ------------- decide if verification is ok ------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.3g > allowed error %3.3g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3g > allowed error %3.3g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3g', functionname, e2);
end

%% ------------ display and plot results if required ----------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    
    st = 'Simulink block verification';     % title
    sx = 'Time in s';                       % x-axis label
    
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_p     = [y0(:,1), y1(:,1), y2(:,1)];
    y_mdot  = [y0(:,2), y1(:,2), y2(:,2)];

    
    %   x - vector with x values for the plot
    x = t0;
    
    %   ye - matrix with error values for each y-value
    ye_p    = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    ye_mdot = [ye1(:,2), ye2(:,2), ye3(:,2)]; 

    
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % pressure plots
    subplot(2,2,1)      % divide in subplots (lower and upper one)
    if size(y_p,2) == 3
        plot(x,y_p(:,1),'x',x,y_p(:,2),'o',x,y_p(:,3),'-')
    else
        plot(x,y_p,'-')
    end
    title(st)
    ylabel('pressure in 1e5 Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,2,3)      % choose lower window
    if size(ye_p,2) == 3
        plot(x,ye_p(:,1),'x',x,ye_p(:,2),'o',x,ye_p(:,3),'-')
    else
        plot(x,ye_p,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in 1e5Pa')
    
    % ID plots
    subplot(2,2,2)      % divide in subplots (lower and upper one)
    if size(y_mdot,2) == 3
        plot(x,y_mdot(:,1),'x',x,y_mdot(:,2),'o',x,y_mdot(:,3),'-')
    else
        plot(x,y_mdot,'-')
    end
    title(st)
    ylabel('massflow in kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,2,4)      % choose lower window
    if size(ye_mdot,2) == 3
        plot(x,ye_mdot(:,1),'x',x,ye_mdot(:,2),'o',x,ye_mdot(:,3),'-')
    else
        plot(x,ye_mdot,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in kg/s')
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
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    ts      created                                     08mar2019
%  7.1.1    hf      enlarged max_simu_error (1e-7 to 4e-5)      19feb2022
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
