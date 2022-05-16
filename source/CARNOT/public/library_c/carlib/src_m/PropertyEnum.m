classdef PropertyEnum < Simulink.IntEnumType
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_c/carlib/src_m/PropertyEnum.m $
	enumeration
		DENSITY(1)
		HEAT_CAPACITY(2)
		THERMAL_CONDUCTIVITY(3)
		VISCOSITY(4)
		ENTHALPY(5)
		ENTROPY(6)
		PRANDTL(7)
		SPECIFIC_VOLUME(8)
		EVAPORATION_ENTHALPY(9)
		VAPOURPRESSURE(10)
		SATURATIONTEMPERATURE(11)
		SATURATIONPROPERTY(12)
		TEMPERATURE_CONDUCTIVITY(13)
		ENTHALPY2TEMPERATURE(14)
		GRASHOFNUMBER(15)
		PRANDTLNUMBER(16)
		VAPOURCONTENT(17)
    end
end