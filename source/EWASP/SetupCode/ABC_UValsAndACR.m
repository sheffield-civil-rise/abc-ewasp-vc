function [ceilingU,wallU,floorU,windowU,doorU,ACRFix]=ABC_UValsAndACR(buildingType,buildingAge,systemWall,WallInsulationUpdgrade,floorInsulationUpgrade,ceilInsulationUpgrade)

UVals_Archetypes=[2.30000000000000,2.10000000000000,0.720000000000000,4.80000000000000,3,0.562500000000000,3.80000000000000;2.30000000000000,2.10000000000000,0.720000000000000,4.80000000000000,3,0.775000000000000,3.80000000000000;2.30000000000000,1.60000000000000,0.720000000000000,4.80000000000000,3,0.760000000000000,3.80000000000000;1.50000000000000,1.60000000000000,0.720000000000000,3.10000000000000,2,0.725000000000000,3.80000000000000;0.400000000000000,1.60000000000000,0.720000000000000,3.10000000000000,2,0.495000000000000,3.80000000000000;0.400000000000000,1.60000000000000,0.500000000000000,3.10000000000000,2,0.510000000000000,3.80000000000000;0.250000000000000,0.350000000000000,0.250000000000000,1.85000000000000,2,0.350000000000000,3.80000000000000;0.180000000000000,0.280000000000000,0.220000000000000,1.85000000000000,2,0.350000000000000,3.80000000000000;2.30000000000000,2.10000000000000,0.590000000000000,4.80000000000000,3,0.562500000000000,3.80000000000000;2.30000000000000,2.10000000000000,0.590000000000000,4.80000000000000,3,0.775000000000000,3.80000000000000;2.30000000000000,1.60000000000000,0.590000000000000,4.80000000000000,3,0.760000000000000,3.80000000000000;1.50000000000000,1.60000000000000,0.590000000000000,3.10000000000000,2,0.725000000000000,3.80000000000000;0.400000000000000,1.60000000000000,0.590000000000000,3.10000000000000,2,0.495000000000000,3.80000000000000;0.400000000000000,1.60000000000000,0.500000000000000,3.10000000000000,2,0.510000000000000,3.80000000000000;0.250000000000000,0.350000000000000,0.250000000000000,1.85000000000000,2,0.350000000000000,3.80000000000000;0.180000000000000,0.280000000000000,0.220000000000000,1.85000000000000,2,0.350000000000000,3.80000000000000];

if buildingType == 1
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 2
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 3
    
    a1=UVals_Archetypes(9:16,:);
    
elseif buildingType == 4
    
    a1=UVals_Archetypes(1:8,:);
    
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

if systemWall==1

wallU=UVals_Archetypes(1,2);
else 
end

if WallInsulationUpdgrade==1
   
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
    
else
    
end

if floorInsulationUpgrade==1
    
floorU=min(floorU,0.25);%install insulation to bring floor to minimum level of insulation according to current building regs - does nothing if already lower/the same
    
else
    
end

if ceilInsulationUpgrade==1
    
ceilingU=min(ceilingU,0.2); %install insulation to bring ceiling to minimum level of insulation according to current building regs - does nothing if already lower/the same
    
else
    
end

end