%% Callback for Carint model Ice_Storage
%% Function Call
%  [h_ini, t_ini, ] = CarnotCallbacks_IceStorage(f_ice, h_ini, t_ini, )
%% Inputs   
%% Outputs
% 
%% Description
%  Callback of the ice storage model in 
%% References and Literature
%  Function is used by: Carnot block IceStorage
%  see also CarnotCallbacks_CONFblocks

function [h_ini, t_ini, A, B, dt, dw, ztilde, delta_grd, U_earth, A_earth, V_earth, UA_tank] = ...
    CarnotCallbacks_IceStorage(f_ice, t_ini, vol, h, z, dearth, cond_ground, rho_ground, cp_ground)

f_ice = min(1, max(0, f_ice));
h_ini = (1-f_ice)*335e3;
t_ini = max(0, t_ini);
if f_ice == 0 
    h_ini = h_ini + 4182*t_ini;
else
    t_ini = 0;
end
%Grundfläche [m^2]
A = vol/h;
% diameter ice storage [m] (storage is a vertical cylinder)
D_tank = 2*sqrt(A/pi);
%Umfang [m]
P = D_tank*pi;
%charakteristisches Bodenmass [m]
B = A/(0.5*P);
%Wärmewiderstand Boden & Wand [m^2*K/W]
Rbtot = 0.12/1.330;
Rwtot = 0.1/1.330;
%Wanddicke [m]
w = 0.1;
%wirksame Dicke Boden & Wand [m]
dt = w + cond_ground*Rbtot;
dw = cond_ground*Rwtot;
%abstand der mitte der wandfläche zur oberfläche [m]
ztilde = z-(0.5*h);
%anzahl stunden pro jahr
t0 = 8760;
%thermische eindringtiefe
delta_grd = sqrt((t0*3600*cond_ground)/(pi*rho_ground*cp_ground));

%U-Wert Erdschicht [W/m^2K]
U_earth = cond_ground/dearth;
%Oberfläche Erdschicht [m^2]
A_earth = ((D_tank+2*dearth)/2)^2*pi + (D_tank+2*dearth)*pi*(h+dearth);
%Volumen Erdschicht [m^3]
V_earth = ((D_tank+2*dearth)/2)^2*pi*(h+dearth) - (D_tank/2)^2*pi*h;
%U*A tank
UA_tank = (D_tank/2)^2*pi/(0.12/1.330) + D_tank*pi*h/(0.1/1.330);


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
%  VERSIONS
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      first publish version                       28feb2021
%  ************************************************************************
%  $Revision: 1 $
%  $Author: carnot-hafner $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/tutorial/templates/template_carnot_m_function.m $
