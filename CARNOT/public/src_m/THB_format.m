%% Format of the THB - Thermo-Hydraulic-Bus in CARNOT
%  No.   name                physical_unit  remarks 
%  1     ID                  none           identifier, set by the simulation
%  2     Temperature         °C 
%  3     Massflow            kg/s
%  4     Pressure            Pa              absolute pressure, not gauge pressure
%  5     FluidType           none            identifier for the fluid, see manual
%  6     FluidMix            see fluids      mixture of 2nd fluid component
%  7     FluidMix2           see fluids      mixture of 3rd fluid component
%  8     FluidMix3           see fluids      mixture of 4th fluid component
%  9     DiameterLastPiece   m               diameter of last piece for pressure drop calculation
%  10    DPConstant          Pa              constant coefficient of pressure drop 
%  11    DPLinear            Pa/(kg/s)       linear coefficient of pressure drop 
%  12    DPQuadratic         Pa/(kg/s)²      quadratic coefficient of pressure drop 
%  13    HydraulicInductance 1/m
%  14    GeodeticHeight      m               height difference between inlet and outlet of a component

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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     jg -> Joachim Goettsche
%                   hf -> Bernd Hafner
%
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                         Date
%  6.1.0    jg      created                                         2014
%  7.1.0    hf      adapted to publish, include fluid mix for air   06jan2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
