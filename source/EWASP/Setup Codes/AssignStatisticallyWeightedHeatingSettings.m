function [ThermostatSetting,DesiredDHWTemp,Tank_Volume_m3,DHWDemandProfile,ElecDemandProfile,HeatingOnProfile,tankExists,occupancyProfile]=AssignStatisticallyWeightedHeatingSettings(DHWDemandProfiles_OCC1,DHWDemandProfiles_OCC2,DHWDemandProfiles_OCC3,DHWDemandProfiles_OCC4,DHWDemandProfiles_OCC5,ElecDemandProfiles_OCC1,ElecDemandProfiles_OCC2,ElecDemandProfiles_OCC3,ElecDemandProfiles_OCC4,ElecDemandProfiles_OCC5,WDProfile,WEProfile,dayType,Tank_Exist_Probability,occ1_normalFabric,occ2_normalFabric,occ3_normalFabric,occ4_normalFabric,occ5_normalFabric,forcedOccupancy,occ)


x=rand()*10350;

if x < 600 
    
        ThermostatSetting=17;
    
    elseif (x>=600) && (x<2700)
        
        ThermostatSetting=18;
    
    elseif (x>=2700) && (x<3800)
        
        ThermostatSetting=19;
        
    elseif (x>=3800) && (x<7400)
        
        ThermostatSetting=20;
            
    elseif (x>=7400) && (x<9000)
        
        ThermostatSetting=21;
                
    elseif (x>=9000) && (x<10000)
        
        ThermostatSetting=22;
                    
    elseif (x>=10000) && (x<10350)
        
        ThermostatSetting=23;
                        
end

x=rand()*100;

if x < 6.5 
    
        DesiredDHWTemp=41;
    
    elseif (x>=6.5) && (x<14.5)
        
        DesiredDHWTemp=43;
    
    elseif (x>=14.5) && (x<24)
        
        DesiredDHWTemp=45;
        
    elseif (x>=24) && (x<34.5)
        
        DesiredDHWTemp=47;
            
    elseif (x>=34.5) && (x<44.75)
        
        DesiredDHWTemp=49;
                
    elseif (x>=44.75) && (x<55.5)
        
        DesiredDHWTemp=51;
                    
    elseif (x>=55.5) && (x<67.5)
        
        DesiredDHWTemp=53;
        
        elseif (x>=67.5) && (x<76.25)
        
        DesiredDHWTemp=55;
                    
    elseif (x>=76.25) && (x<85)
        
        DesiredDHWTemp=57;
        
        elseif (x>=85) && (100>=x)
        
        DesiredDHWTemp=59;
                        
end


x=rand()*100;

if x < 31 
    
       % occupancy=1
    r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC1(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC1(:,r);
    occupancyProfile=occ1_normalFabric(:,r);
    Tank_Volume_m3=0.1;%sized for a little larger than typical daily demand for given occupancy
    
    elseif (x>=31) && (x<65)
        
        % occupancy=2
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC2(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC2(:,r);
    occupancyProfile=occ2_normalFabric(:,r);
    Tank_Volume_m3=0.15;%sized for a little larger than typical daily demand for given occupancy
    
    elseif (x>=65) && (x<81)
        
        % occupancy=3
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC3(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC3(:,r);
    occupancyProfile=occ3_normalFabric(:,r);
    Tank_Volume_m3=0.2;%sized for a little larger than typical daily demand for given occupancy
    
    elseif (x>=81) && (x<93)
        
        % occupancy=4     
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC4(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC4(:,r);
    occupancyProfile=occ4_normalFabric(:,r);
    Tank_Volume_m3=0.25;%sized for a little larger than typical daily demand for given occupancy
    
        
    elseif (x>=93) && (x<100)
        
        % occupancy=5+
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC5(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC5(:,r);
    occupancyProfile=occ5_normalFabric(:,r);
    Tank_Volume_m3=0.3;%sized for a little larger than typical daily demand for given occupancy
    
    
else
end   
   
 if forcedOccupancy==1 %if we are forcing a given occupancy level
     
     if occ==1 
    
       % occupancy=1
    r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC1(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC1(:,r);
    occupancyProfile=occ1_normalFabric(:,r);
    Tank_Volume_m3=0.1;%sized for a little larger than typical daily demand for given occupancy
    
    elseif occ==2 
        
        % occupancy=2
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC2(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC2(:,r);
    occupancyProfile=occ2_normalFabric(:,r);
    Tank_Volume_m3=0.15;%sized for a little larger than typical daily demand for given occupancy
    
    elseif occ==3 
        
        % occupancy=3
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC3(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC3(:,r);
    occupancyProfile=occ3_normalFabric(:,r);
    Tank_Volume_m3=0.2;%sized for a little larger than typical daily demand for given occupancy
    
    elseif occ==4 
        
        % occupancy=4     
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC4(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC4(:,r);
    occupancyProfile=occ4_normalFabric(:,r);
    Tank_Volume_m3=0.25;%sized for a little larger than typical daily demand for given occupancy
    
        
    elseif occ>=5 
        
        % occupancy=5+
        r=randi([1,100]);
    DHWDemandProfile=DHWDemandProfiles_OCC5(:,r);
    ElecDemandProfile=ElecDemandProfiles_OCC5(:,r);
    occupancyProfile=occ5_normalFabric(:,r);
    Tank_Volume_m3=0.3;%sized for a little larger than typical daily demand for given occupancy
    
     else
     end
 else
 end





 x=randi([1 1000]);
    
    if dayType == 'WE'
        HeatingOnProfile=kron(WEProfile(:,x),ones(30,1));
    elseif dayType == 'WD'
        HeatingOnProfile=kron(WDProfile(:,x),ones(30,1));
    else
        error('dayType Must Equal WD (Weekday) or WE (Weekend Day)')
    end
    
    x=rand();
    
    if Tank_Exist_Probability>=x
        
        tankExists=1;
        
    else
        
        tankExists=0;
        
    end

end