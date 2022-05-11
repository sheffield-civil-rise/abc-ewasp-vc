%% verify_PumpAdditionalIntegrationSeries: integration test of Pump_Main and Pump_Additional
%% Function Call
%  [v, s] = verify_Pump_Additional(varargin)
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
%  Integrtation test of the Pump_Main and Pump_Additional block in the 
%  Carnot Toolbox. 
%  Requirements:
%  + Control signal of the Pump_Main switches the flow in the hole circuit
%  + Control signal of the Pump_Additional switches the flow in its branch
%  + Pump_Main and Pump_Additional in series add the pressure head
%  + Pump_Main and Pump_Additional in series keep the max. massflow of one pump
%  + Two Pump_Additional in parallel add the masslfows
%  + Two Pump_Additional in parallel keep the pressure head of one pumpe
%                                                                          
%  Literature:   --
%  see also verify_Pump_Additional, verify_Pump_Main, verification_carnot

function [v, s] = verify_PumpAdditionalIntegrationSeries(varargin)
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
    error('verify_PumpAdditionalIntegrationSeries:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_PumpAdditionalIntegrationSeries_mdl';

% % reference time vector
t0 = 0:5:400;

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
y2 = tx.data;
close_system(functionname, 0)   % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set the literature reference values -------------------

% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_PumpAdditionalIntegrationSeries.mat','y1');
else
    y1 = importdata('simRef_PumpAdditionalIntegrationSeries.mat');  % result from call at creation of function
end

y0 = y1;
disp('verify_PumpAdditionalIntegrationSeries.m: see requirements for reference data')

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
    y_p1    = [y0(:,1), y1(:,1), y2(:,1)];
    y_p2    = [y0(:,2), y1(:,2), y2(:,2)];
    y_p3    = [y0(:,3), y1(:,3), y2(:,3)];
    y_mdot1 = [y0(:,4), y1(:,4), y2(:,4)];
    y_mdot2 = [y0(:,5), y1(:,5), y2(:,5)];
    y_mdot3 = [y0(:,6), y1(:,6), y2(:,6)];
    
    %   x - vector with x values for the plot
    x = t0;
    
    %   ye - matrix with error values for each y-value
    ye_p1    = [ye1(:,1), ye2(:,1), ye3(:,1)];
    ye_p2    = [ye1(:,2), ye2(:,2), ye3(:,2)];
    ye_p3    = [ye1(:,3), ye2(:,3), ye3(:,3)];
    ye_mdot1 = [ye1(:,4), ye2(:,4), ye3(:,4)];
    ye_mdot2 = [ye1(:,5), ye2(:,5), ye3(:,5)];
    ye_mdot3 = [ye1(:,6), ye2(:,6), ye3(:,6)];
    
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % pressure plots
    subplot(2,6,1)      % divide in subplots (lower and upper one)
    plot(x,y_p1,'-')
    title(st)
    ylabel('pressure in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,7)      % choose lower window
    plot(x,ye_p1,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    subplot(2,6,2)      % divide in subplots (lower and upper one)
    plot(x,y_p2,'-')
    title(st)
    ylabel('pressure in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,8)      % choose lower window
    plot(x,ye_p2,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    subplot(2,6,3)      % divide in subplots (lower and upper one)
    plot(x,y_p3,'-')
    title(st)
    ylabel('pressure in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,9)      % choose lower window
    plot(x,ye_p3,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    % massflow plots
    subplot(2,6,4)      % divide in subplots (lower and upper one)
    plot(x,y_mdot1,'-')
    title(st)
    ylabel('massflow in Kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,10)      % choose lower window
    plot(x,ye_mdot1,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Kg/s')
    
    subplot(2,6,5)      % divide in subplots (lower and upper one)
    plot(x,y_mdot2,'-')
    title(st)
    ylabel('massflow in Kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,11)      % choose lower window
    plot(x,ye_mdot2,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Kg/s')
    
    subplot(2,6,6)      % divide in subplots (lower and upper one)
    plot(x,y_mdot3,'-')
    title(st)
    ylabel('massflow in Kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,6,12)      % choose lower window
    plot(x,ye_mdot3,'-')
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Kg/s')
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
%  6.1.0    hf      created                                     26dec2018
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
