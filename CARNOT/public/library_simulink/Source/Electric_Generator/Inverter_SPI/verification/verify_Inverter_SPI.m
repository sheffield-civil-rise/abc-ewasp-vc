%% Function Call
%  [v, s] = verify_InverterSpi(varargin)
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
%  verification of the Inverter block in the Carnot Toolbox
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_InverterSpi(varargin)
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
    error('verify_Inverter:%s',' too many input arguments')
end

% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 1e-3;        % max error between simulation and reference
max_simu_error = 1e-3;   % max error between initial and current simu
max_error_soc = 1e-5;        % max error between simulation and reference
max_simu_error_soc = 2e-4;   % max error between initial and current simu
% ---------- set model file or function name ------------------------------
functionname = 'verify_Inverter_SPI_mdl';

% % reference time vector
load('InputData_verify.mat');
t0 = 0:tsim_end;

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
    save('simRef_Inverter_SPI.mat','y1');
else
    y1 = importdata('simRef_Inverter_SPI.mat');  % result from call at creation of function
end

load('PermodRef.mat');
y0 = [PermodRef.Ppvbs, PermodRef.Ppv2ac, PermodRef.Pbat2ac, PermodRef.Ppv2bat, PermodRef.SOC];
disp('verify_Inverter.m: using Original SPI Model Simulation data as reference data')

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

% !!! shift soc data: soc is always one step behind original model
% implemented real dead time instead of pseudo dead time
% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0(:,1:4), y1(:,1:4), r, s);
[e1_soc, ye1_soc] = calculate_verification_error(y0(1:end-1,5), y1(2:end,5), r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0(:,1:4), y2(:,1:4), r, s);    
[e2_soc, ye2_soc] = calculate_verification_error(y0(1:end-1,5), y2(2:end,5), r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1(:,1:4), y2(:,1:4), r, s);
[e3_soc, ye3_soc] = calculate_verification_error(y1(:,5), y2(:,5), r, s);
% ------------- decide if verification is ok ------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s: with reference FAILED: error %3.3g W> allowed error %3.3g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s: with 1st calculation FAILED: error %3.3g W > allowed error %3.3g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s: OK: error %3.3g W', functionname, e2);
end

if e2_soc > max_error_soc
    v = false;
    s = [s,' | ', sprintf('verification with reference FAILED: SOC-error %3.3g > allowed error %3.3g', ...
        e2_soc, max_error_soc)];
    show = true;
elseif e3_soc > max_simu_error_soc
    v = false;
    s = [s,' | ', sprintf('verification with 1st calculation FAILED: SOC-error %3.3g > allowed error %3.3g', ...
        e3_soc, max_simu_error_soc)];
    show = true;
else
    v = true;
    s = [s,' | ', sprintf(' OK: SOC-error %3.3g', e2_soc)];
end

