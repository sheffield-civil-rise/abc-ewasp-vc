homePath = char(java.lang.System.getProperty("user.home"));
mainPath = fullfile(homePath, "temp_ewasp_vc");
ewaspPath = fullfile(mainPath, "EWASP");
structuralPath = fullfile(ewaspPath, "Structural");
energyDemandsPath = fullfile(ewaspPath, "Energy Demands");

manualStructureDefinition = 0; %only set to 1 if you want to manually define all of the connection matricies and floor areas

buildingAge = 2005; %house build year - should not exceed 2019 unless the user intends to activate the passivehouse model, which is currently experimental and of limited validity
buildingType = 4; %1 = end terraced, 2 = mid Terraced, 3 = semi, 4 = detached
buildingSize = 'S'; %'S' = Small, 'N' = Normal, 'L' = Large
wallRetrofit = 1;
systemWall = 0;
floorInsulationUpgrade = 1;
roofInsulationUpgrade = 1; 
expect30Degrees = 1; %do homeowners expect the pump to perform as well as/better than a boiler i.e. the pump can easily achieve deltaT's of 30 degrees?
fixStat = 0; %assume all homeowners expect house to reach 21 degrees
fixedStatPoint = 21; % if fixing all thermostat setpoints, this variable must be assigned the setPoint (e.g. 21 if the user desires all houses the set their thermost to 21oC). This variable will be ignored if fixStat = 0
forceTen = 0; %force radiators to be a minimum of 10 litres - useful to avoid model crashes when houses are low heat demand (newer houses)
rotation = 0; %equal to 0 (defined building is not rotated), 90 (rotated 90 degreesclockwise from north), 180, or 270
flip = 'N'; %mirror image the house (only affects airflow and irradiance calcs)

forcedOccupancy = 1; % 0 = statisticaly assigned occupancy, 1 = fixed occupancy level (specified in 'occ')
occ = 1; % the occupancy level of simulated houses - only affects output if 'forcedOccupancy = 1'

% Control Type Inputs

preHeatChance = 0; %EXPERIMENTAL - probability of any given house partaking in preheating - set to 1 or 0 if you want to force presence/absence of the strategy
slackRequestChance = 0; %EXPERIMENTAL - probability of house partaking in thermostat dead band temperature reduction at peak times (reduced to 18oC) - set to 1 or 0 if you want to force presence/absence of the strategy

C_d = 0.75; %doorway coefficient of discharge - set to a typical value (0.75) by default, but can be set between 0 and 1
thermostatBand = 0.1; %deadband of the room thermostat - set to a typical 0.1 oC by default, but adjustable to any real positive value
fastAirFlow = 1; %save results of airflow for your floorplan, and auto load later without having to run airflow again (only works if all internal doors are open in both all building states - will be futher developed for later versions)

%Time and Weather Inputs

dayType = 'WD'; %Day type - 'WD' is weekday, 'WE' is weekend
forceCold = 0; %forces temperature to a constant -5 degrees celcius if set equal to 1 

%Heat Pump Variables

Tank_Exist_Probability = 1; %probability of a single house having a DHW tank, (0 = never, 1 = certain ownership, all in between values permitted)

variableASHP = 1;%does the ASHP have a variable speed compressor? 1 = yes, 0 = no
pumpRamp = 180;%seconds for pump to reach full heat output

numRuns = 1;%number of Simulations to run
%%

%Applicable only to those wishing to change detailed house structure and
%fabric (see instruction manual for details on this)

if manualStructureDefinition == 1

roomUse = ['L' 'O' 'O' 'O' 'O' 'B' 'B' 'B' 'B' 'O' 'O' ' '];
frenchDoors = ['N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N' 'N'];
upDown = [0;0;0;0;1;1;1;1;1;1;1]; %0 = room is downstairs, 1 = room is upstairs
floortype = 1; %0 = suspended timber 1 = concrete slab
rooftype = 0; %0 = standard 1 = high mass green roof
floorOrCeilingArea =  [25.4 11.1 4.40 4.50 4.00 12.9 8.37 8.20 5.94 2.70 6.60 0.00];

NESW_Lengths = [
3.4 0 0 1.8 0 3.5 0 3.9 0 0 0   
7.5 0 0 0 0 3.3 2.7 0 0 0 1
3.3 4.1 0 0 0 0 3.1 0 2.2 2 0
0 2.7 2.1 1 0 0 0 2.1 2.7 0 0];%the test house wall lengths as a function of direction facing

NESW_Windows = [
3.6	0	0	0	0	1	0	1	0	0	0
0	0	0	0	0	0	0	0	0	0	0
2.5	2.1	0	0	0	0	1	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0];%the test house window areas as a function of direction facing

verticalConnectMatrix = [
 0 0 0 0 0 0 0 0 0 0 0  %1   
 0 0 0 0 0 0 0 0 0 0 0  %2
 0 0 0 0 0 0 0 0 0 0 0  %3
 0 0 0 0 1 0 0 0 0 0 0  %4
 0 0 0 -1 0 0 0 0 0 0 0  %5
 0 0 0 0 0 0 0 0 0 0 0  %6
 0 0 0 0 0 0 0 0 0 0 0  %7
 0 0 0 0 0 0 0 0 0 0 0  %8
 0 0 0 0 0 0 0 0 0 0 0  %9
 0 0 0 0 0 0 0 0 0 0 0  %10
 0 0 0 0 0 0 0 0 0 0 0  %11
];

HCM_State_1 = [ %connect matrix for the 'day' state - 0 means rooms are not connected, 1 means rooms are connected by an open doorway, 2 means rooms are conneced by a closed doorway
 0 1 0 1 0 0 0 0 0 0 0 %e.g. if element (1,2) is 2, then rooms 1 and 2 are linked by a closed door   
 1 0 0 1 0 0 0 0 0 0 0 %matrix must be symmetric
 0 0 0 1 0 0 0 0 0 0 0 
 1 1 1 0 0 0 0 0 0 0 0 
 0 0 0 0 0 1 1 1 1 0 1
 0 0 0 0 1 0 0 0 0 1 0 
 0 0 0 0 1 0 0 0 0 0 0 
 0 0 0 0 1 0 0 0 0 0 0 
 0 0 0 0 1 0 0 0 0 0 0 
 0 0 0 0 0 1 0 0 0 0 0
 0 0 0 0 1 0 0 0 0 0 0  
];

HCM_State_2 = [
 0 2 0 2 0 0 0 0 0 0 0    
 2 0 0 2 0 0 0 0 0 0 0 
 0 0 0 2 0 0 0 0 0 0 0 
 2 2 2 0 0 0 0 0 0 0 0 
 0 0 0 0 0 2 2 2 2 0 2
 0 0 0 0 2 0 0 0 0 2 0 
 0 0 0 0 2 0 0 0 0 0 0 
 0 0 0 0 2 0 0 0 0 0 0 
 0 0 0 0 2 0 0 0 0 0 0 
 0 0 0 0 0 2 0 0 0 0 0
 0 0 0 0 2 0 0 0 0 0 0  
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
0	0	0	0	2	0	3.3	0	3.3	0	0];

conductiveVConnectMatrix = [
 0 0 0 0 0 1 1 0 0 0 0 0 %1   
 0 0 0 0 0 0 0 0 1 0 0 0 %2
 0 0 0 0 0 0 0 1 0 0 0 0 %3
 0 0 0 0 0 0 0 1 0 0 0 0 %4
 0 0 0 -1 0 0 0 0 0 0 0 0 %5
 -1 0 0 0 0 0 0 0 0 0 0 0 %6
 -1 0 0 0 0 0 0 0 0 0 0 0 %7
 0 0 -1 0 0 0 0 0 0 0 0 0 %8
 0 -1 0 0 0 0 0 0 0 0 0 0 %8
 -1 0 0 0 0 0 0 0 0 0 0 0 %10
 0 -1 0 0 0 0 0 0 0 0 0 0 %11
 0 0 0 0 0 0 0 0 0 0 0 0 %12
];

%Control Transition Time to second closed door state 
Diurnal_State_Active = 0;
Evening_State_Start_Hour = 10;
Evening_State_End_Hour = 6;


else %autoassign building structure
    
%Control Transition Time to second closed door state - are not used in auto
%structure definiton mode, but must be given numerical values for the mdoel
%to run
Diurnal_State_Active = 0;
Evening_State_Start_Hour = 10;
Evening_State_End_Hour = 6;
    
  %AUTOASSIGN the structure of the building, based on a typical layout from
  %the time period
[HCM_State_1,HCM_State_2,verticalConnectMatrix,conductiveHconnectMatrix,conductiveVConnectMatrix,NESW_Lengths,NESW_Windows,roomUse,frenchDoors,upDown,floorOrCeilingArea,floortype,rooftype,ventPattern] = AssignBuildingStructure(buildingType,buildingAge);

end


%% 

%Advanced Controls - Do not change unless you are confident about the changes these may make to the model

%DHW Tank Settings
Aux_Threshold = 52; %Temperature at which the Aux Heater take over from the heat pump when raising temperature to 60 for legionella control
Tank_Upper_Temp = 52; %Temperature at which heating stops during normal operation
Tank_Lower_Temp = 49.5; %Temperature at which tank heating begins during normal operation
HEX_ReturnLowerLimit = 52.5; %Temperature at which heat pump begins to heat up tank charging loop fluid
HEX_ReturnUpperLimit = 55; %Temperature at which heat pump stops heating tank charging loop fluid

%Heat Pump Return Flow Thermostat Settings
ReturnUpperLimit = 40; %Space heating Return Flow temperature at which the Heat Pump switches off
ReturnLowerLimit = 37.5; %Space heating Return Flow temperature at which the Heat Pump switches off
Defrost_After_Time = 30; %Cumulative minutes of operation below 1.7oC before a defrost is required (Typical 30 --> 90)
scaleFactor = 0.20; %empirical scale to account for overestimation of required flow temp inherent in the 'flow temp vs outdoor temp' estimation model - we do not reccomend changing this from its default 0.2
loopCap = 15;%capacity of the pipework between the heat pump and radiators, in units litres
%Space Settings

DesiredDeltaT = 5;%Desired deltaT across radiator flow and return

autoWallStartTemp = 1; %Determines whether sensible starting temperatures for walls are automatically calculated (1 if so, 0 if manually defined by the user)
wallStartTempExt = 6;  %starting temperature of external face of external walls, only active if autoWallStartTemp = 0
wallStartTempInt = 16; %starting temperature of internal face of external walls, only active if autoWallStartTemp = 0

open_system(fullfile(ewaspPath, "Final_EWASP_VC.slx"));

%Load Input Arrays
load(fullfile(ewaspPath, "Meteorological", "GroundTempTimeSeries.mat"))
load(fullfile(structuralPath, "UVal_Data.mat"), "UVals_Archetypes")
load(fullfile(energyDemandsPath, "EnergyDemandProfiles.mat"))
load(fullfile(energyDemandsPath, "HeatingOnProfiles.mat"))
load(fullfile(energyDemandsPath, "occupancyProfiles.mat"))

load('Solar.mat')
load('Wind.mat')
load('Temperature.mat')

%%
[dwnAndConcrete] = floorStructure(upDown,floortype); %assign concrete floors to ground floor rooms if concrete floor type is selected

[HCM,HCM_closed,HCM2,HCM_closed2] = makeAirflowInputMatrices(HCM_State_1,HCM_State_2); %create input matrices for airflow from user input data

NESW_Lengths = RotateAndFlipHouseWalls(NESW_Lengths,rotation,flip);%rotates and flips walls for the 'wall node model' 

if size(floorOrCeilingArea,2) < 12
    
    floorOrCeilingArea(1,end+1:12) = 0;
    
else
end

%%  parameters the model infers
HPdT = 30;
HPType = 'A';
SolarThermalExists = 0; 
furnitureModelOn = 1;%1 = furniture considered, 2 = furniture ignored
ventPattern = [' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '];
roofArea = sum(double(upDown == 1).*floorOrCeilingArea(1,1:length(upDown))')*1;%%Approximates area of flat roof
cRoofGreen = 100000;
RoofIrradiance = Flat_NS_EW_RoofIrradiance(:,1);%selects irradiance per M2 for flat roof
HPSized = 'Y'; %Radiators are sized up for lower heat pump Temp ('Y') or not ('N') - PROBABLY DO NOT WANT TO CHANGE THIS
[neighbourMatrix,convUDMatrix] = simpleConvectionMatrices(HCM,verticalConnectMatrix) % convert matrices to simple convective model input
[condUDMatrix] = makecondUDMatrix(conductiveVConnectMatrix) % convert conductive vertical connect matrix into form required for model input
ceilingHeight = 2.4; %(m)
windowArea = sum(NESW_Windows);
offsetDays = 0; %day to start on (0 is Jan 1st, 364 is December 31st) 
days = 1; %number of days to simulate

if size(windowArea,2) < 11; windowArea(1,end+1:11) = 0; end

roomVol = floorOrCeilingArea*ceilingHeight;
NESW_wallArea = max(NESW_Lengths*ceilingHeight-NESW_Windows,0);

[ceilingU,wallU,floorU,windowU,doorU,ACRFix,intermediateU] = assignUValsAndACR2(buildingType,buildingAge,UVals_Archetypes,wallRetrofit,systemWall,floorInsulationUpgrade,roofInsulationUpgrade);

[wallDensity,wallHeatCapacityInt,wallHeatCapacityMid,wallHeatCapacityExt] = assignWallProperties(buildingAge);

%%
%figure out if building is a bungalow using VCM, and save result as 'bungalow'

if sum(sum(verticalConnectMatrix>0))>0; bungalow = 0; else; bungalow = 1; end

%% Scaling building dimensions

if buildingSize == 'N'
    
    NESW_wallArea = max(NESW_Lengths*ceilingHeight-NESW_Windows,0);
    
elseif buildingSize == 'S'
    
    floorOrCeilingArea = floorOrCeilingArea*0.85;
    NESW_Lengths = NESW_Lengths*(0.85^0.5);
    NESW_wallArea = max(NESW_Lengths*ceilingHeight-NESW_Windows,0);
    roofArea = roofArea*0.85;
    roomVol = roomVol*0.85;
    
elseif buildingSize == 'L'
    
    floorOrCeilingArea = floorOrCeilingArea*1.15;
    NESW_Lengths = NESW_Lengths*(1.15^0.5);
    NESW_wallArea = max(NESW_Lengths*ceilingHeight-NESW_Windows,0);
    roofArea = roofArea*1.15;
    roomVol = roomVol*1.15;
    
else
    
end

RoomDataMatrix = [zeros(1,12);ones(1,12)*wallDensity;zeros(1,12);ones(1,12)*wallU;ones(1,12)*windowU;ones(1,12)*floorU;ones(1,12)*ceilingU;zeros(1,12);windowArea, 0;floorOrCeilingArea;zeros(1,12);floorOrCeilingArea*ceilingHeight]; %Create Matrix

[RoomDataMatrix,IsTop] = assignFloorCeilRoofUVals(upDown,floorU,intermediateU,ceilingU,RoomDataMatrix,bungalow) % assigns correct U-values to room ceiling and floor depending on whether it is top bottom or middle floor, and whther the house is a bungalow
[RadiatorMatrix,massFlowMatrix] = makeRadiatorMatrix(roomUse,frenchDoors,HPSized,RoomDataMatrix,DesiredDeltaT,buildingAge,forceTen)

[a] = determineHeatPumpMultiplier(upDown,RoomDataMatrix,ACRFix,NESW_wallArea,windowArea,floorOrCeilingArea,wallU,windowU,ceilingU,floorU,HPdT,HPType);

roomCount = (12-sum(isspace(roomUse)));
numRooms = roomCount;

if numRooms < 11 IsTop(1,numRooms+1:11) = 0, else, end

for i=1:size(roomUse,2)
    if(roomUse(1,i) == 'L')
numericalRoomUse(1,i) = 1;
    elseif (roomUse(1,i) == 'B')
      numericalRoomUse(1,i) = 2;
    else
       numericalRoomUse(1,i) = 3; 
    end
end

CommentOrUncommentRooms(roomCount,HPType,variableASHP);

ACR = [ACRFix*ones(1,roomCount),zeros(1,12-roomCount)];


%%

ceilArea = sum(floorOrCeilingArea.*[IsTop 0]);
floorArea = sum(floorOrCeilingArea.*[double(not(IsTop)) 0]);

LossFactor = sum(sum(NESW_wallArea))*wallU+sum(windowArea)*windowU+floorArea*floorU+ceilArea*ceilingU+((ACR(1,1)/3600)*sum(roomVol)*1.275*720);

pumpRealCapacities = [3.6;4.8;6.8;9;11.2;13.4];
pumpChoices = [5;6;8.5;11.2;14;18];
theoreticalHeatLosskW = ((LossFactor*24.2)/1000)*1.5;%Times 1.5 accounts for the requirement the heat relatively quickly

heatDiscrepancy = pumpRealCapacities-theoreticalHeatLosskW;
heatDiscrepancy(heatDiscrepancy<0) = -1000;
heatDiscrepancy = abs(heatDiscrepancy);

if sum(heatDiscrepancy) == 6000 %if no pump is technically large enough

pumpChoice = pumpChoices(6,1) %choose the largest avaialble
PUMPWARNING = 1; %Warn that no commercially available pump is large enough
else
    [~,MinIndex] = min(heatDiscrepancy);
pumpChoice = pumpChoices(MinIndex,1);
PUMPWARNING = 0; %Warn that no commercially available pump is large enough
end

heatPumpDataSetsPath = fullfile(mainPath, "HeatPumpDataSets");
minHeatPumpPath = fullfile(heatPumpDataSetsPath,"COPDatabase_Min.xls");
midHeatPumpPath = fullfile(heatPumpDataSetsPath,"COPDatabase_Mid.xls");
maxHeatPumpPath = fullfile(heatPumpDataSetsPath,"COPDatabase_Max.xls");
heatPumpFileType = "Sheet";
pumpID = strcat("PUZ", num2str(pumpChoice));
heatPumpRangeStr = "A1:O402";

COPDatabase_Min = ...
    readtable( ...
        minHeatPumpPath, ...
        heatPumpFileType, ...
        pumpID, ...
        "Range", ...
        heatPumpRangeStr ...
    );
COPDatabase_Mid = ...
    readtable( ...
        midHeatPumpPath, ...
        heatPumpFileType, ...
        pumpID, ...
        "Range", ...
        heatPumpRangeStr ...
    );
COPDatabase_Max = ...
    readtable( ...
        maxHeatPumpPath, ...
        heatPumpFileType, ...
        pumpID, ...
        "Range", ...
        heatPumpRangeStr ...
    );

clear Heat_Max Heat_Mid Heat_Min COP_Max COP_Mid COP_Min

for i = 1:31
    COP_integerDegreesMax(i,:) = COPDatabase_Max(101+(i-1)*10,:);
    COP_integerDegreesMid(i,:) = COPDatabase_Mid(101+(i-1)*10,:);
    COP_integerDegreesMin(i,:) = COPDatabase_Min(101+(i-1)*10,:);
end

for i = 1:7
   
    Heat_Max(:,i) = COP_integerDegreesMax(:,2*i);
    Heat_Mid(:,i) = COP_integerDegreesMid(:,2*i);
    Heat_Min(:,i) = COP_integerDegreesMin(:,2*i);
    COP_Max(:,i) = COP_integerDegreesMax(:,2*i+1);
    COP_Mid(:,i) = COP_integerDegreesMid(:,2*i+1);
    COP_Min(:,i) = COP_integerDegreesMin(:,2*i+1);
end

Heat_Max = table2array(Heat_Max);
Heat_Mid = table2array(Heat_Mid);
Heat_Min = table2array(Heat_Min);
COP_Max = table2array(COP_Max);
COP_Mid = table2array(COP_Mid);
COP_Min = table2array(COP_Min);

Heat_Max(isnan(Heat_Max)) = 0;
Heat_Mid(isnan(Heat_Mid)) = 0;
Heat_Min(isnan(Heat_Min)) = 0;
COP_Max(isnan(COP_Max)) = 0;
COP_Mid(isnan(COP_Mid)) = 0;
COP_Min(isnan(COP_Min)) = 0;
    
Elec_Max = Heat_Max./COP_Max;
Elec_Mid = Heat_Mid./COP_Mid;
Elec_Min = Heat_Min./COP_Min;
Elec_Max(isnan(Elec_Max)) = 0;
Elec_Mid(isnan(Elec_Mid)) = 0;
Elec_Min(isnan(Elec_Min)) = 0;
        
    if expect30Degrees == 1 %if we assume homeowners expect a higher temperature to be reachable, or heating to occur faster, scale pump size up by a factor of 30/24.2
    Elec_Max = Elec_Max*(30/24.2);
    Elec_Mid = Elec_Mid*(30/24.2);
    Elec_Min = Elec_Min*(30/24.2);
    Heat_Max = Heat_Max*(30/24.2);
    Heat_Mid = Heat_Mid*(30/24.2);
    Heat_Min = Heat_Min*(30/24.2);
    end
    
    Elec_3D(:,:,1) = Elec_Min;
    Elec_3D(:,:,2) = Elec_Mid;
    Elec_3D(:,:,3) = Elec_Max;
    
    for i = 1:31      
        for o = 1:3
        
            lookUp = [3;5;10];
            
        end
    end
    
    %% Fixed Rate Pump Array Generation
    
   ElecFixed = [Elec_Max(6,2) Elec_Max(6,4) Elec_Max(6,6) Elec_Max(6,7)
       Elec_Max(16,2) Elec_Max(16,4) Elec_Max(16,6) Elec_Max(16,7)
       Elec_Max(23,2) Elec_Max(23,4) Elec_Max(23,6) Elec_Max(23,7)]*1000;
   
   HeatFixed = [Heat_Max(6,2) Heat_Max(6,4) Heat_Max(6,6) Heat_Max(6,7)
       Heat_Max(16,2) Heat_Max(16,4) Heat_Max(16,6) Heat_Max(16,7)
       Heat_Max(23,2) Heat_Max(23,4) Heat_Max(23,6) Heat_Max(23,7)]*1000;
   
   SourceFixed = HeatFixed-ElecFixed;

%%

[AirFlowID] = createUniqueIDforHouseLayout(rotation,flip,C_d,roomVol,HCM_State_1,verticalConnectMatrix); %determine the unique ID for this building layout
location = fullfile(ewaspPath, "AirFlowPregens", strcat(AirFlowID, ".mat"));

%%check whether HCM stats are both the same, and ensure there are no closed
%%doors, otherwise don't use the fast load function (will extend to load complex airflow definitions in futer versions) 
HS1 = HCM_State_1;
HS1(HS1<2) = 0;
HS2 = HCM_State_2;
HS2(HS2<2) = 0;
openTest = sum(sum(HS1+HS2));
equalTest = sum(sum(abs(HS1-HS2)));

%%either run airflow calcs or load pre-calculated output

if and(openTest+equalTest == 0,fastAirFlow == 1) %if all doors are open, both door states are the same, fast airflow is selected...

    if isfile(location) == 1 %airflow data already exists for the building specified
load(location);  %just load all the airflow data
    'loading existing airflow data'
    else %run airflow calculations and save outputs
        
       [room2roomflowmatrix_N,room2roomflowmatrix_E,room2roomflowmatrix_S,room2roomflowmatrix_W,StateAirInEXPANDED_N,StateAirInEXPANDED_E,StateAirInEXPANDED_S,StateAirInEXPANDED_W,StateAirOutEXPANDED_N,StateAirOutEXPANDED_E,StateAirOutEXPANDED_S,StateAirOutEXPANDED_W,deltaPEXPANDED_N,deltaPEXPANDED_E,deltaPEXPANDED_S,deltaPEXPANDED_W,HCM,HCM_closed,VCM,roomCount] = Airflow_State_Model_Update(C_d,HCM,HCM_closed,verticalConnectMatrix,NESW_Lengths,upDown,ACR,rotation,flip,bungalow,'1');
       [room2roomflowmatrix_N2,room2roomflowmatrix_E2,room2roomflowmatrix_S2,room2roomflowmatrix_W2,StateAirInEXPANDED_N2,StateAirInEXPANDED_E2,StateAirInEXPANDED_S2,StateAirInEXPANDED_W2,StateAirOutEXPANDED_N2,StateAirOutEXPANDED_E2,StateAirOutEXPANDED_S2,StateAirOutEXPANDED_W2,deltaPEXPANDED_N2,deltaPEXPANDED_E2,deltaPEXPANDED_S2,deltaPEXPANDED_W2,HCM2,HCM_closed2,VCM2,roomCount] = Airflow_State_Model_Update(C_d,HCM2,HCM_closed2,verticalConnectMatrix,NESW_Lengths,upDown,ACR,rotation,flip,bungalow,'2');    

        
        save(location,'room2roomflowmatrix_N','room2roomflowmatrix_E','room2roomflowmatrix_S','room2roomflowmatrix_W','StateAirInEXPANDED_N','StateAirInEXPANDED_E','StateAirInEXPANDED_S','StateAirInEXPANDED_W','StateAirOutEXPANDED_N','StateAirOutEXPANDED_E','StateAirOutEXPANDED_S','StateAirOutEXPANDED_W','deltaPEXPANDED_N','deltaPEXPANDED_E','deltaPEXPANDED_S','deltaPEXPANDED_W','HCM','HCM_closed','VCM','roomCount','room2roomflowmatrix_N2','room2roomflowmatrix_E2','room2roomflowmatrix_S2','room2roomflowmatrix_W2','StateAirInEXPANDED_N2','StateAirInEXPANDED_E2','StateAirInEXPANDED_S2','StateAirInEXPANDED_W2','StateAirOutEXPANDED_N2','StateAirOutEXPANDED_E2','StateAirOutEXPANDED_S2','StateAirOutEXPANDED_W2','deltaPEXPANDED_N2','deltaPEXPANDED_E2','deltaPEXPANDED_S2','deltaPEXPANDED_W2','HCM2','HCM_closed2','VCM2')
    end

else %run airflow calculations and save outputs
    
  [room2roomflowmatrix_N,room2roomflowmatrix_E,room2roomflowmatrix_S,room2roomflowmatrix_W,StateAirInEXPANDED_N,StateAirInEXPANDED_E,StateAirInEXPANDED_S,StateAirInEXPANDED_W,StateAirOutEXPANDED_N,StateAirOutEXPANDED_E,StateAirOutEXPANDED_S,StateAirOutEXPANDED_W,deltaPEXPANDED_N,deltaPEXPANDED_E,deltaPEXPANDED_S,deltaPEXPANDED_W,HCM,HCM_closed,VCM,roomCount] = Airflow_State_Model_Update(C_d,HCM,HCM_closed,verticalConnectMatrix,NESW_Lengths,upDown,ACR,rotation,flip,bungalow,'1');
       [room2roomflowmatrix_N2,room2roomflowmatrix_E2,room2roomflowmatrix_S2,room2roomflowmatrix_W2,StateAirInEXPANDED_N2,StateAirInEXPANDED_E2,StateAirInEXPANDED_S2,StateAirInEXPANDED_W2,StateAirOutEXPANDED_N2,StateAirOutEXPANDED_E2,StateAirOutEXPANDED_S2,StateAirOutEXPANDED_W2,deltaPEXPANDED_N2,deltaPEXPANDED_E2,deltaPEXPANDED_S2,deltaPEXPANDED_W2,HCM2,HCM_closed2,VCM2,roomCount] = Airflow_State_Model_Update(C_d,HCM2,HCM_closed2,verticalConnectMatrix,NESW_Lengths,upDown,ACR,rotation,flip,bungalow,'2');    

         save(location,'room2roomflowmatrix_N','room2roomflowmatrix_E','room2roomflowmatrix_S','room2roomflowmatrix_W','StateAirInEXPANDED_N','StateAirInEXPANDED_E','StateAirInEXPANDED_S','StateAirInEXPANDED_W','StateAirOutEXPANDED_N','StateAirOutEXPANDED_E','StateAirOutEXPANDED_S','StateAirOutEXPANDED_W','deltaPEXPANDED_N','deltaPEXPANDED_E','deltaPEXPANDED_S','deltaPEXPANDED_W','HCM','HCM_closed','VCM','roomCount','room2roomflowmatrix_N2','room2roomflowmatrix_E2','room2roomflowmatrix_S2','room2roomflowmatrix_W2','StateAirInEXPANDED_N2','StateAirInEXPANDED_E2','StateAirInEXPANDED_S2','StateAirInEXPANDED_W2','StateAirOutEXPANDED_N2','StateAirOutEXPANDED_E2','StateAirOutEXPANDED_S2','StateAirOutEXPANDED_W2','deltaPEXPANDED_N2','deltaPEXPANDED_E2','deltaPEXPANDED_S2','deltaPEXPANDED_W2','HCM2','HCM_closed2','VCM2')

end

clear windDirectionSeries ElecOut AppOut
%%
for i = 1:numRuns
i
    roofStartTemp = ones(11,1)*20;
%randomly assign statistically determined heating system setting properties


[thermostatSetting,DesiredDHWTemp,Tank_Volume_m3,DHWDemandProfile,ElecDemandProfile,HeatingOnProfile,tankExists,occupancyProfile] = AssignStatisticallyWeightedHeatingSettings(DHWDemandProfiles_OCC1,DHWDemandProfiles_OCC2,DHWDemandProfiles_OCC3,DHWDemandProfiles_OCC4,DHWDemandProfiles_OCC5,ElecDemandProfiles_OCC1,ElecDemandProfiles_OCC2,ElecDemandProfiles_OCC3,ElecDemandProfiles_OCC4,ElecDemandProfiles_OCC5,WDProfile,WEProfile,dayType,Tank_Exist_Probability,occ1_normalFabric,occ2_normalFabric,occ3_normalFabric,occ4_normalFabric,occ5_normalFabric,forcedOccupancy,occ);

if fixStat == 1 %if we assume all homewoners want house to reach 21 degrees
thermostatSetting = fixedStatPoint;
else
end

[DesiredFlowTempVsInOutDeltaTemp] = calculateFlowTempVsHeatingPowerAndCharacteristicLoss(thermostatSetting,RadiatorMatrix,buildingSize,buildingType,buildingAge,systemWall,wallRetrofit,floorInsulationUpgrade,roofInsulationUpgrade,scaleFactor)


freegain = zeros(1440,1);

x = rand;
if preHeatChance >= x %make heating activate an hour before both peaks if, probability variable x allows it
  HeatingOnProfile(330:390,1) = 1; 
  HeatingOnProfile(930:990,1) = 1;  
else
end

x = rand;
if slackRequestChance >= x 
  SlackRequest = zeros(1440,1); SlackRequest(420:509) = 1; SlackRequest(960:1259) = 1;  
else   
  SlackRequest = zeros(1440,1);    
end

overChargeSeries = zeros(1440,1); overChargeSeries(930:990) = 1; overChargeSeries = repmat(overChargeSeries,365,1);

%PasiveHouse Test addition
if buildingAge >= 2020

 load('PassiveTest.mat')
 occupancy = occFreegainHotwaterElecTestPassiveOcc3(:,1);
 maxOcc = max(occupancy);
 freegain = occFreegainHotwaterElecTestPassiveOcc3(:,2)-max(occupancy)*25;
 DHWDemandProfile = occFreegainHotwaterElecTestPassiveOcc3(:,3);
 ElecDemandProfile = occFreegainHotwaterElecTestPassiveOcc3(:,4);
 HeatingOnProfile = repmat(HeatingOnProfile,365,1); %stretches out 'heating allowed on profile' to represent a full year 
 thermostatSetting = 20.0;
 Tank_Volume_m3 = 0.15;
 
else
    
 occupancy = occupancyProfile;
 maxOcc = max(occupancyProfile);
    
end

uVec = [8.1;wallU*2;wallU*2;14.4];
relLoss = [8.1/sum(uVec);(wallU*2)/sum(uVec);(wallU*2)/sum(uVec);14.4/sum(uVec)];
DeltaTProportional = 1./relLoss;
DeltaTProportional = DeltaTProportional/sum(DeltaTProportional);
RoomInitialTemps = ones(1,11)*thermostatSetting;

LeakMultiplier = 1+(2*(rand()-0.5)/10); %Apply slight (+/- 10%) randomisation to house leakiness

if forceCold == 1
    outdoorStartTemp = -5;
else
outdoorStartTemp = offsetDays*1440+1;
end

if autoWallStartTemp == 1
wallStartTempExt = thermostatSetting*(0.266+0.00215*outdoorStartTemp+0.018*wallU+0.00113*outdoorStartTemp*wallU+0.0068*wallU^2);
wallStartTempInt = thermostatSetting*(1+0.0023*outdoorStartTemp-0.06*wallU+0.005*outdoorStartTemp*wallU-0.00017*wallU^2)-(2.5*(thermostatSetting-outdoorStartTemp)/(21-outdoorStartTemp));
end

slabStartTemp = (GroundTempTimeSeries(offsetDays*1440+1,1)+thermostatSetting)/2;
StateSeries  =  StateSeriesGenerator(22,7,1);
TankHeatHour = randi([1 5])-1; %randomly varies the time at which the tank legionella heating cycle begins between midnight and 4 am

 simOut  =  sim('Final_EWASP_VC'); 

if variableASHP == 1
 V = HP_Elec.Data;   
    V = squeeze(V(1,1,:));
else
V = HP_Elec.Data;
end

V = V(2:end,1);
V2  =  arrayfun(@(i) mean(V(i:i+6-1)),1:6:length(V)-6+1)'; % the averaged vector


W = Other_Elec.Data;
W = W(2:end,1);
W2  =  arrayfun(@(i) mean(W(i:i+6-1)),1:6:length(W)-6+1)'; % the averaged vector



unprocessedheatingElectricityProfiles(1:1440*days,i) = V2;
applianceElectricityProfiles(1:1440*days,i) = W2;

end

if variableASHP == 1
[heatingElectricityProfiles] = NETMODEL_postProcess(unprocessedheatingElectricityProfiles);
else
 heatingElectricityProfiles = unprocessedheatingElectricityProfiles;   
end

totalElectricityProfiles = heatingElectricityProfiles+applianceElectricityProfiles;

