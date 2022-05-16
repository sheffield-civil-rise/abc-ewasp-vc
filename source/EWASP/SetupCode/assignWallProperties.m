function [wallDensity,wallHeatCapacityInt,wallHeatCapacityMid,wallHeatCapacityOut]=assignWallProperties(buildingAge)

%selects correct wall thickness,density, and hear capacity from
%buildingAge, predicted from typical construction during the period

if buildingAge < 1920
    
    %wallThickness=0.215; %(m)
wallDensity=2000; %(kg/m^3)
wallHeatCapacityInt=168000; %(j/k/kg)
wallHeatCapacityMid=8000;
wallHeatCapacityOut=168000;
    
elseif (1919 < buildingAge) && (buildingAge < 1930)
    
    %wallThickness=0.265; %(m)
wallDensity=1625; %(kg/m^3)
wallHeatCapacityInt=172000; %(j/k/kg)
wallHeatCapacityMid=500;
wallHeatCapacityOut=172000;
    
elseif (1929 < buildingAge) && (buildingAge < 1970)
    
   %wallThickness=0.372; %(m)
wallDensity=1445; %(kg/m^3)
wallHeatCapacityInt=172000; %(j/k/kg)
wallHeatCapacityMid=500;
wallHeatCapacityOut=322500;

elseif (1969 < buildingAge) && (buildingAge < 1990)
    
    %wallThickness=0.372; %(m)
wallDensity=954; %(kg/m^3)
wallHeatCapacityInt=172000; %(j/k/kg)
wallHeatCapacityMid=500;
wallHeatCapacityOut=139750;

    
elseif (1989 < buildingAge) && (buildingAge < 2020)
    
    %wallThickness=0.275; %(m)
wallDensity=5250; %(kg/m^3)
wallHeatCapacityInt=164800; %(j/k/kg)
wallHeatCapacityMid=5250;
wallHeatCapacityOut=65000;

elseif 2019 < buildingAge
    
    %In the passivehouse model, we assume the majority of the walls thermal
    %mass is made up of 240mm thick sandstone, with density 2323
    %kg/m3, and heat capaity 0.92 kJ/K/kg, which translates to 520006 J/m2
    %f wall, which is split into 3 for the 3 node wall model
    %wallThickness=0.275; %(m)
wallDensity=2323; %(kg/m^3)
wallHeatCapacityInt=173335; %(j/k/kg/m2)
wallHeatCapacityMid=173335;
wallHeatCapacityOut=173335;
    
else 
    
    error('Only integer numbers may be input for buildingAge')
    
end