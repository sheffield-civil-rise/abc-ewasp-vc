
roomArea=20;
roomtype='O';

roomTemp=21;
TemperatureWoodPlastic=22;
TemperatureSoft=24;



[woodPlasticHeatTransfertoroom,deltaTWoodPlasticMean,softHeatTransfertoroom,deltaTsoftMean]=FurnitureTransfer(roomArea,roomtype,roomTemp,TemperatureWoodPlastic,TemperatureSoft);
