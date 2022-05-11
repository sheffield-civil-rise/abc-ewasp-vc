ts = 30 * pi/180; % sun zenith angle
azs =  -0.01 * pi/180; % Sun azimuth, South=0, West positive

sun=[sin(ts)*cos(azs) -sin(ts)*sin(azs) cos(ts)]; % x South, y East, z Up

beta_c= 0 * pi/180; % second axis of rot. around rotated y axis
az_c = 90 * pi/180; % first axis of rot. around vertical (East neg.)
rot_c = -30 * pi/180; % third axis of rot. around tilted x axis

R_az = [cos(az_c) -sin(az_c) 0,
        sin(az_c) cos(az_c) 0,
        0   0   1];
R_beta = [cos(beta_c) 0 -sin(beta_c),
          0 1 0,
          sin(beta_c) 0 cos(beta_c)];
R_rot = [1 0 0,
         0 cos(rot_c) sin(rot_c),
         0 -sin(rot_c) cos(rot_c)];

sun_1 = R_az*sun';
sun_2 = R_beta*sun_1;
sun_3 = R_rot*sun_2;

az_new=180/pi*atan(sun_3(1)/sun_3(2))% sun azimuth on rotated coord. system
teta_new= 180/pi*acos(sun_3(3)) % sun zenith on rotated coord. system
long_new=-180/pi*atan(sun_3(1)/sun_3(3)) % projection of teta_new on x-z plane
trans_new=-180/pi*atan(sun_3(2)/sun_3(3)) % projection of teta_new on y-z plane

% Plot-Versuch
figure(1);
A=[zero;sun];
B=[zero;sun_1'];
C=[zero;sun_2'];
D=[zero;sun_3'];

plot3(A(:,1), A(:,2), A(:,3));
hold on
plot3(B(:,1), B(:,2), B(:,3));
plot3(C(:,1), C(:,2), C(:,3));
plot3(D(:,1), D(:,2), D(:,3));

hold off;
grid on;
xlabel('x');
ylabel('y');

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
%  $Revision: 652 $
%  $Author: carnot-hafner $
%  $Date: 2019-12-10 21:42:59 +0100 (Di, 10 Dez 2019) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/library_simulink/Weather/Radiation_on_Inclined_Surface/verification/verify_RadiationInclinedSurface.m $
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   jg -> Joachim Goettsche
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    jg      created                                     01nov2019
%  6.2.0    hf      added copyright                             01jan2020
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
