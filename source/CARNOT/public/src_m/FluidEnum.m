classdef FluidEnum < Simulink.IntEnumType
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/FluidEnum.m $
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