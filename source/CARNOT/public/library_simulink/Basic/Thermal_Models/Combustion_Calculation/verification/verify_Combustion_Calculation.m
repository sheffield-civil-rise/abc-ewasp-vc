%% verification of the Combustion_Calculation block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_Combustion_Calculation(varargin)
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
%  verification of the Combustion_Calculation block in the Carnot Toolbox
%                                                                          
%  Literature: --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Combustion_Calculation(varargin)
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
    error('verify_Combustion_Calculation:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Combustion_Calculation_mdl';

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
y2 = simOut.get('yout');       % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout');        % get the whole time vector from simu
close_system(functionname, 0)  % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Combustion_Calculation.mat','y2');
else
    y1 = importdata('simRef_Combustion_Calculation.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = y1;
disp('verify_Combustion_Calculation.m: using simulation data as reference data')

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
    y_money     = [y0(:,7), y1(:,7), y2(:,7)];
    y_mdot_fuel = [y0(:,3), y1(:,3), y2(:,3)];
    y_mdot      = [y0(:,8), y1(:,8), y2(:,8), y0(:,9), y1(:,9), y2(:,9), y0(:,11), y1(:,11), y2(:,11), y0(:,12), y1(:,12), y2(:,12), y0(:,13), y1(:,13), y2(:,13)];
    
    %   x - vector with x values for the plot
    x = t;
    
    %   ye - matrix with error values for each y-value
    ye_money     = [ye1(:,7), ye2(:,7), ye3(:,7)]; 
    ye_mdot_fuel = [ye1(:,3), ye2(:,3), ye3(:,3)]; 
    ye_mdot      = [ye1(:,8), ye2(:,8), ye3(:,8), ye1(:,9), ye2(:,9), ye3(:,9), ye1(:,11), ye2(:,11), ye3(:,11), ye1(:,12), ye2(:,12), ye3(:,12), ye1(:,13), ye2(:,13), ye3(:,13)]; 
    
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % Money flow plots
    subplot(2,3,1)      % divide in subplots (lower and upper one)
    if size(y_money,2) == 3
        plot(x,y_money(:,1),'x',x,y_money(:,2),'o',x,y_money(:,3),'-')
    else
        plot(x,y_money,'-')
    end
    title(st)
    ylabel('')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,4)      % choose lower window
    if size(ye_money,2) == 3
        plot(x,ye_money(:,1),'x',x,ye_money(:,2),'o',x,ye_money(:,3),'-')
    else
        plot(x,ye_money,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference')
    
    % mdot fuel plots
    subplot(2,3,2)      % divide in subplots (lower and upper one)
    if size(y_mdot_fuel,2) == 3
        plot(x,y_mdot_fuel(:,1),'x',x,y_mdot_fuel(:,2),'o',x,y_mdot_fuel(:,3),'-')
    else
        plot(x,y_mdot_fuel,'-')
    end
    title(st)
    ylabel('mdot in Kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,5)      % choose lower window
    if size(ye_mdot_fuel,2) == 3
        plot(x,ye_mdot_fuel(:,1),'x',x,ye_mdot_fuel(:,2),'o',x,ye_mdot_fuel(:,3),'-')
    else
        plot(x,ye_mdot_fuel,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Kg/s')
    
    % other mdot plots
    subplot(2,3,3)      % divide in subplots (lower and upper one)
    if size(y_mdot,2) == 3
        plot(x,y_mdot(:,1),'x',x,y_mdot(:,2),'o',x,y_mdot(:,3),'-')
    elseif size(y_mdot,2) == 15
        plot(x,y_mdot(:,1),'x',x,y_mdot(:,2),'o',x,y_mdot(:,3),'-')
        hold on;
        plot(x,y_mdot(:,4),'x',x,y_mdot(:,5),'o',x,y_mdot(:,6),'-')
        hold on;
        plot(x,y_mdot(:,7),'x',x,y_mdot(:,8),'o',x,y_mdot(:,9),'-')
        hold on;
        plot(x,y_mdot(:,10),'x',x,y_mdot(:,11),'o',x,y_mdot(:,12),'-')
        hold on;
        plot(x,y_mdot(:,13),'x',x,y_mdot(:,14),'o',x,y_mdot(:,15),'-')
    else
        plot(x,y_mdot,'-')
    end
    title(st)
    ylabel('mdot in Kg/s')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,6)      % choose lower window
    if size(ye_mdot,2) == 3
        plot(x,ye_mdot(:,1),'x',x,ye_mdot(:,2),'o',x,ye_mdot(:,3),'-')
    elseif size(y_mdot,2) == 15
        plot(x,ye_mdot(:,1),'x',x,ye_mdot(:,2),'o',x,ye_mdot(:,3),'-')
        hold on;
        plot(x,ye_mdot(:,4),'x',x,ye_mdot(:,5),'o',x,ye_mdot(:,6),'-')
        hold on;
        plot(x,ye_mdot(:,7),'x',x,ye_mdot(:,8),'o',x,ye_mdot(:,9),'-')
        hold on;
        plot(x,ye_mdot(:,10),'x',x,ye_mdot(:,11),'o',x,ye_mdot(:,12),'-')
        hold on;
        plot(x,ye_mdot(:,13),'x',x,ye_mdot(:,14),'o',x,ye_mdot(:,15),'-')
    else
        plot(x,ye_mdot,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Kg/s')
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
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *