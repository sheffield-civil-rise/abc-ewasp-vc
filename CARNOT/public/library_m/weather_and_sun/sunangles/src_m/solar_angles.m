%% solar_angles calculates the position angles of the sun
%
% syntax: [dec,elev,zen,azi,hh] = solar_angles(t,lat,long,long0);
% Input t     : time in s, January 1st 00:00:00 = 0 s, December 31st 24:00:00 = 365*24*3600 s
%		lat   : geographic latitude [-90,90], north positiv
%       long  : geographic longitude [-180,180], west positiv
%       long0 : longitude of timezone
% Output dec  : declination of the sun [-23.45 ° ... 23.45 °]
%        elev : elevation angle of the sun in degrees [-90 ... 90 °]
%               (angle between sun and horizon)
%        zen  : zenith of the sun in degrees  [0 ... 180 °]
%               (angle between the sun and the zenith)
%        azi  : azimuth of the sun in degrees  [-180 ° ... 180 °]
%        hh   : hourangle of the sun in degrees [-180 ° ... 180 °]
%               east negativ, west positiv, south = 0 °
%                             
% The function solar_angles calls the mex-file sunangles. 
% The mex-file is the interface to the CARNOT library "Carlib" where the 
% calculation is effectuated.
% The equation was taken from Duffie, Beckmann: Solar Engineering of
% Thermal Processes, 2006.                                              
% See also CARLIB, sunangles, solar_extraterrestrial, solar_declination

function [d,e,z,a,h] = solar_angles(t,lat,long,long0)
[d,e,z,a,h] = sunangles(t,lat,long,long0);
end % of function


%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2020, Solar-Institute Juelich of the FH Aachen.
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
% $Revision: 372 $
% $Author: carnot-wohlfeil $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/library_m/weather_and_sun/calcsolar/src_m/solar_declination.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                     Date
% 7.1.0    hf      created                                     26jan2020
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
