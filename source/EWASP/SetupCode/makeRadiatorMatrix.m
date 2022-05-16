function [radiatorMatrix,massFlowMatrix]=makeRadiatorMatrix(roomUse,frenchDoors,HPSized,RoomDataMatrix,DesiredDeltaT,buildingAge,forceTen)


for i=1:12
   
    if roomUse(1,i)=='L'
        
        a(1,i)=RoomDataMatrix(12,i)*35.3147*5/3412.142;
        
    elseif roomUse(1,i)=='B'
        
        a(1,i)=RoomDataMatrix(12,i)*35.3147*4/3412.142;
        
    elseif roomUse(1,i)=='O'
        
        a(1,i)=RoomDataMatrix(12,i)*35.3147*3/3412.142;
        
    elseif  roomUse(1,i)==' '
    
        a(1,i)=0;
        
    else
        
        error('roomUse elements must always take values L, B, O or a single blank space')
        
    end
    
end



if HPSized=='Y';
    
    a=a*(1/((25/40)^1.3));
    
elseif HPSized=='N'
    
else
   
    error('HPSized must equal Y or N')
    
end



for i=1:12

if frenchDoors(1,i)=='Y'
    
    a(1,i)=a(1,i)+a(1,i)*0.2;
    
elseif frenchDoors(1,i)=='N'
    
    
else
   
    error('All elements of frenchDoors must equal Y or N')
    
end

end



for i=1:12

if RoomDataMatrix(1,i)>=2.8
    
    
    
elseif RoomDataMatrix(1,i)<2.8
    
    a(1,i)=a(1,i)-a(1,i)*0.1;
    
else
   
    error('All elements of frenchDoors must equal Y or N')
    
end

end

for i=1:12

if roomUse(1,i)=='L'
        
        b(1,i)=22;
        
    elseif roomUse(1,i)=='B'
        
        b(1,i)=18;
        
    elseif roomUse(1,i)=='O'
        
        b(1,i)=18;
        
    elseif  roomUse(1,i)==' '
    
        b(1,i)=0;
        
    else
        
        error('roomUse elements must always take values L, B, O or a single blank space')
        
    end

end

radiatorMatrix=[
 40*ones(1,12)
 1000*a*1.3
 b
 ((1000*a)/196)*1.3
];

if forceTen==1
    
 radiatorMatrix(4,:)=max(radiatorMatrix(4,:),12*ones(1,12));
    
else
    
    
end


    if HPSized=='Y'
massFlowMatrix=((radiatorMatrix(2,:)/1.8)/(4200*DesiredDeltaT))*1.3

    elseif HPSized=='N'
        
massFlowMatrix=((radiatorMatrix(2,:))/(4200*DesiredDeltaT))*1.3    
    
    else
    
error('HPSized must equal Y or N')

    end


    if buildingAge >= 2020 %heavily reduce the size of the hydronic system
       
        radiatorMatrix(2,:)=radiatorMatrix(2,:)*0.25;
        radiatorMatrix(4,:)=radiatorMatrix(4,:)*0.25;
        massFlowMatrix=massFlowMatrix*0.25;
        
    else
        
    end
    
end