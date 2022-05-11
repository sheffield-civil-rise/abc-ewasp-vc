%% verify_carlib: verification of carlib fluid properties in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_carlib(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%  save_sim_ref - optional flag to save new simulation reference
%         false : do not save a new reference simulation scenario
%         true  : save a new reference simulation scenario
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  verification of carlib fluid properties in the Carnot Toolbox
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock,
%  verification_carnot, verification_fluidproperty

function [v, s] = verify_carlib(varargin)
%% check input arguments
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
    error('verification_carlib:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% Fluids
WATER       = 1;
AIR         = 2; %#ok<NASGU>
COTOIL      = 3; %#ok<NASGU>
SILOIL      = 4; %#ok<NASGU>
WATERGLYCOL = 5; %#ok<NASGU>
TYFOCOR_LS  = 6; %#ok<NASGU>
WATER_CONSTANT = 7; %#ok<NASGU>
AIR_CONSTANT = 8;

property = {'density', 'heat_capacity', 'thermal_conductivity', ...
    'kinematic_viscosity', 'vapourpressure', 'enthalpy', 'entropy', ...
    'specific_volume', 'evaporation_enthalpy', 'saturationtemperature' ...
    'temperature_conductivity'};

% fluid type    WATER  AIR   COTOIL SILOIL WATERGLYCOL TYFOCOR_LS WATER_CONSTANT AIR_CONSTANT
max_error = [   6e-4,  1e-7, 4e-3,  0.13,  2e-2,       1e-3,      4e-6,          1e-7; ... % maximum error for density
                6e-3,  1e-7, 0.12,  0.1,   3e-2,       3e-3,      1e-3,          1e-7; ... % maximum error for heat_capacity
                2e-2,  1e-7, 1e-7,  7e-4,  1e-7,       2e-3,      2e-3,          1e-7; ... % maximum error for thermal_conductivity
                8e-3,  1e-7, 1e-7,  1e-7,  1e-7,       5e-2,      7e-4,          1e-7; ... % maximum error for kinematic_viscosity
                1100,  1e-7, 1e-7,  18e3,  1e-7,       6e4,       1e-7,          1e-7; ... % maximum error for vapourpressure
                1.1e3, 1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for enthalpy
                40,    1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for entropy
                1e-3,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      4e-6,          1e-7; ... % maximum error for specific volume
                8e-4,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for evaporation_enthalpy
                2e-2,  1e-7, 1e-7,  1.2,   1e-7,       1e-7,      4e-2,          1e-7; ... % maximum error for saturation_temperature
                2e-2,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-3,          1e-7; ... % maximum error for temperature_conductivity
            ]; 
error_type = {'relative', ...  % error evaluation type for density
              'relative', ...  % error evaluation type for heat_capacity
              'relative', ...  % error evaluation type for thermal_conductivity
              'relative', ...  % error evaluation type for kinematic_viscosity
              'absolute', ...  % error evaluation type for vapourpressure
              'absolute', ...  % error evaluation type for enthalpy
              'absolute', ...  % error evaluation type for entropy
              'relative', ...  % error evaluation type for specific volume
              'relative', ...  % error evaluation type for evaporation_enthalpy
              'absolute', ...  % error evaluation type for saturation_temperature
              'relative', ...  % error evaluation type for temperature_conductivity
            }; 
        
%% ---------- check fluid properties --------------------------------------
for fluid = WATER:AIR_CONSTANT
    for n = 1:length(property)
        [v, s] = verification_fluidproperty(fluid,show,property{n}, ...
            max_error(n,fluid),error_type{n},save_sim_ref);
        if ~v 
            return
        end
        disp(['    ' s])
    end
end


s = 'verification of CARLIB fluid property functions ok';

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
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
%  $Revision$
%  $Author$
%  $Date$
%  $HeadURL$
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:      aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  5.0.0    hf      created                                     20aug2013
%  6.1.0    hf      variable number of input arguments          02apr2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    hf      filename verify_ replaced by verification_  09jan2015
%  6.3.0    hf      added validation of FH Duesseldorf          12nov2016
%  6.4.0    hf      added save_sim_ref as input argument        01nov2017
%                   comments adapted to publish function        01nov2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
