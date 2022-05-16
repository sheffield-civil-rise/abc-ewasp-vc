% Paths.
homePath = char(java.lang.System.getProperty("user.home"));
mainPath = fullfile(homePath, "temp_ewasp_vc");

% Number of runs.
numRuns = 1; % Number of simulations to run.

% Manual structure definition.
manualStructureDefinition = 0;
% The other configs in this section are only used if the above is set to 1.
roomUse = ['L' 'O' 'O' 'O' 'O' 'B' 'B' 'B' 'B' 'O' 'O' ' '];
frenchDoors = ['N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N'];
upDown = [0 0 0 0 1 1 1 1 1 1 1]; % 0 = downstairs, 1 = upstairs
floortype = 1; % 0 = suspended timber, 1 = concrete slab
rooftype = 0; % 0 = standard, 1 = high mass green roof
floorOrCeilingArea = [
    25.4 11.1 4.40 4.50 4.00 12.9 8.37 8.20 5.94 2.70 6.60 0.00
];
NESW_Lengths = [
    3.4 0   0   1.8 0   3.5 0   3.9 0   0   0
    7.5 0   0   0   0   3.3 2.7 0   0   0   1
    3.3 4.1 0   0   0   0   3.1 0   2.2 2   0
    0   2.7 2.1 1   0   0   0   2.1 2.7 0   0
]; % Test house wall lengths as a function of direction facing.
NESW_Windows = [
    3.6	0	0	0	0	1	0	1	0	0	0
    0	0	0	0	0	0	0	0	0	0	0
    2.5	2.1	0	0	0	0	1	0	1	0	0
    0	0	0	0	0	0	0	0	0	0	0
]; % Test house wall lengths as a function of direction facing.
verticalConnectMatrix = [
    0   0   0   0   0   0   0   0   0   0   0 %1
    0   0   0   0   0   0   0   0   0   0   0 %2
    0   0   0   0   0   0   0   0   0   0   0 %3
    0   0   0   0   1   0   0   0   0   0   0 %4
    0   0   0   -1  0   0   0   0   0   0   0 %5
    0   0   0   0   0   0   0   0   0   0   0 %6
    0   0   0   0   0   0   0   0   0   0   0 %7
    0   0   0   0   0   0   0   0   0   0   0 %8
    0   0   0   0   0   0   0   0   0   0   0 %9
    0   0   0   0   0   0   0   0   0   0   0 %10
    0   0   0   0   0   0   0   0   0   0   0 %11
];
% Connect matrix for the "day" state. 0 means rooms are not connected; 1
% means rooms are connected by an open doorway. 2 means rooms are connected
% by a closed doorway. E.g. if element (1, 2) is 2, then rooms 1 and 2 are
% linked by a closed door. % Matrix must be symmetric.
HCM_State_1 = [
    0   1   0   1   0   0   0   0   0   0   0
    1   0   0   1   0   0   0   0   0   0   0
    0   0   0   1   0   0   0   0   0   0   0
    1   1   1   0   0   0   0   0   0   0   0
    0   0   0   0   0   1   1   1   1   0   1
    0   0   0   0   1   0   0   0   0   1   0
    0   0   0   0   1   0   0   0   0   0   0
    0   0   0   0   1   0   0   0   0   0   0
    0   0   0   0   1   0   0   0   0   0   0
    0   0   0   0   0   1   0   0   0   0   0
    0   0   0   0   1   0   0   0   0   0   0
];
HCM_State_2 = [
    0   2   0   2   0   0   0   0   0   0   0
    2   0   0   2   0   0   0   0   0   0   0
    0   0   0   2   0   0   0   0   0   0   0
    2   2   2   0   0   0   0   0   0   0   0
    0   0   0   0   0   2   2   2   2   0   2
    0   0   0   0   2   0   0   0   0   2   0
    0   0   0   0   2   0   0   0   0   0   0
    0   0   0   0   2   0   0   0   0   0   0
    0   0   0   0   2   0   0   0   0   0   0
    0   0   0   0   0   2   0   0   0   0   0
    0   0   0   0   2   0   0   0   0   0   0
];
conductiveHconnectMatrix = [
    0	3.3	0	3.1	0	0	0	0	0	0	0
    3.3	0	0	3.8	0	0	0	0	0	0	0
    0	0	0	4.1	0	0	0	0	0	0	0
    3.1	3.8	4.1	0	0	0	0	0	0	0	0
    0	0	0	0	0	4.3	0.6	3.9	2.8	0	2
    0	0	0	0	4.3	0	0	1.6	0	2.7	0
    0	0	0	0	0.6	0	0	0	0	3.1	3.3
    0	0	0	0	3.9	1.6	0	0	0	0	0
    0	0	0	0	2.8	0	0	0	0	0	3.3
    0	0	0	0	0	2.7	3.1	0	0	0	0
    0	0	0	0	2	0	3.3	0	3.3	0	0
];
conductiveVConnectMatrix = [
    0   0   0   0   0   1   1   0   0   0   0   0 %1
    0   0   0   0   0   0   0   0   1   0   0   0 %2
    0   0   0   0   0   0   0   1   0   0   0   0 %3
    0   0   0   0   0   0   0   1   0   0   0   0 %4
    0   0   0   -1  0   0   0   0   0   0   0   0 %5
    -1  0   0   0   0   0   0   0   0   0   0   0 %6
    -1  0   0   0   0   0   0   0   0   0   0   0 %7
    0   0   -1  0   0   0   0   0   0   0   0   0 %8
    0   -1  0   0   0   0   0   0   0   0   0   0 %8
    -1  0   0   0   0   0   0   0   0   0   0   0 %10
    0   -1  0   0   0   0   0   0   0   0   0   0 %11
    0   0   0   0   0   0   0   0   0   0   0   0 %12
];
% Control transition time to second closed door state.
Diurnal_State_Active = 0;
Evening_State_Start_Hour = 10;
Evening_State_End_Hour = 6;

% Other building configs.
buildingYearBuilt = 2005; % More accurately: YEAR in which the house was built.
buildingType = 4; % 1 = end terraced, 2 = mid ", 3 = semi, 4 = detached
buildingSize = 'S'; % 'S' = small, 'N' = normal, 'L' = large
wallRetrofit = 1;
systemWall = 0;
floorInsulationUpgrade = 1;
roofInsulationUpgrade = 1; 
expect30Degrees = 1; % Can pump can easily achieve deltaTs of 30 degrees?
fixStat = 0; % Assume all homeowners expect house to reach 21 degrees.
% If fixing all thermostat setpoints, this variable must be assigned the
% setPoint, e.g. 21 if the user desires all houses the set their
% thermostats to 21. Ignored if fixStat = 0.
fixedStatPoint = 21; % ^
forceTen = 0; % Force radiators to be a minimum of 10 litres.
% 0 = defined building not rotated, 90 = rotated 90 degrees clockwise from
% north, etc
rotation = 0 % ^;
flip = 'N'; % Mirror image house. (Only affects airflow and irradiance.)
% 0 = statisticaly assigned occupancy, 1 = fixed occupancy level (specified
% in 'occ')
forcedOccupancy = 1; % ^
occ = 1; % Occupancy level of simulated houses.

% Control type inputs.
% EXPERIMENTAL. Probability of any given house partaking in preheating. set
% to 1 or 0 if you want to force presence/absence of the strategy.
preHeatChance = 0; % ^
% EXPERIMENTAL. Probability of house partaking in thermostat dead band
% temperature reduction at peak times (reduced to 18 degrees). Set to 1 or
% 0 if you want to force presence/absence of the strategy.
slackRequestChance = 0; % ^
C_d = 0.75; % Doorway coefficient of discharge. Set between 0 and 1.
thermostatBand = 0.1; % Deadband of the room thermostat.
% Save results of airflow for your floorplan, and auto load later without
% having to run airflow again. (Only works if all internal doors are open
% in both all building states. Will be futher developed for later
% versions.)
fastAirFlow = 1; % ^

% Time and weather inputs.
dayType = "WD"; % Day type. "WD" = weekday. "WE" is weekend.
forceCold = 0; % Forces temperature to a constant -5 degrees if set to 1. 

% Heat pump variables.
Tank_Exist_Probability = 1; % Probability of single house having DHW tank.
variableASHP = 1; % Does the ASHP have a variable speed compressor?
pumpRamp = 180; % Seconds for pump to reach full heat output.

% Save these configs to an importable file.
save("setup_configs.mat");