function [ExtractRates]=AssignVentilationRates(floorOrCeilingArea,ventPattern,numRooms,roomVol)



for i=1:11
    
   if ventPattern(1,i)=='I'
       
       VPin(i,1)=-1;
       VPout(i,1)=0;
       
   elseif ventPattern(1,i)=='O'
       
       VPin(i,1)=0;
       VPout(i,1)=1;
       
   else
       
       VPin(i,1)=0;
       VPout(i,1)=0;
       
   end
    
end

if or(sum(VPin)==0,sum(VPout)==0)==0 %provided that some mech ventilation is assigned
perSecondExtractionRate=sum(roomVol)*0.3/3600;%total mechanical extraction Rate required In m3/s, using 0.3 ACR as base rate
extractionRateLo=perSecondExtractionRate*0.7;
extractionRateMid=perSecondExtractionRate*1;
extractionRateHi=perSecondExtractionRate*1.3;
TotalInFloorFractions=(floorOrCeilingArea(1,1:11)'.*VPin)/sum((-floorOrCeilingArea(1,1:11)'.*VPin));
TotalOutFloorFractions=(floorOrCeilingArea(1,1:11)'.*VPout)/sum((floorOrCeilingArea(1,1:11)'.*VPout));

ExtractRates=[(TotalInFloorFractions+TotalOutFloorFractions)*extractionRateLo,(TotalInFloorFractions+TotalOutFloorFractions)*extractionRateMid,(TotalInFloorFractions+TotalOutFloorFractions)*extractionRateHi];
ExtractRates=ExtractRates(1:numRooms,1:3);
else %all mechanical ventilation rates equal zero
    ExtractRates=zeros(numRooms,3);
end
end