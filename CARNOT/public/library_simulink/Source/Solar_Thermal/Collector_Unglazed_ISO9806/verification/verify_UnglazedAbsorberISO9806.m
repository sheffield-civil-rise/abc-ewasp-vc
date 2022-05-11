%% Verification of the model Collector_Unglazed_ISO9806
%% Function Call
%  [v, s] = verify_UnglazedAbsorber12975conf(show, safe_simref)
%% Inputs
%   show - optional flag for display 
%          0 (default) : show results only if verification fails
%          1           : show results allways
%   safe_simref - optional flag to create new simulation reference
%          0 (default) : do not create new reference
%          1           : create new reference
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
% 
%% Description
%  verfification of the model Collector_Unglazed_EN12975
% 
%% References and Literature
%  Literature: EN 12975, ISO 9806
%  Function is used by: verification_carnot.m
%  Function uses: verify_UnglazedAbsorber12975conf_mdl.slx
%  See also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_UnglazedAbsorberISO9806(varargin)
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
    error('verify_UnglazedAbsorberISO9806:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.01;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_UnglazedAbsorberISO9806_mdl';
t0 = 1800:900:14*3600;


%%  -------------- simulate the model or call the function -----------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout');        % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout');        % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
u0 = yt.data(:,1);              % temperature difference as x-vector for the plot
y0 = yt.data(:,2);              % reference power values from fcn block (iso equation)
y2 = yt.data(:,3);              % power from model
y2(:,2) = yt.data(:,4);         % pressure drop from model
y0(:,2) = ones(size(u0))*200.3; % reference pressure drop from TUEV test report
close_system(functionname, 0)   % close system, but do not save it

%% set reference values initial simulation
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_CollectorUnglazedISO9806.mat','y1');
else
    y1 = importdata('simRef_CollectorUnglazedISO9806.mat');  % result from call at creation of function
end

%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
% r = 'absolute'; 
r = 'relative'; 
% s = 'max';
% s = 'sum';
s = 'mean';

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
    s = sprintf('verification %s with 1st calculation FAILED: error %3.5f > allowed error %3.5f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: realtive error %3.5f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    sz = strrep(s,'_',' ');
    disp(['Initial error = ', num2str(e1)])
    sx = 'Temperature difference in K';                         % x-axis label
    st = 'Simulink model unglazes absorber';   % title
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = reshape(u0,length(u0),1);

    %   y - matrix with y-values (reference values and result of the function call)
    sy1 = 'Power in W';                     % y-axis label in the upper plot
    sy2 = 'relative error';                     % y-axis label in the lower plot
    y = [y0(:,1), y1(:,1), y2(:,1)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)

    %   y - matrix with y-values (reference values and result of the function call)
    sy1 = 'Pressure drop in Pa';                     % y-axis label in the upper plot
    sy2 = 'relative error';                     % y-axis label in the lower plot
    y = [y0(:,2), y1(:,2), y2(:,2)]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,2), ye2(:,2), ye3(:,2)]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
end

%% Copyright and Versions
%  This file is part of the Viessmann extension of the CARNOT Blockset.
%  Copyright (c) 2016 - 2019, Viessmann Werke GmbH
%  All rights reserved.
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% 
%  author list:      hf -> Bernd Hafner (DrHf)
%
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
%  Version  Author  Changes                                     Date
%  7.1.0    drhf    created                                     11may2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
