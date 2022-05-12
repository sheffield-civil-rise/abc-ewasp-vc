%% verification for the AddSolarPosition block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_AddSolarPosition(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%  save_sim_ref
%         false : do not save a new reference simulation scenario
%         true  : save a new reference simulation scenario
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  verification for the AddSolarPosition block in the Carnot Toolbox.
%                                                                          
% Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006
%  see also template_verify_mFunction, verification_carnot

function [v, s] = verify_AddSolarPosition(varargin)
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
    error('verify_AddSolarPosition:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.5;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functin name -------------------------------
functionname = 'AddSolarPosition';
modelfile = 'verify_AddSolarPosition_mdl';

% ----------------- set the literature reference values -------------------
lat = 45;                % reference input values for latitude
lst = 0;                % reference meridian
local = 0;              % local meridian
n = 1;                  % day 1

standardtime = 0:24;
latirad = lat*pi/180;
b = ((n-81)*360/364)*pi/180;
E = (9.87*sin(2*b)-7.53*cos(b)-1.5*sin(b))/60;
solartime = standardtime+E+(lst-local)/15;
del = 23.45*sin((360*(n+284)/365)*pi/180);
delrad = del*pi/180;
wdegree = (solartime-12)*15;
wrad = wdegree*(pi/180);
zenrad = acos(sin(delrad)*sin(latirad)+cos(delrad)*cos(latirad)*cos(wrad));
zenith = zenrad*(180/pi);
azimuth = sign(wrad).*(180/pi).*acos((sin(latirad)*cos(zenrad)-sin(delrad))./ ...
    (cos(latirad)*sin(zenrad)));
azimuth(25)=azimuth(1);  % at midnight, azimut is same as at 0 h

y0 = [zenith', azimuth'];             % reference results

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
y2 = zeros(25,2,length(lat));
load_system(modelfile)
for n = 1:length(lat)
    % maskStr = get_param([gcs, '/Constant'],'DialogParameters');
    set_param([gcs, '/Add_Solar_Position'], 'lati', num2str(lat(n)));
    set_param([gcs, '/Add_Solar_Position'], 'longi', '0');
    set_param([gcs, '/Add_Solar_Position'], 'timezone', '0');
    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
    y2(:,:,n) = xx;
end
u0 = simOut.get('tout')/3600;
close_system(modelfile, 0)   % close system, but do not save it

%% set reference values initial simulation ---------------
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_AddSolarPosition.mat','y1');
else
    y1 = importdata('simRef_AddSolarPosition.mat');  % result from call at creation of function
end


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

% ------------- decide if verification is ok --------------------------------
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

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Time in h';                       % x-axis label
    st = 'Simulink block verification';       % title
    sy1 = 'Angles in °';                    % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data zenith','reference data azimut', ...
        'initial simulation zenith', 'initial simulation azimut', ...
        'current simulation zenith', 'current simulation azimut'};
    % lower legend
    sleg2 = {'ref. vs initial simu zenith', 'ref. vs initial simu azimut', ...
        'ref. vs current simu zenith', 'ref. vs current simu azimut',...
        'initial simu vs current zenith', 'initial simu vs current azimut'};
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
%  $Revision: 372 $
%  $Author: carnot-wohlfeil $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Weather/Add_Solar_Position/verification/verify_AddSolarPosition.m $
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version   Author  Changes                                     Date
%  6.1.0     hf      created                                     03jun2014
%  6.2.0     hf      return argument is [v, s]                   03oct2014
%  6.2.1     hf      filename validate_ replaced by verify_      09jan2015
%  6.2.2     hf      close system without saving it              16may2016
%  6.3.1     hf      comments adapted to publish function        01nov2017
%                    added parameter save_sim_ref
