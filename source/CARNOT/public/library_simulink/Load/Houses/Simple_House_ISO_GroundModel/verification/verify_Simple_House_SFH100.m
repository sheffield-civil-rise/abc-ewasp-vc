%% verify_Simple_House_SFH100 - verification of the Simple_House_ISO_GroundModel block in Carnot
%% Function Call
%  [v, s] = verify_Simple_House_SFH100(varargin)
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
%  Validation of the Simple House Model with ISO Ground Model in the Carnot 
%  Toolbox by using the benchmark of the IEA SHC TASK 44 and IEA HPP ANNEX 38. 
%  The benchmark is the % comparison of simulation results from TRNSYS.
%                                                                          
%  Literature:   reports of IEA SHC TASK 44 and IEA HPP ANNEX 38
%                (see link to reports in the model)
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Simple_House_SFH100(varargin)
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
    error('verify_Simple_House_SFH100:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 10;         % max error between TRNSYS and Carnot in kWh/m²
max_simu_error = 1e-7;  % max error between initial and current Carnot simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_Simple_House_SFH100_mdl';
functionnamedisp = strrep(functionname,'_',' ');

% ----------------- set the literature reference values -------------------
mm = [0 31 28 31 30 31 30 31 31 30 31 30 31]; % end of month
t0 = zeros(1,12);
for n = 1:length(mm)
    t0(n) = sum(mm(1:n))*24*3600;
end

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)
load('FR_Strasbourg.mat');      % load weather data
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
% simOut = sim(functionname, 'SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2 = diff(yt.data(:,1));     % monthly energy balance
close_system(functionname, 0)   % close system, but do not save it

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_SimpleHouseSFH100.mat','y1');
else
    y1 = importdata('simRef_SimpleHouseSFH100.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
% reference results from TRNSYS simulation (Type 56 building model)
% Single family house with ~15 kWh/m² in Strasbourg
% columns: month TRNSYS Simulink AbsError RelError
Q100 = [1, 22.8, 23.8, 1, 4.3; ...
        2, 16.6, 18, 1.4, 8.2; ...
        3, 10.9, 13.2, 2.3, 20.6; ...
        4, 4.8, 7.2, 2.4, 0; ...
        5, 0.95, 2.05, 1.1, 100; ...
        6, 0, 0.2, 0.1, 0; ...
        7, 0, 0, 0, 0; ...
        8, 0, 0, 0, 0; ...
        9, 0.8, 1.9, 1.1, 0; ...
        10, 6.1, 8, 1.9, 30.9; ...
        11, 15.5, 17.3, 1.8, 11.3; ...
        12, 21.6, 22.4, 0.8, 3.8];
y0 = Q100(:,2); % compare to TRNSYS


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'sum';

% error between internal reference and inital simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between external reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between internal and external balance
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e1 > max_error
    v = false;
    s = sprintf('verification %s initial simulation with TRNSYS FAILED: error %3.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
elseif e2 > max_error
    v = false;
    s = sprintf('verification %s current simulation with TRNSYS FAILED: error %5.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
% elseif e3 > max_simu_error 
elseif e3 > max_simu_error % corrected because refence is not the same model
    v = false;
    s = sprintf('verification %s initial with current simulation FAILED: error %3.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, e1+max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3g kWh/m²', functionnamedisp, e2);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'time in h';               % x-axis label
    st = 'Validation simple house model';       % title
    sy1 = 'Energy in kWh/m²';       % y-axis label in the upper plot
    sy2 = 'Difference';             % y-axis label in the lower plot
    % upper legend
    sleg1 = {'TRNSYS','initial','current'};
    % lower legend
    sleg2 = {'TRNSYS vs. initial','TRNSYS vs. current','initial vs. current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0(2:end)/(24*3600), [y0, y1, y2], [ye1,ye2,ye3], ...
        st, sx, sy1, sleg1, sy2, sleg2, s)
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Load/Houses/Simple_House_ISO_GroundModel/verification/verify_Simple_House_SFH100.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     27dec2014
%  6.1.1    hf      load weather data before simulation         03jan2015
%  6.1.2    hf      comparision of y1 and y2 not valid because  06jan2015
%                   of different models, corrected if e3 > ...
%  6.1.3    hf      filename validate_ replaced by verify_      09jan2015
%  6.1.4    hf      close system without saving it              16may2016
%  6.2.0    hf      comments adapted to publish function        01nov2017
%                   added save_sim_ref as 2nd input argument
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
