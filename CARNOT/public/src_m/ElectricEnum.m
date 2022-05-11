classdef ElectricEnum < Simulink.IntEnumType
% $Revision: 81 $
% $Author: kefer $
% $Date: 2016-11-02 14:10:23 +0100 (Mi., 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/ElectricEnum.m $
	enumeration
		POWER(1)
        DC(2)
        AC_1P(3)
        AC_3P(4)        
    end
end