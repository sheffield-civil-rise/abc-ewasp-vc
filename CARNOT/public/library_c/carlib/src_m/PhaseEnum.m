%% Definition of the fluid properties of Carnot
% 		VAPOROUS(1)
%         LIQUID(2)
%         SOLID(3)
% see also carlib

classdef PhaseEnum < Simulink.IntEnumType
	enumeration
		VAPOROUS(1)
        LIQUID(2)
        SOLID(3)
    end
end

% $Revision$
% $Author$
% $Date$
% $HeadURL$
