%% verify_PipeStratEnhanced - verification of the PipeStratEnhanced block in Carnot
%% Function Call
%  [v, s] = verify_PipeStratEnhanced(varargin)
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
%  Verification of the PipeStratEnhanced block in the Carnot Toolbox by
%  comparing the simulation result of the block with an other model which
%  uses seperate models for stratified charging and pipe connection. See
%  model verify_PipeStratEnhanced_mdl for details.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = todo_verify_PipeStratEnhanced(varargin)
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
    error('verify_PipeStratEnhanced:%s',' too many input arguments')
end

%% set specific model parameters
% set error tolerances
max_error = 1000;            % max error between simulation and reference
max_simu_error = 1000;   % max error between initial and current simu

% set model filename
functionname = 'verify_PipeStratEnhanced_mdl';
% outlet positions of stratified charging/discharging pipe
u0 = 0:0.2:1;       
nsim = length(u0);

%% set the reference values 
% initial simulation
if (~save_sim_ref)
    y1 = importdata('simRef_PipeStratEnhanced.mat'); % data from file
end
% reference values of "literature"
disp(['verify_PipeStratEnhanced.m: using different model as reference data, see ' functionname])
y0 = zeros(1,nsim);         % both models have the same result: difference should be zero
t0 = 0:300:5*3600;          % time vector

%% simulate the model
load_system(functionname )
y2 = zeros(1,nsim);         % preallocation of y2
v = true;                   % be optimistic, assume that validation is true :-)
for n = 1:nsim
    set_param([functionname, '/Storage_PipeStat_PipeConnect'], 'outlet_charge', num2str(u0(n)));
    set_param([functionname, '/Storage_PipeStat_PipeConnect'], 'outlet_discharge', num2str(1-u0(n)));
    set_param([functionname, '/Storage_PipeStratEnhanced'], 'outlet_charge', num2str(u0(n)));
    set_param([functionname, '/Storage_PipeStratEnhanced'], 'outlet_discharge', num2str(1-u0(n)));
    
    simOut = sim(functionname, 'SrcWorkspace','current', 'SaveOutput','on','OutputSaveName','yout');
    yy = simOut.get('yout');            % get the whole output vector (one value per simulation timestep)
    tt = simOut.get('tout');            % get the whole time vector from simu
    tsy = timeseries(yy,tt);            % timeseries for the columns
    tx = resample(tsy,t0);              % resample with t0
    y2(n) = tx.data(end,1);             % error calculation with the last value of the temperature integral
    Tref = tx.data(:,2:(end-1)/2+1);    % node temperatures of reference model
    Tsim = tx.data(:,(end-1)/2+2:end);  % node temperatures of PipeStratEnhanced model
    
    % result at creation of function, if required it can be determined from the simulation result
    if (save_sim_ref)
        y1(n) = y2(n);   % determinded data
    end
    
    %% calculate the errors
    r = 'absolute';
    se = 'max';
    % error between reference and initial simu
    [e1, ~] = calculate_verification_error(y0(n), y1(n), r, se);
    % error between reference and current simu
    [e2, ~] = calculate_verification_error(y0(n), y2(n), r, se);
    % error between initial and current simu
    [e3, ~] = calculate_verification_error(y1(n), y2(n), r, se);
    
    %% decide if verification is ok
    if e2 > max_error
        v = false;
        s2 = sprintf(['verification %s with reference at stratified charge ' ...
            'outlet position %3.1f FAILED: error %3.5g > allowed error %3.5g'], ...
            functionname, u0(n), e2, max_error);
        show = true;
    elseif e3 > max_simu_error
        v = false;
        s2 = sprintf(['verification %s with 1st calculation at stratified charge' ...
            'outlet position %3.1f FAILED: error %3.5g > allowed error %3.5g'], ...
            functionname, u0(n), e3, max_simu_error);
        show = true;
    else            
        s2 = sprintf('%s at stratified charge outlet position %3.1f OK: error %3.5g', ...
            functionname, u0(n), e2);
    end
%     if v                % validation is still true, set output string s
        s = s2;
%     end
    
    %% diplay and plot results if required
    if (show)
        disp(s2)
        disp(['Initial error = ', num2str(e1)])
        ye = Tref - Tsim;
        sz = strrep(s2, '_', ' ');
        figure
        ax1 = subplot(2,2,1);
        plot(t0,Tref)
        title('Tnodes Reference')
        xlabel('time in s')
        ylabel('temperatures in °C')
        ax2 = subplot(2,2,2);
        plot(t0,Tsim)
        title('Tnodes PipeStratEnhanced')
        xlabel('time in s')
        ylabel('temperatures in °C')
        ax3 = subplot(2,2,3);
        plot(t0,ye)
        title('Difference between models')
        linkaxes([ax1, ax2, ax3], 'x')
        xlabel('time in s')
        ylabel('temperature difference in K')
        text(1.2,0.5,sz,'Units','normalized')
    end
end % for n
close_system(functionname, 0)   % close system, but do not save it

%% save simulation reference if required
if (save_sim_ref)
    save('simRef_PipeStratEnhanced.mat','y1');
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
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created on the base of verify_StorageType_2 03aug2020
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
