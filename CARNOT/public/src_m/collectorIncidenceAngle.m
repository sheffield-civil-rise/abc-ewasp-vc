%% collectorIncidenceAngle - incidence angles on a solar collector
%% Function Call
%  [teta, tetalong, tetatrans] = 
%       collectorIncidenceAngle(zenith, azimuth, elevation, colazimuth)
%% Inputs
%   zenith      zenith angle of the sun in degree (0° .. 180°)
%               0° = vertical above ground
%               90° = at the horizon
%               > 90 ° = sun not visible
%   azimuth     azimuth angle of the sun in degree (-180°..+180°)
%               east negative, west positive
%   elevation   collector elevation (inclination angle) in degree
%               0 ° = flat on the ground
%               90 ° = vertical
%   colazimuth  azimuth angle of the collector (-180°..+180°)
%               east negative, west positive
%% Outputs
%  teta         incidence angle on the collector in degree
%               0°  : vertical
%               90° : parallel to the collector surface
%  tetalong     longitudinal incidence angle on the collector in degree
%               tube collectors: the longitudinal plane is parallel to a 
%               tube and vertical to the surface determined by all tubes
%               0°  : vertical
%               90° : parallel to the collector surface (in axis with the tube)
%  tetatrans    transversal incidence angle on the collector in degree
%               tube collectors: the transveral plane is vertical to a tube
%               0°  : vertical
%               90° : parallel to the collector surface
% 
%% Description
%  Literature: 
%   Duffie, Beckman: Solar Engineering of Thermal Processes, ed. 1988 and 2006         
%   https://en.wikipedia.org/wiki/Solar_azimuth_angle (access 26jan2020)
%   ISO 9806: solar thermal collectors, 2017
%             with remark of DrHf to S.Fischer on 26/01/2020
%   

function [teta,tetalong,tetatrans] = ...
    collectorIncidenceAngle(zenith, azimuth, elevation, colazimuth)
%% Parameters
Deg2Rad = single(pi/180);
Rad2Deg = single(180/pi);
elevrad = elevation*Deg2Rad;    % collector elevation in radian
zenrad = zenith*Deg2Rad;
gamarad = (azimuth-colazimuth)*Deg2Rad;
%% Initial values
teta = ones(size(zenith))*90;
tetalong = teta;
tetatrans = teta;
%% Calculations
inanglecos = cos(zenrad).*cos(elevrad) ...  % cosine of the incidence angle
    +sin(zenrad).*cos(gamarad).*sin(elevrad);
idx = inanglecos > 0.0;                     % cosine positive: angle < 90 °
inangle(idx) = acos(inanglecos(idx));
teta(idx) = inangle(idx)*Rad2Deg;           % incidence angle
tetalong(idx) = (atan(tan(zenrad(idx)).*cos(gamarad(idx)))-elevrad) ...
    *Rad2Deg;                               % longitudinal incidence angle
tetatrans(idx) = atan(sin(zenrad(idx)).*sin(gamarad(idx))./inanglecos(idx))...
    *Rad2Deg;                               % transversal incidence angle

%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2022, Solar-Institute Juelich of the FH Aachen.
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
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                     Date
% 7.1.0    hf      created                                     24apr2022
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
