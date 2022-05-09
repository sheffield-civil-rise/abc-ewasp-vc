function [woodPlasticHeatTransfertoroom,deltaTWoodPlasticMean,softHeatTransfertoroom,deltaTsoftMean]=FurnitureTransfer(roomArea,roomtype,roomTemp,TemperatureWoodPlastic,TemperatureSoft)

excessMeanWoodPlastic=TemperatureWoodPlastic-roomTemp;
excessMeanSoft=TemperatureSoft-roomTemp;

if roomtype=='L'
    
%carpetMass=roomArea*2.041;% 2.041kg/m2 based on  https://thecarpetstop.co.uk/buying-guides/#:~:text=These%20are%20given%20in%20ounces,commonly%20a%20more%20luxurious%20carpet.  
%underlayMass=roomArea*2.7;% 2.7kg/m2 based on https://www.carpet-underlay-shop.co.uk/products/duralay-durafit-650-15-07m2-from-5-74-per-m2
CurtainMass=15;
Sofafabricmass=10;% based on 2lb/ft^3 and 2 sofas - 3 seater and 2 seater https://furnitureblog.simplicitysofas.com/blog/what-is-the-difference-between-a-sofa-cushions-foam-density-and-firmness/ 
matressMass=0; %no beds
duvetandSheetsMass=0; %no beds

SoftMass=CurtainMass+Sofafabricmass;
woodPlasticMass=roomArea*20-SoftMass;

elseif roomtype =='B'

%carpetMass=roomArea*2.041;% 2.041kg/m2 based on  https://thecarpetstop.co.uk/buying-guides/#:~:text=These%20are%20given%20in%20ounces,commonly%20a%20more%20luxurious%20carpet.  
%underlayMass=roomArea*2.7;% 2.7kg/m2 based on https://www.carpet-underlay-shop.co.uk/products/duralay-durafit-650-15-07m2-from-5-74-per-m2
CurtainMass=15;
matressMass=40; %https://democracy.york.gov.uk/documents/s2116/Annex%20C%20REcycling%20Report%20frnweights2005.pdf
duvetandSheetsMass=5; %5kg based on %https://inthewash.co.uk/washing-machines/can-you-wash-a-king-size-duvet-in-an-8-9-10-kg-washing-machine/#:~:text=A%20king%20size%20duvet%20will,able%20to%20cope%20with%20them.
Sofafabricmass=0; %no sofa

SoftMass=CurtainMass+matressMass+duvetandSheetsMass;


woodPlasticMass=roomArea*30-SoftMass;
woodPlasticMass=roomArea*30-SoftMass;

else %room is other e.g. kitchen - assume heavily furnished, and majority wood or plastic
    
CurtainMass=0; %
matressMass=0; %
duvetandSheetsMass=0; %
Sofafabricmass=0; %no sofa

SoftMass=0;

woodPlasticMass=roomArea*35-SoftMass;
woodPlasticMass=roomArea*35-SoftMass;    
    
end





softDensityA=60;
softDensityB=80;
softThicknessA=0.15; %represents thicker furnishings (sofa foam etc.)
softThicknessB=0.01; %Represents thinner funishings (e.g. carpet)

SoftMassA=duvetandSheetsMass+Sofafabricmass+matressMass;
SoftMassB=CurtainMass;

SoftVolumeA=SoftMassA/softDensityA;
SoftVolumeB=SoftMassA/softDensityB;

approxSoftA_SA=(SoftVolumeA/softThicknessA);%no 2* here due to one surface usually being obscured
approxSoftB_SA=(SoftVolumeB/softThicknessB);%as above

Softradius=3*((SoftVolumeA+SoftVolumeB)/(approxSoftA_SA+approxSoftB_SA));
SoftbiotNumber=(10/0.03)*((SoftVolumeA+SoftVolumeB)/(approxSoftA_SA+approxSoftB_SA));% appropriate for typical soft furnishings with conductivity 0.03 w/mK and convective transfer coefficient 10 W/k m2 
SoftFBI=1/(0.282*SoftbiotNumber+0.944);
excessSurfSoft=SoftFBI*excessMeanSoft;
softHeatTransfertoroom=excessSurfSoft*10*(approxSoftA_SA+approxSoftB_SA)
deltaTsoftMean=softHeatTransfertoroom/(softDensityA*SoftVolumeA*1400+softDensityB*SoftVolumeB*1400)

if isnan(deltaTsoftMean)==1
deltaTsoftMean=0;
else
end
    
woodPlasticDensity=800; %600kg/m^3 as of Influence of internal thermal mass on the indoor thermal dynamics and integration of phase change materials in furniture for building energy storage: A review
woodPlasticThickness=0.018; %0.018m typical as of as of Influence of internal thermal mass on the indoor thermal dynamics and integration of phase change materials in furniture for building energy storage: A review
woodPlasticVolume=woodPlasticMass/woodPlasticDensity;
approxWoodPlasticSA=(woodPlasticVolume/woodPlasticThickness); %a rough surface area calculation for the wooden elements

radius=3*woodPlasticVolume/approxWoodPlasticSA;
biotNumber=(10/0.2)*(woodPlasticVolume/approxWoodPlasticSA);% appropriate for typical wood with conductivity 0.2 w/mK and convective transfer coefficient 10 W/k m2 
FBI=1/(0.282*biotNumber+0.944);
excessSurfWoodPlastic=FBI*excessMeanWoodPlastic;
woodPlasticHeatTransfertoroom=excessSurfWoodPlastic*10*approxWoodPlasticSA
deltaTWoodPlasticMean=woodPlasticHeatTransfertoroom/(800*woodPlasticVolume*1700)% heat capacity of wodd and plastic is assumer 1700 J/Kg, they are very close in capacity anyway (1.76 wood, 1.67 plastic)

deltaTWoodPlasticMean(isnan(deltaTWoodPlasticMean))=0;

softHeatTransfertoroom(isnan(softHeatTransfertoroom))=0;

%end
