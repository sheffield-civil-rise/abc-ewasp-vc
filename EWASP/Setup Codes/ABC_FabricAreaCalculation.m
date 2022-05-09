
function [wallArea,winArea,FloorArea,CeilArea,DoorArea,AirVol]=ABC_FabricAreaCalculation(buildingAge,buildingType,buildingSize)    

gndFlr=[47,47,58,95;41,41,43,66;35,35,37,65;41,41,41,65];
extWall=[58.8500000000000,94.1000000000000,115.200000000000,175.500000000000;38.3000000000000,75.2000000000000,69.3000000000000,121.600000000000;29.3500000000000,67.5000000000000,65.4000000000000,97.7500000000000;27.1000000000000,72.2000000000000,71.1000000000000,118.500000000000];
win=[12,12,22,22;13,13,19,15;18,18,14,27;16,16,13,16];

if buildingAge < 1919
    
    AgeBracket=1;
    
elseif (1918 < buildingAge) && (buildingAge < 1965)
    
    AgeBracket=2;
    
elseif (1964 < buildingAge) && (buildingAge < 1991)
    
     AgeBracket=3;
    
elseif (1990 < buildingAge) 
    
     AgeBracket=4;
    
else 
    
    error('Only integer numbers may be input for buildingAge')
    
end


wallArea=extWall(AgeBracket,buildingType);
winArea=win(AgeBracket,buildingType);
FloorArea=gndFlr(AgeBracket,buildingType);
CeilArea=gndFlr(AgeBracket,buildingType);
DoorArea=2;
AirVol=FloorArea*5; %Assumes 5m wall height

if buildingSize == 'S'
    
wallArea=wallArea*0.85;
winArea=winArea*0.85;
FloorArea=FloorArea*0.85;
CeilArea=FloorArea;
DoorArea=2;
    
AirVol=FloorArea*(5*0.85); %Assume house height also scales down

elseif buildingSize == 'L'
        
wallArea=wallArea*1.15;
winArea=winArea*1.15;
FloorArea=FloorArea*1.15;
CeilArea=FloorArea;
DoorArea=2;    

AirVol=FloorArea*(5*1.15); %Assume house height also scales up 

elseif buildingSize == 'N'
        

    
else
    
    error('size must take the value S (small), N (normal), or L (large)')
end
end