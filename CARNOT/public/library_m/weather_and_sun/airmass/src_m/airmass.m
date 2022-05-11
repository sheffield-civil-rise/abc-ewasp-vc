%% Calulates the airmass at a specific time and for a specific location.
%% Function Call
%  m = airmass(time, latitude, longitude, longitude0)
%% Inputs   
%   time          : second in the year (january, 1st, 0:00 = 0 s)
%   latitude      :   [-90,90],north positive
%   longitude     :   [-180,180],west positive
%   longitude0    :   reference longitude (timezone)
%% Outputs
%   m : airmass 
% 
%% Description
%  The airmass is 1/sin(solar_altitude) as long as the solar altitue  
%  is above 30 degrees. Otherwise the airmass is 
%  ((1229+(614*sin(solar_altitude)).^2).^(0.5)) - 614.*sin(solar_altitude)
% 
%% References and Literature
%  Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006

function m = airmass(time, latitude, longitude, longitude0)
if nargin ~= 4
   help airmass
   return
end
% start calculation
[~, alt, ~, ~, ~] = sunangles(time,latitude, longitude, longitude0);

altsin = sin(alt*pi/180);    % sine of altitude of the sun in radian

if alt >= 30 
   m = 1./altsin;
else
   m = sqrt(1229+(614.*altsin).^2) - 614.*altsin;
end

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2020, Solar-Institute Juelich of the FH Aachen.
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
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  1.0  hf      created                                         21jun2009
%  7.0  hf      adapted comments for publsih                    09aug2020
%               check for alt, nor for zen angle
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  ************************************************************************
%  $Revision$
%  $Author$
%  $Date$
%  $HeadURL$
