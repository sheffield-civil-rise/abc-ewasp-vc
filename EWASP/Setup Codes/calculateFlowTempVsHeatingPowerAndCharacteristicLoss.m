function [DesiredFlowTempVsInOutDeltaTemp]=calculateFlowTempVsHeatingPowerAndCharacteristicLoss(ThermostatSetting,RadiatorMatrix,buildingSize,buildingType,buildingAge,systemWall,WallInsulationUpdgrade,floorInsulationUpgrade,ceilInsulationUpgrade,scaleFactor)



%calculate available radiator power at steady state point as a function of flow temperature  

%calc available power
for i=1:12
    if RadiatorMatrix(3,i)>ThermostatSetting %TRVs are set higher than room thermostat
b1(1,i)=RadiatorMatrix(2,i); %radiator will operate when trying to heat reference zone
    else%TRVs will have turned radiator off by this point, so effectively radiators arent doing anything for when heat pump is trying to hold room temp, so remove them from this sum
 b1(1,i)=0;    
    end
end



%%

for i=1:35
   
Tnode1=i-1+30;
Tnode2=Tnode1-7; 
T_AV=(Tnode1+Tnode2)/2;
    
radiatorHeatOut=(sum(b1)/RadiatorMatrix(1,1)^1.3)*((Tnode1-Tnode2)/log((Tnode1-ThermostatSetting)/(Tnode2-ThermostatSetting)))^1.3;
PowerCurveFlowTemp(i,1)=real(radiatorHeatOut); %Power out of Radiators as a function of flow temperature, from 30->65oC 

end
%
%


[ceilingU1,wallU1,floorU1,windowU1,doorU1,ACR1]=ABC_UValsAndACR(buildingType,buildingAge,systemWall,WallInsulationUpdgrade,floorInsulationUpgrade,ceilInsulationUpgrade);

[wallArea1,winArea1,floorArea1,ceilArea1,DoorArea1,AirVol1]=ABC_FabricAreaCalculation(buildingAge,buildingType,buildingSize);   

LossFactor=wallArea1*wallU1+winArea1*windowU1+floorArea1*floorU1+ceilArea1*ceilingU1+((ACR1/3600)*AirVol1*1.275*720);

PowerVsDeltaT=repmat(LossFactor,36,1).*(0:35)';

%% 
%Calculates the desired flow temperature as function of ouitdoor temperature, by
% finding the intercept of PowerVsDeltaT (house heat loss as a function of outdoor temp) and PowerCurveFlowTemp
%(house heat gain as a function of flow temp) - i.e. finds the blanace point flow temp

for i=1:36
    
    RequiredHeatingPower=PowerVsDeltaT(i,1);
    
A1=abs(PowerCurveFlowTemp-RequiredHeatingPower);

[~,I] = min(A1);

DesiredFlowTempVsInOutDeltaTemp(i,1)=(I*scaleFactor)+30;%The flow temp required as a function of 
end

for i=1:36
   
    smoothGraph(i,1)=DesiredFlowTempVsInOutDeltaTemp(1,1)+((DesiredFlowTempVsInOutDeltaTemp(36,1)-DesiredFlowTempVsInOutDeltaTemp(1,1))*i/36);
    
end

DesiredFlowTempVsInOutDeltaTemp=smoothGraph;
