function [a]=determineHeatPumpMultiplier(upDown,RoomDataMatrix,ACRFix,NESW_wallArea,windowArea,floorOrCeilingArea,wallU,windowU,ceilingU,floorU,HPdT,HPType)


updn2=ones(11,1);
updn2(upDown>min(upDown))=0;
updn3=ones(11,1);
updn3(upDown<max(upDown))=0;
ExpectedACRLoss=sum(RoomDataMatrix(12,:))*1.225*ACRFix*(1/3600)*HPdT*1000;
ExpectedWallLoss=sum(sum(NESW_wallArea))*HPdT*wallU;
ExpectedWinLoss=sum(windowArea)*HPdT*windowU;
ExpectedRoofLoss=sum(floorOrCeilingArea(1,1:11).*updn3')*HPdT*ceilingU;
ExpectedFloorLoss=sum(floorOrCeilingArea(1,1:11).*updn2')*HPdT*floorU;

Loss=ExpectedACRLoss+ExpectedWallLoss+ExpectedWinLoss+ExpectedRoofLoss+ExpectedFloorLoss;
a=1.2*(Loss/4000);

if HPType=='G' %if GSHP, then dowsize by 1/3 to account for much lower temp variations to deal with
    a=a*0.667;
else
    
end
end