function [ceilingU,wallU,floorU,windowU,doorU,ACRFix,intfloor]=assignUValsAndACR2(buildingType,buildingAge,UVals_Archetypes,wallRetrofit_1,systemWall,floorInsulationUpgrade,ceilInsulationUpgrade);




if buildingType == 1
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 2
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 3
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 4
    
    a1=UVals_Archetypes(1:8,:);
    
elseif buildingType == 5  
    
    a1=UVals_Archetypes(25:32,:);
    
else 
    
    error('buildingType must equal either 1(endTerraced), 2(midTerraced), 3(semi), or 4(detached)')
    
end




if buildingAge < 1919
    
    a2=a1(1,:);
    
elseif (1918 < buildingAge) && (buildingAge < 1945)
    
    a2=a1(2,:);
    
elseif (1944 < buildingAge) && (buildingAge < 1965)
    
    a2=a1(3,:);
    
elseif (1964 < buildingAge) && (buildingAge < 1981)
    
    a2=a1(4,:);
    
elseif (1980 < buildingAge) && (buildingAge < 1991)
    
    a2=a1(5,:);
    
elseif (1990 < buildingAge) && (buildingAge < 2004)
    
    a2=a1(6,:);
    
elseif (2003 < buildingAge) && (buildingAge < 2010)
    
    a2=a1(7,:);
    
elseif (2009 < buildingAge) 
    
    a2=a1(8,:);
    
else 
    
    error('Only integer numbers may be input for buildingAge')
    
end

ceilingU=a2(1,1);
wallU=a2(1,2);
floorU=a2(1,3);
windowU=a2(1,4);
doorU=a2(1,5);
ACRFix=a2(1,6);
intfloor=2; %Typical uval for an intermediatefloor



if wallRetrofit_1==1
   
    if or(buildingAge < 1919, systemWall==1) %if building is old enough to have solid wall, or has a solid system concrete wall
    
    wallU=0.27; %external EPS 100mm
    
elseif (1918 < buildingAge) && (buildingAge < 1965)
    
    wallU=0.5; %external EPS 100mm; %fill cavity
    
elseif (1964 < buildingAge) && (buildingAge < 1991)
    
     wallU=0.5; %external EPS 100mm;
    
elseif (1990 < buildingAge) 
    
     wallU=0.2; %cavity is already filled, so add internal EPS 50mm
    
else 
    
    error('Only integer numbers may be input for buildingAge')
    
end

if floorInsulationUpgrade == 1

    floorU=0.25;

else
    
end

if ceilInsulationUpgrade == 1

    ceilingU=0.25;

else
    
end

if buildingAge >= 2020
   
ceilingU=0.1;
wallU=0.137;
floorU=0.12;
windowU=0.75;
doorU=0.5;
ACRFix=0.03;
intfloor=2; %Typical uval for an intermediatefloor 
    
else
    
end

end