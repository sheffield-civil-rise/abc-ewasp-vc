%% verify_Pressuredrop - verification of the Pressuredrop block in Carnot
%% Function Call
%  [v, s] = verify_Pressuredrop(varargin)
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
%  Validation of the Pressuredrop block in the Carnot Toolbox by comparing
%  the simulation results with the initial simulation and the result of the
%  equations calculated by this function.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_Pressuredrop(varargin)
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
    error('verify_Pressuredrop:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here ---------
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;        % max error between simulation and reference
max_simu_error = 1e-7;   % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_Pressuredrop_mdl';
t0 = 0:10:100;

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
y2 = yt.data;
close_system(functionname, 0)  % close system, but do not save it

%% ---------------- set the reference values ------------------------------
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Pressuredrop.mat','y1');
else
    y1 = importdata('simRef_Pressuredrop.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
mdot = y2(:,1);
p0 = 1e5;
E = ones(size(mdot));
c0 = 1*E;
l0 = 2*E;
q0 = 3*E;
c = 101*E;
l = 202*E;
q = 303*E;
dp = c + l.*mdot + q.*mdot.^2;
y0 = [mdot, p0-dp, c0+c, l0+l, q0+q, dp]; 
    
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
    sx = 'mdot';                            % x-axis label
    
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_P     = [y0(:,2), y1(:,2), y2(:,2)];
    y_clq   = [y0(:,3:5), y1(:,3:5), y2(:,3:5)];
    y_dp    = [y0(:,6), y1(:,6), y2(:,6)];
    
    %   x - vector with x values for the plot
    x = y2(:,1);
    
    %   ye - matrix with error values for each y-value
    ye_P     = [ye1(:,2), ye2(:,2), ye3(:,2)]; 
    ye_clq   = [ye1(:,3:5), ye2(:,3:5), ye3(:,3:5)]; 
    ye_dp    = [ye1(:,6), ye2(:,6), ye3(:,6)]; 
    
    sz = strrep(s,'_',' ');
    
% ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % Pressure plots
    subplot(2,3,1)      % divide in subplots (lower and upper one)
    if size(y_P,2) == 3
        plot(x,y_P(:,1),'x',x,y_P(:,2),'o',x,y_P(:,3),'-')
    else
        plot(x,y_P,'-')
    end
    title(st)
    ylabel('Pressure in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,4)      % choose lower window
    if size(ye_P,2) == 3
        plot(x,ye_P(:,1),'x',x,ye_P(:,2),'o',x,ye_P(:,3),'-')
    else
        plot(x,ye_P,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in Pa')
    
    % clq plots
    subplot(2,3,2)      % divide in subplots (lower and upper one)
    if size(y_clq,2) == 3
        plot(x,y_clq(:,1),'x',x,y_clq(:,2),'o',x,y_clq(:,3),'-')
    else
        plot(x,y_clq,'-')
    end
    title(st)
    ylabel('Constant in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,5)      % choose lower window
    if size(ye_clq,2) == 3
        plot(x,ye_clq(:,1),'x',x,ye_clq(:,2),'o',x,ye_clq(:,3),'-')
    else
        plot(x,ye_clq,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference')
    
    % pressure drop plots
    subplot(2,3,3)      % divide in subplots (lower and upper one)
    if size(y_dp,2) == 3
        plot(x,y_dp(:,1),'x',x,y_dp(:,2),'o',x,y_dp(:,3),'-')
    else
        plot(x,y_dp,'-')
    end
    title(st)
    ylabel('Pressure in Pa')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,6)      % choose lower window
    if size(ye_dp,2) == 3
        plot(x,ye_dp(:,1),'x',x,ye_dp(:,2),'o',x,ye_dp(:,3),'-')
    else
        plot(x,ye_dp,'-')
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
%  6.2.0    hf      added validation equations in this function 11feb2018
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
