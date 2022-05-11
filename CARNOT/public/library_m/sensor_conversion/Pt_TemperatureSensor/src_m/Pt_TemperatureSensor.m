%% function Pt_TemperatureSensor calculates temperature or resistance of platin temperature sensors
%% Function Call
%  y = Pt_TemperatureSensor(x,R0,mode)
%% Inputs
%  x  : temperature in °C or resistance in Ohm
%  R0 : resistance in Ohm at 0 °C (= 100 for Pt100, 1000 for Pt1000)
%  mode : 'R'  : result is resistance in Ohm
%         'T'  : result is temperature in °C
%% Outputs
%  mode = 'R'
%   y : resistance in Ohm as a function of temperature
%  mode = 'T'
%   y : temperature in °C as a function of resistance
% 
%% Description
%  Calculation of the resistance or temperature of Pt platin temperature
%  sensors.
% 
%  For temperature t > 0 °C :
%  R(t) = R0 * (1 + A*t + B*t^2)
%  with (ITS-90)
%  A = 3.9083e-3 * 1/K
%  B = -5.775e-7 * 1/K^2
%  t : temperature in °C
%  R0 = 100 Ohm for Pt100, 1000 Ohm for Pt1000
% 
%  for temperature t < 0 °C :
%  R(t) = R0 · [1 + A*t + B*t^2 + C*(t - 100°C) · t^3)]
%  with (ITS-90)
%  C = -4.183e-12 1/K^4
%  t : temperature in °C
%  R0 = 100 Ohm for Pt100, 1000 Ohm for Pt1000
%  
%  DIN EN 60751 accuracy class A and class B
%  classe A :
%  dt = ±(0,15 + 0,002 · |t|)°C
%  class B :
%  dt = ±(0,3 + 0,005 · |t|)°C
% 
%  Temperature as a function of the resistance
%  For temperature t > 0 °C :
%  t = (-R0*A + sqrt(R0^2*A^2 - 4*R0*B*(R0-R(t)))/(2*R0*B)
% 
%% References and Literature
%  https://www.uni-kassel.de/maschinenbau/fileadmin/datas/fb15/ITE/SAT/SolarPraktikum/01_Temperaturmessung.pdf
%  (access: 08mar2021)
%  ITS-90: International Temperature Scale of 1990
%    https://www.bipm.org/utils/common/pdf/ITS-90/Guide_ITS-90_5_SPRT_2018.pdf
%    https://www.bipm.org/en/committees/cc/cct/guide-its90.html
%    (access: 08mar2021)

function y = Pt_TemperatureSensor(varargin)
%% select inputs
if nargin < 1
    error('Pt1000:temperature as input argument required')
elseif nargin < 2
    x = varargin{1};
    R0 = 1000;
    mode = 'R';
elseif nargin < 3
    x = varargin{1};
    R0 = varargin{2};
    mode = 'R';
else
    x = varargin{1};
    R0 = varargin{2};
    mode = varargin{3};
end

%% Calculations
% set platin constants
A = 3.9083e-3;      % 1/K
B = -5.775e-7;      % 1/K^2
C = -4.183e-12;     % 1/K^4

% calculate temperature or resistance
switch mode
    case 'R'                % resistance as a function of temperature
        y = x;              % just for preallocation
        % check definition limits 
        if x < -200
            warning('Pt_TemperatureSensor:not defined below -200 °C')
        elseif x > 850
            warning('Pt_TemperatureSensor:not defined above 850 °C')
        end
        for n = 1:length(x)
            if x(n) >= 0        % temperature ist 0 °C or higher
                % R(t) = R0 * (1 + A*t + B*t^2)
                y(n) = R0*(1+A*x(n) + B*x(n)^2);
            else                % temperature is below 0 °C
                % R(t) = R0 * [1 + A*t + B*t^2 + C*(t-100°C)*t^3)]
                y(n) = R0*(1 + A*x(n) + B*x(n)^2 + C*(x(n)-100).*x(n)^3);
            end
        end
    case 'T'                % temperature as a function of resistance
        y = x;              % just for preallocation
        % check definition limits 
        if x/R0 < 0.185
            warning('Pt_TemperatureSensor:not defined below 185 Ohm')
        elseif x/R0 > 3.905
            warning('Pt_TemperatureSensor:not defined above 3905 Ohm')
        end
        for n = 1:length(x)
            if x(n) >= R0          % resistance above R0 : temperature is 0 °C or higher
                %  t = (-R0*A + sqrt(R0^2*A^2 - 4*R0*B*(R0-R(t))))/(2*R0*B)
                y(n) = (-R0*A + sqrt(R0^2*A^2 - 4*R0*B*(R0-x(n))))/(2*R0*B);
            else                % temperature is below 0 °C
                % create a polynom for temperatures between -200 °C and 0 °C
                % t = -200:0;
                % r = Pt_TemperatureSensor(t,1000,'R');
                % p = polyfit(r/R0,t,3);
                % result of the fit is:
                p = [-5.86195131020781,25.1779022813779,222.762489707053,-242.090646534155];
                y(n) = polyval(p,x(n)/R0);    % evaluate for resistance x
            end
        end
end


%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2021, Solar-Institute Juelich of the FH Aachen.
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
%  $Revision: 372 $
%  $Author: carnot-wohlfeil $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/tutorial/templates/template_carnot_m_function.m $
%  ************************************************************************
%  VERSIONS
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     08mar2021
