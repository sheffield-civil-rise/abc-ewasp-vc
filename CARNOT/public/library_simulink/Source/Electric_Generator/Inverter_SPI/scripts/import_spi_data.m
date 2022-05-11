%% convert structure used by official SPI Model
%% Function Call
%  [names,values] = import_spi_data(s) 
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%  bhandle - block handle (result of matlab function gcbh)
%% Outputs
%  names     - cell array of fieldnames fro convenience
%  values    - array of values used by model
% 
%% Description
% convert structure "s" used by official SPI Model to array used by carnot model
% The struct with can be taken from the original SPI tool which can be
% downloaded on the HTW Permod-website: https://pvspeicher.htw-berlin.de/permod/
% for convenience fieldnames of converted values are exported to cell array
%% References and Literature
% https://pvspeicher.htw-berlin.de/permod/

function [names,values] = import_spi_data(s) 
% Extraction of the parameters from the struct to reduce the calculating time
% list of variable names to exctract
names =[... %1. System sizing
"P_PV2AC_in";... % Rated PV input power (AC) in kW
"P_PV2AC_out";... % Rated PV output power (AC) in kW
"P_PV2BAT_in";... % Nominal input charging power (DC) in kW
"P_PV2BAT_out";...% Nominal charging power (DC) in kW
"P_BAT2AC_out";...% Nominal discharging power (AC) in kW
"P_AC2BAT_in";...% Nominal input charging power (AC) in kW
% 2. Conversion losses
"PV2AC.a_in";... % Coefficient of the quadratic PV2AC power loss function in W
"PV2AC.b_in";... % Coefficient of the quadratic PV2AC power loss function in W
"PV2AC.c_in";...  % Coefficient of the quadratic PV2AC power loss function in W
"PV2AC.a_out";...  % Coefficient of the quadratic PV2AC power loss function in W
"PV2AC.b_out";...  % Coefficient of the quadratic PV2AC power loss function in W
"PV2AC.c_out";... % Coefficient of the quadratic PV2AC power loss function in W

"PV2BAT.a_in";... % Coefficient of the quadratic PV2BAT power loss function in W
"PV2BAT.b_in";... % Coefficient of the quadratic PV2BAT power loss function in W
"PV2BAT.c_in";... % Coefficient of the quadratic PV2BAT power loss function in W

"BAT2AC.a_out";... % Coefficient of the quadratic BAT2AC power loss function in W
"BAT2AC.b_out";... % Coefficient of the quadratic BAT2AC power loss function in W
"BAT2AC.c_out";... % Coefficient of the quadratic BAT2AC power loss function in W

"AC2BAT.a_out";...% Coefficient of the quadratic AC2BAT power loss function in W
"AC2BAT.b_out";... % Coefficient of the quadratic AC2BAT power loss function in W
"AC2BAT.c_out";... % Coefficient of the quadratic AC2BAT power loss function in W
"AC2BAT.a_in";... % Coefficient of the quadratic AC2BAT power loss function in W
"AC2BAT.b_in";... % Coefficient of the quadratic AC2BAT power loss function in W
"AC2BAT.c_in";... % Coefficient of the quadratic AC2BAT power loss function in W
% eta_BAT=s.eta_BAT; % Mean battery efficiency in %
% 3. Control losses
"SOC_h";... % Hysteresis threshold for the recharging of the battery
"t_DEAD";... % Mean dead time in s
"t_CONSTANT";...% Mean settling time in s
% 4. Standby losses
"P_SYS_SOC1_DC";...% DC standby power consumption in fully charged state in W
"P_SYS_SOC1_AC";...% AC standby power consumption in fully charged state in W
"P_SYS_SOC0_AC";...% AC standby power consumption in fully discharged state in W
"P_SYS_SOC0_DC";...% DC standby power consumption in fully discharged state in W
"P_PERI_AC";...% AC power consumption of other system components in W
"E_BAT";...
"eta_BAT"
];
%%
values = -9999*ones(length(names),1);
for vIdx = 1:length(names)
    actName = regexp(names(vIdx),'\.','split');
    if length(actName)>1
        temp = s.(actName(1));
        for fIdx = 2:length(actName)
        	temp = temp.(actName(fIdx));
        end
        values(vIdx,1) = temp;        
    else
        values(vIdx,1) = s.(names(vIdx));
    end    
end
