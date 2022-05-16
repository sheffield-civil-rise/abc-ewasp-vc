%% verify_Room_Node - verification of the Room_Node block in Carnot
%% Function Call
%  [v, s] = verify_Room_Node(varargin)
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
%  Validation of the Room_Node block in the Carnot Toolbox. By comparing
%  the current simulation with an initial simulation and a reference. The 
%  reference is the analytical solution of the node temperature.
%
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Room_Node(varargin)
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
    error('verify_Room_Node:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 0.05;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Room_Node_mdl';

% % reference time vector
dt = 1800;
t0 = 0:dt:24*3600;

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
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Room_Node.mat','y1');
else
    y1 = importdata('simRef_Room_Node.mat');  % result from call at creation of function
end

%% ----------------- set the literature reference values -------------------
% convective node
p0 = 1013e2;
T0 = 22;
Vair = 5*5*2.5;                 % node air volume
xH2O = rel_hum2x(T0,p0,50);
rho = density(T0,p0,2,xH2O);
cp = heat_capacity(T0,p0,2,xH2O);
Qdot = 10*[0, -ones(1,24), ones(1,24)]'; 
dTdt = Qdot./(rho*cp*Vair);     % W * s / (kg/m³ * J/kg/K * m³) 
dT = cumsum(dTdt*dt);
y0(:,1) = 22*ones(length(dT),1)+dT;

% radiative node
Qdot = 0.02*[0, -ones(1,24), ones(1,24)]'; 
dTdt = Qdot./100;               % power / timeconstant 
dT = cumsum(dTdt*dt);
y0(:,2) = 22*ones(length(dT),1)+dT;


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
    sx = 'Time in h';                       % x-axis label
    x = t0/3600;                            % x-vector with x values for the plot
    
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_Tc    = [y0(:,1), y1(:,1), y2(:,1)];
    y_Tr    = [y0(:,2), y1(:,2), y2(:,2)];
    
    %   ye - matrix with error values for each y-value
    ye_Tc   = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    ye_Tr   = [ye1(:,2), ye2(:,2), ye3(:,2)]; 

    % ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    sz = strrep(s,'_',' ');
    subplot(2,1,1)      % divide in subplots (lower and upper one)
    plot(x,y_Tc(:,1),'x',x,y_Tc(:,2),'o',x,y_Tc(:,3),'-')
    hold on
    plot(x,y_Tr(:,1),'x',x,y_Tr(:,2),'o',x,y_Tr(:,3),'-')
    hold off
    title(st)
    ylabel('Temperature in °C')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    subplot(2,1,2)      % choose lower window
    plot(x,ye_Tc(:,1),'x',x,ye_Tc(:,2),'o',x,ye_Tc(:,3),'-')
    hold on
    plot(x,ye_Tr(:,1),'x',x,ye_Tr(:,2),'o',x,ye_Tr(:,3),'-')
    hold off
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in °C')
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
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    ts      created                                     08aug2017
%  6.1.1    hf      comments adapted to publish function        01nov2017
%                   reference y1 does not overwrite y2
%  6.2.0    hf      reference is the analytical soultion for    15jan2018
%                   for the convective and radiative temperature
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
