%% calculates the temperature [�C] as a function of enthalpy using Carlib 
%% Function Call
%  t = enthalpy2temperature(h, p, ft, fm)
%% Inputs   
%  (scalar or vector)
%  h    : enthalpy in J/kg
%  p    :   pressure [Pa]  
%  ft   :   fluid_ID (see link to FluidEnum below)
%  fm   :   fluid_mix 
%% Outputs
%  t    :   temperature [�C] 
% 
%% Description
%  The function calls the function "enthalpy2temperature" in the CARNOT library Carlib.
%  The Carlib function is also used by the "enthalpy2temperature"-block in CARNOT library.
% 
%% References and Literature
%  Function is used by: Carnot blocks in basic/material_properties
%  See also Carnot_Fluid_Types, FluidEnum, Carlib, 
%   density, enthalpy, entropy, heat_capacity,  
%   kinematic_viscosity, saturationtemperature, specific_volume, 
%   temperature_conductivity, thermal_conductivity, vapourpressure  

function t = enthalpy2temperature(h, p, ft, fm)
if (nargin ~= 4)
  help enthalpy2temperature
  error('4 input arguments required: enthalpy2temperature(h,p,id,mix)')
end

t = fluidprop (h, p, ft, fm, 14); % see carlib.h for function type 14

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
%  **********************************************************************
%  D O C U M E N T A T I O N
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
%  Version  Author  Changes                                     Date
%  1.0.0    hf      created                                     1999
%  6.1.0    hf      updated help text and error handling        03oct2014
%  7.1.0    hf      updated comments for publish                12aug2020
% **********************************************************************
% $Revision$
% $Author$
% $Date$
% $HeadURL$
