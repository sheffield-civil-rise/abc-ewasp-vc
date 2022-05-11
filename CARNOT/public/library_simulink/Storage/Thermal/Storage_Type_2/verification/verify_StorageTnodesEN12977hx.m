%% verify_StorageTnodesEN12977hx - verification of the StorageTnodes block in Carnot
%% Function Call
%  [v, s] = verify_StorageTnodesEN12977hx(varargin)
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
%  Validation of the s-function StorageTnodes in the Carnot Toolbox by
%  using the benchmark defined in EN 12977-3 Annex A. The benchmark is the
%  use of the storage as counter-current heat exchanger. For fixed inlet
%  conditions (massflow, temperature) and heat transfer UA the
%  analytical solution is given by the EN.
%                                                                          
%  Literature:   EN 12977-3
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_StorageTnodesEN12977hx(varargin)
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
    error('verify_StorageTnodesEN12977hx:%s',' too many input arguments')
end

%% set your specific model or function parameters here
%  set error tolerances from EN 12977-3:2012 Annex A
max_error = 0.2;            % max error for temperature between simulation and reference is 0.2 K
max_rerror = 0.03;          % max relative error for energy between simulation and reference is 3 %
max_simu_error = 0.001;     % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodesEN12977hx_mdl';
functionnamedisp = strrep(functionname(1:end-4),'_','');

%% set the literature reference values -------------------
% parameters for benchmark according to EN 12977-3:2012 Annex A
% cp = 4181.0;    % heat capacity of fluid (water, constant)
% T1in = 90;      % °C
% mdot1 = 200;    % kg/h
% T2in = 20;      % °C
% mdot2 = 600;    % kg/h
% UA = 1667;      % W/K heat transfer coefficient of the heat exchanger
% expected result is given by EN 12977-3:2012 Annex A, table A.1
t0 = 0:3600:24*3600;
y0t = [43.202, 20.391];             % reference results temperature 
y0q = 16165;                        % reference results power
y0t = repmat(y0t,length(t0),1);
y0q = repmat(y0q,length(t0),1);

%% simulate the model or call the function -----------------
load_system(functionname)

% set parameters
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2t = yt.data(:,1:2);
y2q = yt.data(:,3);
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation ---------------
if (save_sim_ref)
    y1t = y2t;   % determinded data
    y1q = y2q;
    save('simRef_StorageTnodesEN12977hx.mat','y1t','y1q');
else
    load('simRef_StorageTnodesEN12977hx.mat','y1t','y1q');  % result from call at creation of function
end

%% calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim
rt = 'absolute'; 
rq = 'relative'; 
s = 'last';

% error between reference and initial simu 
[e1t(:,1), ye1t(:,1)] = calculate_verification_error(y0t(:,1), y1t(:,1), rt, s);
[e1t(:,2), ye1t(:,2)] = calculate_verification_error(y0t(:,2), y1t(:,2), rt, s);
E1 = max(e1t(end,:));
[e1q, ye1q] = calculate_verification_error(y0q, y1q, rq, s);
% error between reference and current simu
[e2t(:,1), ye2t(:,1)] = calculate_verification_error(y0t(:,1), y2t(:,1), rt, s);
[e2t(:,2), ye2t(:,2)] = calculate_verification_error(y0t(:,2), y2t(:,2), rt, s);
E2 = max(e2t(end,:));
[e2q, ye2q] = calculate_verification_error(y0q, y2q, rq, s);
E2Q = max(e2q(end,:));
% error between initial and current simu
[e3t(:,1), ye3t(:,1)] = calculate_verification_error(y1t(:,1), y2t(:,1), rt, s);
[e3t(:,2), ye3t(:,2)] = calculate_verification_error(y1t(:,2), y2t(:,2), rt, s);
E3 = max(e3t(end,:));
[e3q, ye3q] = calculate_verification_error(y1q, y2q, rq, s);
E3Q = max(e3q(end,:));

% ------------- decide if verification is ok --------------------------------
% ------ check the temperature results first ------------
if E2 > max_error
    v = false;
    s = sprintf('validate temperature %s with reference FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, E2, max_error);
    show = true;
elseif E3 > max_simu_error
    v = false;
    s = sprintf('validate temperature %s with 1st calculation FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, E3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('temperature %s OK: error %3.3g K, allowed %3.3g K', functionnamedisp, E2, max_error);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(E1)])
    sx = 'Outlet postion';                       % x-axis label
    st = 'verification storage heat exchanger model';       % title
    sy1 = 'Temperature in °C';              % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0t, y1t, y2t], [ye1t,ye2t,ye3t], st, sx, sy1, sleg1, sy2, sleg2, s)
end

% ------ now check the power results ------------
if E2Q > max_rerror
    v = false;
    s = sprintf('validate power %s with reference FAILED: error %3.3g > allowed error %3.3g', ...
        functionnamedisp, E2Q, max_rerror);
    show = true;
elseif E3Q > max_simu_error
    v = false;
    s = sprintf('validate power %s with 1st calculation FAILED: error %3.3g > allowed error %3.3g', ...
        functionnamedisp, E3Q, max_simu_error);
    show = true;
elseif v == true
    s = sprintf('power %s OK: error %1.3g %%, allowed %1.3g %%', functionnamedisp, E2Q*100, max_rerror*100);
end

%% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(max(e1q(end,:)))])
    sx = 'time in h';                       % x-axis label
    st = 'verification storage heat exchanger model';       % title
    sy1 = 'Power in W';              % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0q, y1q, y2q], [ye1q,ye2q,ye3q], st, sx, sy1, sleg1, sy2, sleg2, s)
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
%  $Revision$
%  $Author$
%  $Date$
%  $HeadURL$
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0     hf     created                                     15dec2014
%  6.1.1     hf     filename validate_ replaced by verify_      09jan2015
%  6.1.2     hf     close system without saving it              16may2016
%  6.2.0     hf     added save_sim_ref as 2nd input argument    11oct2017
%  6.2.1    hf      comments adapted to publish function        01nov2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
