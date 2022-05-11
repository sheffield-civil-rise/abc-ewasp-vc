%% verification of the HeatExchanger block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_HeatExchanger(varargin)
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
%  verification of the HeatExchanger block in the Carnot Toolbox by
%  comparing the current simulation results with an initial simulation and
%  measurement data of a heat exchanger in a fresh water station
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_HeatExchanger(varargin)
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
    error('verify_HeatExchanger:%s',' too many input arguments')
end

%% ---------- model 1: validate energy balance for multinode model
% ----- set error tolerances ----------------------------------------------
max_error = 0.025;      % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_HeatExchanger_mdl';

% ----------------- set the literature reference values -------------------
t0 = 0:5930;        % reference time vector

%  -------------- simulate the model or call the function -----------------
load_system(functionname)
load measurement_HX.mat T_prim_in T_prim_out T_sec_in T_sec_out m_prim m_sec  %#ok<NASGU>
simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
xx = simOut.get('yout');            % get output vector
t2 = simOut.get('tout');            % get the time vector
tsy = timeseries(xx,t2);            % timeseries with temperatures
tx = resample(tsy,t0);              % resample with t0
y2 = tx.data(:,3:4);
close_system(functionname, 0)       % close system, but do not save it

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result

if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_heatexchanger.mat','y1');
else
    y1 = importdata('simRef_heatexchanger.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = tx.data(:,1:2);  % power calculated in the model from measured temperature and massflow

% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value of the individual errorsS
r = 'relative'; 
s = 'last';

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('energy verification %s with reference FAILED: relative error %3.3g > allowed error %3.3g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('energy verification %s with 1st calculation FAILED: relative error %3.3g > allowed error %3.3g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('energy %s OK: difference %3.3g J', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial relative error = ', num2str(e1)])
    x = t0/3600; %   x - vector with x values for the plot: time in h
    stx = strrep(s,'_',' ');

    figure
    % plot the power balance of the primary side
    ax11 = subplot(2,2,1);
    plot(x,[y0(:,1), y1(:,1), y2(:,1)])
    title('Simulink block verification');
    text(0,-0.2,stx,'Units','normalized')  % display valiation text
    legend('reference data','initial simulation','current simulation','Location','best');
    xlabel('time in h');
    ylabel('Energy in J');
    % plot the energy difference of the primary side
    ax12 = subplot(2,2,3);
    plot(x,[ye1(:,1), ye2(:,1), ye3(:,1)])
    legend('ref. vs initial simu','ref. vs current simu','initial simu vs current','Location','best');
    xlabel('time in h');
    ylabel('Energy difference in J');
    linkaxes([ax11, ax12], 'x')

    % plot the power balance of the secondary side
    ax21 = subplot(2,2,2);
    plot(x,[y0(:,2), y1(:,2), y2(:,2)])
    legend('reference data','initial simulation','current simulation','Location','best');
    xlabel('time in h');
    ylabel('Energy in J');
    % plot the energy difference of the secondary side
    ax22 = subplot(2,2,4);
    plot(x,[ye1(:,2), ye2(:,2), ye3(:,2)])
    legend('ref. vs initial simu','ref. vs current simu','initial simu vs current','Location','best');
    xlabel('time in h');
    ylabel('Energy difference in J');    
    linkaxes([ax21, ax22], 'x')
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
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    ts      created                                     03oct2016
%  6.2.0    hf      comments adapted to publish function        01nov2017
%                   added save_sim_ref as 2nd input argument
%  7.1.0    hf      reference data is measurement of            20nov2019
%                   a fresh water station
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
