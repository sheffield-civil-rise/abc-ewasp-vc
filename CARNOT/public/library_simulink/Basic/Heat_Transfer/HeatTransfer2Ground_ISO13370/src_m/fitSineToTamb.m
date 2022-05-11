%% fitSineToTamb - fits a sine curve to Tamb for ISO 13370 ground model
%% Function Call
%  [Tampl, timeshift, Tmean] = fitSineToTamb(filename)
%% Inputs   
%  filename - [optional] filename of the weather data file

%% Outputs
%  Tampl     - amplitude of yearly ambient temperature change
%  timeshift - time of year of min Tamb in sec
%  Tmean     - average ambient outdoor temperature in °C
%% Description
%  Fit a sine curve to the annual ambient temperature curve. 
%  T(t) = Tavg - ampT * cos( 2*pi/(365*24*3600) * (t - tshift) )
% 
%% References and Literature
%  Function is used by: --
%  see also WDB_format.m


function [Tampl, timeshift, Tmean] = fitSineToTamb(varargin)
%% Main function fitSineToTamb
% check correct number of input arguments
if nargin == 1
    filename = varargin{1};
    if exist(filename, 'file')
        filterindex = 1;
    else 
        error('fitSineToTamb: file not existing')
    end
elseif nargin == 0
    [filename, ~, filterindex] = uigetfile({'*.mat','MAT-files (*.mat)'; ...
        '*.dat;*.csv','ASCII (*.dat, *.csv)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file', path_carnot('data'));
else
    error('fitSineToTamb: number of inputs must be 0 or 1')
end

if filterindex == 0
    return
end

% Load weather data file
wdata = importdata(filename);
y = wdata(:,7);              % ambient temperature is column 7
x = wdata(:,1);              % time is in cloumn 1
yu = max(y);
yl = min(y);
yr = (yu-yl);                % Range of ‘tamb’
ym = mean(y);                % Estimate offset
tshift = 15*24*3600;         % estimated timeshift
%  T(t) = Tavg - ampT * cos( 2*pi/(365*24*3600) * (t - tshift) )
fit = @(b,x)  -b(1).*(cos((2*pi/(365*24*3600)).*(x - b(2)))) + b(3);    % Function to fit
fcn = @(b) sum((fit(b,x) - y).^2);                                      % Least-Squares cost function
s = fminsearch(fcn, [yr; tshift; ym]);                                 % Minimise Least-Squares
xp = linspace(min(x),max(x));
figure
plot(x,y,'b',  xp,fit(s,xp), 'r')
grid

disp(['Amplitude ' num2str(s(1)) ' K'])
disp(['Timeshift ', num2str(s(2)) ' s'])
disp(['Tmean ', num2str(s(3))  ' °C'])

Tampl = s(1);
timeshift = s(2);
Tmean = s(3);

end     % end of function CarnotCallbacks_StorageConf

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2019, Solar-Institute Juelich of the FH Aachen.
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
%  author list:     hf -> Bernd Hafner
%                   aw -> Arnold Wohlfeil
%                   pk -> Patrick Kefer
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     04jan2019
%  7.2.1    pk      correction of help section                  09feb2022
% *************************************************************************
% $Revision: 455 $
% $Author: carnot-hafner $
% $Date: 2018-11-24 10:49:49 +0100 (Sa, 24 Nov 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/src_m/CarnotCallbacks_StorageConf.m $
% *************************************************************************
