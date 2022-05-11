classdef MessageLevelEnum < Simulink.IntEnumType
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/MessageLevelEnum.m $
	enumeration
		DEBUGLEVEL(1)
        INFOLEVEL(2)
        WARNINGLEVEL(3)
        ERRORLEVEL(4)
        FATALLEVEL(5)
        NOLEVEL(6)
    end
end