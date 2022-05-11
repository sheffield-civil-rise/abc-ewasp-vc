%% verify_Pressure_Drop_StoragePipe - verification of the Pressure_Drop_StoragePipe block in Carnot
%% Function Call
%  [v, s] = verify_Pressure_Drop_StoragePipe(varargin)
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
%  Verification of the Pressure_Drop_StoragePipe block in the Carnot Toolbox
%  by comparing the current simulation to the initial simulation and
%  reference values from literature.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Pressure_Drop_StoragePipe(varargin)
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
    error('verify_Pressure_Drop_StoragePipe:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu
t0 = 0:10;

% ---------- set model file or function name ------------------------------
functionname = 'verify_Pressure_Drop_StoragePipe_mdl';

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');

yy = simOut.get('yout');       % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout');       % get time
yt = timeseries(yy,tt);
yt = resample(yt,t0);
mdot = yt.data(:,1);
y2 = yt.data(:,2:end);

close_system(functionname, 0)  % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Pressure_Drop_StoragePipe.mat','y1');
else
    y1 = importdata('simRef_Pressure_Drop_StoragePipe.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = y2;   % initial values, reference values will be replaced later
% storage is connected with a pipe: 
%   1. flow sees a sudden increase of diameter : d -> inf
%   2. flow sees a sudden decrease of diameter : inf -> d
% sudden increase in diameter (A1 < A2)
%   for a flow from A1 to A2 
%   zeta = (1 - A1/A2)^2 = (1 - (d1/d2)^2)^2              
% sudden decrease in diameter (A1 < A2)
%   for a flow from A2 to A1 
%   zeta = 0.5 * (1 - A1/A2)^2 = 0.5 * (1 - (d1/d2)^2)^2 
% dp = zeta * density/2 * w^2 
% dp = c + l*mdot + q*mdot^2    Carnot approach (here c = l = 0)
% with mdot = Vdot*density = w*A*density  
% -> w = mdot/A/density
% dp = zeta * density/2 * mdot^2/A^2/density^2
% dp = zeta/(2*A^2*density) * mdot^2
% -> q = zeta/(2*A^2*density)
% diameter increase: 
%   q = (1 - A1/A2)^2/(2*A1^2*density)
%   q = (1/A1 - 1/A2)^2 / (2*density)
%   with A = pi/4*d^2
%   q = 8/density/pi^2 * (1/d1^2 - 1/d2^2)^2
% diameter decrease: 
%   q = 0.5*(1 - A1/A2)^2/(2*A1^2*density)
%   q = 0.5*(1/A1 - 1/A2)^2 / (2*density)
%   with A = pi/4*d^2
%   q = 4/density/pi^2 * (1/d1^2 - 1/d2^2)^2

% in this example 
d1 = 0.04;  % m
d2 = 1;     % m
h = 2.0;    % m       outlet above inlet
p0 = 2e5;   % Pa
A1 = pi/4*d1^2;
A2 = pi/4*d2^2;
rho = density(20,p0,1,0);
zeta_i = (1 - (d1/d2)^2)^2;         % diameter increase
q_i = (1/A1 - 1/A2)^2 / (2*rho);
q_d = 0.5*(1/A1 - 1/A2)^2 / (2*rho);
zeta_d = 0.5*(1 - (d1/d2)^2)^2;     % diameter decrease
w = mdot./A1./rho;
dp = (zeta_i + zeta_d)*rho/2*w.^2;
pstat = rho*9.81*h;
y0(:,1) = p0-dp;                    % pressure drop due to flowrate
y0(:,2) = p0-pstat-dp;              % pressure drop due to flow and static height
y0(:,3) = pstat;                    % constant coefficient (= static height)
y0(:,4) = 0;                        % linear coeff is zero
y0(:,5) = q_i+q_d;                  % quadratic coefficient

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
    y_Pfric      = [y0(:,1), y1(:,1), y2(:,1)];
    y_Ptot       = [y0(:,2), y1(:,2), y2(:,2)];
    y_DP_const   = [y0(:,3), y1(:,3), y2(:,3)];
    y_DP_Quadrat = [y0(:,5), y1(:,5), y2(:,5)];
    
    %   x - vector with x values for the plot
    x = t0;
    
    %   ye - matrix with error values for each y-value
    ye_Pfric      = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    ye_Ptot       = [ye1(:,2), ye2(:,2), ye3(:,2)]; 
    ye_DP_const   = [ye1(:,3), ye2(:,3), ye3(:,3)]; 
    ye_DP_Quadrat = [ye1(:,5), ye2(:,5), ye3(:,5)];
    
    if max(ye3 ~= 0)
        warning('Linear coefficient must be zero. This is not the case in the current simulation.')
    end
    
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % Pressure plots
    subplot(2,4,1)      % divide in subplots (lower and upper one)
    if size(y_Pfric,2) == 3
        plot(x,y_Pfric(:,1),'x',x,y_Pfric(:,2),'o',x,y_Pfric(:,3),'-')
    else
        plot(x,y_Pfric,'-')
    end
    title(st)
    ylabel('Pressure drop in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,4,5)      % choose lower window
    if size(ye_Pfric,2) == 3
        plot(x,ye_Pfric(:,1),'x',x,ye_Pfric(:,2),'o',x,ye_Pfric(:,3),'-')
    else
        plot(x,ye_Pfric,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    % pressure plots with static height
    subplot(2,4,2)      % divide in subplots (lower and upper one)
    if size(y_Ptot,2) == 3
        plot(x,y_Ptot(:,1),'x',x,y_Ptot(:,2),'o',x,y_Ptot(:,3),'-')
    else
        plot(x,y_Ptot,'-')
    end
    title(st)
    ylabel('Pressure drop in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,4,6)      % choose lower window
    if size(ye_Ptot,2) == 3
        plot(x,ye_Ptot(:,1),'x',x,ye_Ptot(:,2),'o',x,ye_Ptot(:,3),'-')
    else
        plot(x,ye_Ptot,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    % Const pressure plots
    subplot(2,4,3)      % divide in subplots (lower and upper one)
    if size(y_DP_const,2) == 3
        plot(x,y_DP_const(:,1),'x',x,y_DP_const(:,2),'o',x,y_DP_const(:,3),'-')
    else
        plot(x,y_DP_const,'-')
    end
    title(st)
    ylabel('Constant coeff')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,4,7)      % choose lower window
    if size(ye_DP_const,2) == 3
        plot(x,ye_DP_const(:,1),'x',x,ye_DP_const(:,2),'o',x,ye_DP_const(:,3),'-')
    else
        plot(x,ye_DP_const,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    % Quadratic pressure plots
    subplot(2,4,4)      % divide in subplots (lower and upper one)
    if size(y_DP_Quadrat,2) == 3
        plot(x,y_DP_Quadrat(:,1),'x',x,y_DP_Quadrat(:,2),'o',x,y_DP_Quadrat(:,3),'-')
    else
        plot(x,y_DP_Quadrat,'-')
    end
    title(st)
    ylabel('Quadratic coeff')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,4,8)      % choose lower window
    if size(ye_DP_Quadrat,2) == 3
        plot(x,ye_DP_Quadrat(:,1),'x',x,ye_DP_Quadrat(:,2),'o',x,ye_DP_Quadrat(:,3),'-')
    else
        plot(x,ye_DP_Quadrat,'-')
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
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    ts      created                                     19jul2017
%  6.1.1    hf      comments adapted to publish function        01nov2017
%                   reference y1 does not overwrite y2
%  7.1.0    hf      added theoretical values as reference       10feb2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
