% verify_Pt_TemperatureSensor verifies the function Pt_TemperatureSensor
%% Description
%  [v, s] = verify_Pt_TemperatureSensor([show], [save_sim_ref])
%  Verification of the function Pt_TemperatureSensor by comparing the
%  calculation with reference results and initialc calculation 
%  of temperatures and resistances of Pt-100 and Pt-1000 sensors.
%  Inputs:  show - optional flag for display 
%               false : show results only if verification fails
%               true  : show results allways
%           save_sim_ref
%               false : do not save a new reference simulation scenario
%               true  : save a new reference simulation scenario
%  Outputs: v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
%  Literature:  https://www.pentronic.se/wp-content/uploads/2019/04/table-pt100-2019.pdf - Source refers to IEC 60751:
% see also --


function [v, s] = verify_Pt_TemperatureSensor(varargin)
%% check input arguments ----------------------------------------------
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
    error('template_verify_mFunction:%s',' too many input arguments')
end

%% set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.01;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

%% set model file or function name ------------------------------
functionname = 'Pt_TemperatureSensor';

%% set the literature reference values -------------------
% Source referes to IEC 60751:
% https://www.pentronic.se/wp-content/uploads/2019/04/table-pt100-2019.pdf 
rawData =[-200 18.520 210 179.528 620 320.116 ...
-190 22.825 220 183.188 630 323.302 ...
-180 27.096 230 186.836 640 326.477 ...
-170 31.335 240 190.473 650 329.640 ...
-160 35.543 250 194.098 660 332.792 ...
-150 39.723 260 197.712 670 335.932 ...
-140 43.876 270 201.314 680 339.061 ...
-130 48.005 280 204.905 690 342.178 ...
-120 52.110 290 208.484 700 345.284 ...
-110 56.193 300 212.052 710 348.378 ...
-100 60.256 310 215.608 720 351.460 ...
-90 64.300 320 219.152 730 354.531 ...
-80 68.325 330 222.685 740 357.590 ...
-70 72.335 340 226.206 750 360.638 ...
-60 76.328 350 229.716 760 363.674 ...
-50 80.306 360 233.214 770 366.699 ...
-40 84.271 370 236.701 780 369.712 ...
-30 88.222 380 240.176 790 372.714 ...
-20 92.160 390 243.640 800 375.704 ...
-10 96.086 400 247.092 810 378.683 ...
0 100.000 410 250.533 820 381.650 ...
10 103.903 420 253.962 830 384.605 ...
20 107.794 430 257.379 840 387.549 ...
30 111.673 440 260.785 850 390.481 ...
40 115.541 450 264.179 ...
50 119.397 460 267.562 ...
60 123.242 470 270.933 ...
70 127.075 480 274.293 ...
80 130.897 490 277.641 ...
90 134.707 500 280.978 ...
100 138.506 510 284.303 ...
110 142.293 520 287.616 ...
120 146.068 530 290.918 ...
130 149.832 540 294.208 ...
140 153.584 550 297.487 ...
150 157.325 560 300.754 ...
160 161.054 570 304.010 ...
170 164.772 580 307.254 ...
180 168.478 590 310.487 ...
190 172.173 600 313.708 ...
200 175.856 610 316.918];%reference values are for pt100
% y0 = [R, T];
y0(:,1) = rawData(2:2:end);% resistance
y0(:,2) = rawData(1:2:end);%temperature
y0 = sortrows(y0,2);
T = y0(:,2);
R = y0(:,1);
R0 = 100;
% old reference values
% T = [-200   -100   -50    0    20      50      100     200     400     850]';     % temperatures
% R = [185.20 602.56 803.06 1000 1077.94 1193.97 1385.06 1758.56 2470.92 3904.81]'; % resistance
% y0 = [R, T];

%%  simulate the model or call the function -----------------
y2(:,1) = Pt_TemperatureSensor(T,R0,'R'); % calculate resistance
y2(:,2) = Pt_TemperatureSensor(R,R0,'T'); % calculate temperature

%% set reference values initial simulation ---------------
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_Pt_TemperatureSensor.mat','y1');
else
    y1 = importdata('simRef_Pt_TemperatureSensor.mat');  % result from call at creation of function
end

%% calculate the errors -------------------------------------------
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
    s = sprintf('verification %s with reference FAILED: error %3.5g > allowed error %3.5g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.5g > allowed error %3.5g', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.5g', functionname, e2);
end

%% diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'temperature in °C';                   % x-axis label
    st = 'm-Function verification';             % title
    sy1 = 'resistance in Ohm';                  % y-axis label in the upper plot
    if strcmp(r,'relative')                     % y-axis label in the lower plot
        sy2 = 'relative error';         
    elseif strcmp(r,'absolute')
        sy2 = 'absolute error';
    else
        sy2 = 'Difference';
    end
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %% fist part: resistance is a result of the temperature
    %   x - vector with x values for the plot
    x = T;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,1), y1(:,1), y2(:,1)];
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,1), ye2(:,1), ye3(:,1)];
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
    %% second part: temperature is a result of the resistance
    sx = 'resistance in Ohm';                   % x-axis label
    sy1 = 'temperature in °C';                  % y-axis label in the upper plot
    %   x - vector with x values for the plot
    x = R;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,2), y1(:,2), y2(:,2)];
    %   ye - matrix with error values for each y-value
    ye = [ye1(:,2), ye2(:,2), ye3(:,2)];
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
end

%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
% 
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     29may2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.2.2     hf      comments corrected                          18sep2015
% 6.2.3     hf      added resampling of timeseries              27nov2015
% 6.2.4     hf      close system without saving it              16may2016
% 6.3.0     hf      added save_sim_ref as 2nd input argument    10oct2017
% 7.1.0  	hf      replaced print format 3.5f by 3.5g			11jun2020
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
