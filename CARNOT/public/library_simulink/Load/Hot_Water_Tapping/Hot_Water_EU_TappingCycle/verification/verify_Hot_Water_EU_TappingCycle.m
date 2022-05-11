%% verification of the Hot_Water_EU_Tapping_Cycle block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_Hot_Water_EU_TappingCycle(varargin)
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
%  Verification of the Hot_Water_EU_Tapping_Cycle block in the Carnot Toolbox
%  by comparing the tapped energy and tapped mass to the theoretical values
%  from the tapping profile and to the initial simulation.
                              
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Hot_Water_EU_TappingCycle(varargin)
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
    error('verify_Hot_Water_EU_TappingCycle:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 3e-3;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Hot_Water_EU_TappingCycle_mdl';

% % reference time vector
t0 = 0:1800:24*3600;

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
y2(:,1) = y2(:,1)./36e5;        % energies are compared in kWh
close_system(functionname, 0)   % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Hot_Water_EU_TappingCycle.mat','y1');
else
    y1 = importdata('simRef_Hot_Water_EU_TappingCycle.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = y1;
% tapping profile parameters
% Profile M      5.845 kWh
times =    [7.000 7.083 7.500 8.016 8.250 8.5   8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.25 21.5]*3600;
energies = [0.105 1.4   0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 1.4 ]*36e5;
dT_set =   [30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30  ];
% mdot   =   [3     6     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     3     6   ];
mtap = zeros(size(t0));
Qtap = mtap;
Tcw = 10;
cp = heat_capacity(0.5*dT_set+Tcw,1e5,1,0);
for n = 1:size(times,2)
    idx = logical(t0 > times(n));
    Qtap(idx) = Qtap(idx) + energies(n);
    mtap(idx) = mtap(idx) + energies(n)/(cp(n)*dT_set(n));
end
y0(:,1) = Qtap'./36e5;
y0(:,3) = mtap';


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
    sx = '';                                % x-axis label
    
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_Q      = [y0(:,1), y1(:,1), y2(:,1)];
    y_T_warm = [y0(:,2), y1(:,2), y2(:,2)];
    y_m_warm = [y0(:,3), y1(:,3), y2(:,3)];
    
    %   x - vector with x values for the plot
    x = t0/3600;
    
    %   ye - matrix with error values for each y-value
    ye_Q      = [ye1(:,1), ye2(:,1), ye3(:,1)]; 
    ye_T_warm = [ye1(:,2), ye2(:,2), ye3(:,2)]; 
    ye_m_warm = [ye1(:,3), ye2(:,3), ye3(:,3)]; 
   
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % temperature plots of the cold side
    subplot(2,3,1)      % divide in subplots (lower and upper one)
    if size(y_Q,2) == 3
        plot(x,y_Q(:,1),'x',x,y_Q(:,2),'o',x,y_Q(:,3),'-')
    else
        plot(x,y_Q,'-')
    end
    title(st)
    ylabel('Energy in kWh')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,4)      % choose lower window
    if size(ye_Q,2) == 3
        plot(x,ye_Q(:,1),'x',x,ye_Q(:,2),'o',x,ye_Q(:,3),'-')
    else
        plot(x,ye_Q,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in kWh')
    
    % temperature plots of the warm side
    subplot(2,3,2)      % divide in subplots (lower and upper one)
    if size(y_T_warm,2) == 3
        plot(x,y_T_warm(:,1),'x',x,y_T_warm(:,2),'o',x,y_T_warm(:,3),'-')
    else
        plot(x,y_T_warm,'-')
    end
    title(st)
    ylabel('temperature in �C')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,5)      % choose lower window
    if size(ye_T_warm,2) == 3
        plot(x,ye_T_warm(:,1),'x',x,ye_T_warm(:,2),'o',x,ye_T_warm(:,3),'-')
    else
        plot(x,ye_T_warm,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in K')
    
    % integrated massflow plots of the warm side
    subplot(2,3,3)      % divide in subplots (lower and upper one)
    if size(y_m_warm,2) == 3
        plot(x,y_m_warm(:,1),'x',x,y_m_warm(:,2),'o',x,y_m_warm(:,3),'-')
    else
        plot(x,y_m_warm,'-')
    end
    title(st)
    ylabel('tapped mass in kg')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,6)      % choose lower window
    if size(ye_m_warm,2) == 3
        plot(x,ye_m_warm(:,1),'x',x,ye_m_warm(:,2),'o',x,ye_m_warm(:,3),'-')
    else
        plot(x,ye_m_warm,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in kg')
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
%  6.2.0    hf      new comparison of energy, temperature       09oct2018
%                   and tapped mass (volume)
%  7.1.0    hf      y0 = theoretical values of energy and mass  26jan2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
