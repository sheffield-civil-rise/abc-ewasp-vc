% Format of the THB - Thermo-Hydraulic-Bus
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/carnot_library_tools/Buses/src_m/THB_format.m $
% No.   name                physical_unit  remarks 
% 1     ID                  none           identifier, set by the simulation
% 2     Temperature         °C 
% 3     Massflow            kg/s
% 4     Pressure            Pa              absolute pressure, not gauge pressure
% 5     FluidType           none            identifier for the fluid, see manual
% 6     FluidMix            see fluids      mixture of 2nd fluid component
% 7     FluidMix2           see fluids      mixture of 3rd fluid component
% 8     FluidMix3           see fluids      mixture of 4th fluid component
% 9     DiameterLastPiece   m               diameter of last piece for pressure drop calculation
% 10    DPConstant          Pa              constant coefficient of pressure drop 
% 11    DPLinear            Pa/(kg/s)       linear coefficient of pressure drop 
% 12    DPQuadratic         Pa/(kg/s)²      quadratic coefficient of pressure drop 
% 13    HydraulicInductance 1/m
% 14    GeodeticHeight      m               height difference between inlet and outlet of a component