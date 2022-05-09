%% verify_StorageTnodes_inverseTC - verification of the StorageTnodes block in Carnot
%% Function Call
%  [v, s] = verify_StorageTnodes_inverseTC(varargin)
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
%  Validation of the inverse thermocline elimination of the s-function 
%  StorageTnodes in the Carnot Toolbox. The benchmark is the analytical
%  solution of the mixed storage nodes
%                                                                          
%  Literature: --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_StorageTnodes_inverseTC(varargin)
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
    error('verify_StorageTnodes_inverseTC:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;      % max error between simulation and reference (EN12977)
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodes_inverseTC_mdl';
% functionnamedisp = strrep(functionname,'_',' ');

% parameters for benchmar according to EN 12977-3 Annex A
% cp = 4181.0;    % heat capacity of fluid (water, constant)
% rho = 998.21;   % density of fluid (water, constant)
tini = 55:-5:10;

% ----------------- set the literature reference values -------------------
u0 = 1:2;                   % reference input values
y0(1,:) = tini;         % no elimination during first run
% since water properties are constant, 
% the mixed temperature is simply the mean
y0(2,:) = ones(1,length(tini))*mean(tini);

%% simulate the model or call the function
y2 = zeros(2,10);
load_system(functionname)
for n = 1:length(u0)
    set_param([functionname,'/sfun_storageTnodes'], 'elimthermocline', num2str(u0(n)-1));
    simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
    y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
    y2(n,:) = y(end,:);
end
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_StorageTnodesInvTc.mat','y1');
else
    y1 = importdata('simRef_StorageTnodesInvTc.mat');  % result from call at creation of function
end


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
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
    sx = 'simulation run';                  % x-axis label
    st = 'Simulink block verification';     % title
    sy1 = 'temperature in °C';              % y-axis label in the upper plot
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
    x = reshape(u0,length(u0),1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1, ye2, ye3]; 
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
%  $Revision: 372 $
%  $Author: carnot-wohlfeil $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Basic/Thermal_Models/sfun_storageTnodes/verification/verify_StorageTnodes_inverseTC.m $
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     26feb2018
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
