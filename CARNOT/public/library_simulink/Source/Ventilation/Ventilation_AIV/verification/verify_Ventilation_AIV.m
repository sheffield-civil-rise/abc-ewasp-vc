%% verify_Ventilation_AIV - verification of the Ventilation_AIV block in Carnot
%% Function Call
%  [v, s] = verify_Ventilation_AIV(varargin)
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
%  validation of the Ventilation_AIV block in the Carnot Toolbox by
%  comparing the current simulation with an initial simulation and
%  theoretical caluclation of the vector elements.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Ventilation_AIV(varargin)
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
    error('verify_Ventilation_AIV:%s',' too many input arguments')
end

%% specific model or function parameters
% ----- set error tolerances ----------------------------------------------
max_error = 6e-5;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Ventilation_AIV_mdl';

%% simulate the model or call the function
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout');        % get the whole output vector (one value per simulation timestep)
% tt = simOut.get('tout');        % get the whole time vector from simu
% tsy = timeseries(yy,tt);        % timeseries for the columns
% tx = resample(tsy,t0);          % resample with t0
% y2 = tx.data;
y2 = yy(end,:)';
close_system(functionname, 0)   % close system, but do not save it

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Ventilation_AIV.mat','y1');
else
    y1 = importdata('simRef_Ventilation_AIV.mat');  % result from call at creation of function
end

% -------- set the reference values (theoretical calculation) -------------
Tamb = 0;
Troom = 20;
xH2O_out = rel_hum2x(Tamb,1013e2,50);
xH2O_in = rel_hum2x(Troom,1013e2,50);
xCO2_out = 1.529*400/1e6;  % rho(CO2) / rho(air) * CO2norm
xCO2_in = 1.529*450/1e6;
rho_out = density(Tamb, 1013e2, 2, xH2O_out);
cp_out = heat_capacity(Tamb, 1013e2, 2, xH2O_out);
Vair = 5*5*2.5;
nair = 0.4/3600;
Vdot = Vair*nair;
mdot_air_out2in = rho_out*Vdot;
mdot_air_in2out = mdot_air_out2in;
D_mdot_air = mdot_air_out2in-mdot_air_in2out;
Qdot_air = mdot_air_out2in*cp_out*(Tamb-Troom);
Qdotc = Qdot_air;
D_mdot_H2O = mdot_air_out2in*(xH2O_out-xH2O_in);
D_mdot_CO2 = mdot_air_out2in*(xCO2_out-xCO2_in);
Qdot_sol = 0;
Qdot_eqip = 0;
Qdot_light = 0;
Qdot_pers = 0;
Qdot_heat = 0;
Qdotr = 0;
y0 = [Qdot_sol; Qdot_eqip; Qdot_light; Qdot_pers; Qdot_heat; Qdot_air; ...
    Qdotc; Qdotr; D_mdot_air; D_mdot_H2O; D_mdot_CO2; Vdot; Vdot];

%% -------- calculate the errors ------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r1 = 'absolute'; 
r2 = 'relative'; 
s = 'max';
% s = 'sum';
% s = 'mean';

% select which values have relative error and which ones have absolute
ae = [1:5, 8]; 
re = [6, 7, 9, 10, 11, 12, 13];

% error between reference and initial simu 
[e1(ae,1), ye1(ae,1)] = calculate_verification_error(y0(ae,1), y1(ae,1), r1, s);
[e1(re), ye1(re)] = calculate_verification_error(y0(re), y1(re), r2, s);
% error between reference and current simu
[e2(ae,1), ye2(ae,1)] = calculate_verification_error(y0(ae,1), y2(ae,1), r1, s);
[e2(re), ye2(re)] = calculate_verification_error(y0(re), y2(re), r2, s);
% error between initial and current simu
[e3(ae,1), ye3(ae,1)] = calculate_verification_error(y1(ae,1), y2(ae,1), r1, s);
[e3(re,1), ye3(re,1)] = calculate_verification_error(y1(re,1), y2(re,1), r2, s);

e1 = max(e1);
e2 = max(e2);
e3 = max(e3);


% ------------- decide if verification is ok ------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.2g > allowed error %3.2g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.2g > allowed error %3.2g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.2g', functionname, e2);
end

%% ------------ display and plot results if required ----------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    
    st = 'Simulink block verification';     % title
    sx = '';                                % x-axis label
    
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_Qdot  = [y0(:,1), y1(:,1), y2(:,1)];
    
    %   x - vector with x values for the plot
    x = 1:length(y2);
    
    %   ye - matrix with error values for each y-value
    ye_Qdot = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
   
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % power plots
    subplot(2,1,1)      % divide in subplots (lower and upper one)
    if size(y_Qdot,2) == 3
        plot(x,y_Qdot(:,1),'x',x,y_Qdot(:,2),'o',x,y_Qdot(:,3),'-')
    else
        plot(x,y_Qdot,'-')
    end
    title(st)
    ylabel('AIV values')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,1,2)      % choose lower window
    if size(ye_Qdot,2) == 3
        plot(x,ye_Qdot(:,1),'x',x,ye_Qdot(:,2),'o',x,ye_Qdot(:,3),'-')
    else
        plot(x,ye_Qdot,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference')
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_Ventilation_AIV.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    ts      created                                     08aug2017
%  6.1.1    hf      comments adapted to publish function        09nov2017
%                   reference y1 does not overwrite y2
%                   resample y2 with t0
%  6.2.0    hf      validation with theoretical values          21jan2018
%  7.1.0    hf      y0 with corrected values for D_mdot_air     22dec2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
