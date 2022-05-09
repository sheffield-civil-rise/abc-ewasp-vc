%% verify_WeatherFromWorkspace - verification of the WeatherFromWorkspace block in Carnot
%% Function Call
%  [v, s] = verify_WeatherFromWorkspace(varargin)
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
%  verification of the WeatherFromWorkspace block in the Carnot Toolbox by
%  comparing the simulation resuls with the initial simulation and the
%  reference data which can be read directely in the file.
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_WeatherFromWorkspace(varargin)
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
    error('verify_WeatherFromWorkspace:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'WeatherFromWorkspace';
modelfile = 'verify_WeatherFromWorkspace_mdl';

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(modelfile)
verification_weather_file = importdata('verification_weather_file.mat');
mws = get_param(modelfile, 'ModelWorkspace');
mws.assignin('verification_weather_file', verification_weather_file)
simOut = sim(modelfile, 'SaveOutput','on','OutputSaveName','yout');
y2 = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
u0 = simOut.get('tout')/3600; % get the whole time vector from simusave_system(modelfile)
close_system(modelfile, 0)   % close system, but do not save it

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_WeatherFromWS.mat','y1');
else
    y1 = importdata('simRef_WeatherFromWS.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
y0 = verification_weather_file(:,3:4);
% reference result is zenith and azimuth angle in the file
evalin('base', 'clear verification_weather_file WDB')


%% -------- calculate the errors -------------------------------------------

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

% ------------- decide if validation is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('validating %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('validating %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('validating %s OK: error %3.3f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Time in h';                         % x-axis label
    st = 'Simulink block validation';   % title
    sy1 = 'Outputs';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = reshape(u0,length(u0),1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1, ye2, ye3]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
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
%  $Revision: 434 $
%  $Author: carnot-hafner $
%  $Date: 2018-07-24 21:12:32 +0200 (Di, 24 Jul 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Weather/Weather_from_Workspace/verification/verify_WeatherFromWorkspace.m $
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%                   mp -> Marcel Paasche
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     31aug2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    mp      rearrange model workspace                   14oct2014
%  6.2.2    hf      filename validate_ replaced by verify_      09jan2015
%  6.2.3    hf      close system without saving it              16may2016
%  6.2.4    hf      delete variable verification_weather_file   16oct2017
%  6.2.5    ts      handling of workspaces                      08aug2017
%  6.1.1    hf      comments adapted to publish function        09nov2017
%                   save_sim_ref as 2nd input parameter
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
