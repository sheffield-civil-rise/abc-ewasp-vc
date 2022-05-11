%% Definition of the fluid types enumeration of Carnot
%  ID  FLUID           REMARKS
%  1   water/steam --- fluid_mix is the vapourcontent in the 2-phase region
%                      liquid water: temperature range  0°C to 374.15°C
%                      pressure range: pressure dependance is not considered
%                      steam:        temperature range 0°C to 800 °C
%                      pressure range: 600 Pa to 45 MPa
%  2   air ----------- fluid_mix is (kg water) / (kg air)
%                      temperature range: -150°C to 1000°C
%                      pressure range: ideal gas assumption
%  3   cotton oil ---- temperature range:    0°C to 320°C
%                      pressure range: pressure dependance is not considered
%  4   silicone oil -- temperature range: - 50°C to 400°C
%                      pressure range: pressure dependance is not considered
%  5   water-glycol -- fluid_mix gives the volume-fraction of propylen glycol
%                      temperature range: - 20°C to 200°C
%                      pressure range: pressure dependance is not considered
%  6   Tyfocor LS ---- water-propylenglycol mixture with 42% of glycol
%                      temperature range : -30°C to 120°C
%                      pressure range: pressure dependance is not considered
%  7   Water Constant- pressure and temperature independant property for 
%                      liquid water at 20°C
%  8   Air Constant -- pressure and temperature independant property for 
%                      dry air at 20°C
%  see also carlib, 

classdef FluidEnum < Simulink.IntEnumType
	enumeration
		WATER(1)
        AIR(2)
        COTOIL(3)
        SILOIL(4)
        WATERGLYCOL(5)
        TYFOCOR_LS(6)
		WATER_CONSTANT(7)
		AIR_CONSTANT(8)
    end
end


% $Revision$
% $Author$
% $Date$
% $HeadURL$
