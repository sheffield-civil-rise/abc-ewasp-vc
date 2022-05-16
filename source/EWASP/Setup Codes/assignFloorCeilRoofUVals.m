function [RoomDataMatrix,IsTop]=assignFloorCeilRoofUVals(upDown,floorU,intermediateU,ceilingU,RoomDataMatrix,bungalow)

for i=1:size(upDown,1)
    
    if upDown(i,1)==min(upDown)

RoomDataMatrix(6,i)=floorU;
RoomDataMatrix(7,i)=intermediateU;
IsTop(1,i)=0;
    elseif upDown(i,1)==max(upDown)

RoomDataMatrix(6,i)=intermediateU;
RoomDataMatrix(7,i)=ceilingU;
IsTop(1,i)=1;

    elseif min(upDown) < upDown(i,1) < max(upDown)  
        
        RoomDataMatrix(6,i)=intermediateU;
        RoomDataMatrix(7,i)=intermediateU;
IsTop(1,i)=0;

    else
        
        error('elements of upDown matrix must equal either 0 for downstairs, 2 for upstairs top floor, and 1 for any floor inbetween ground and top')

    end

end

if bungalow == 1 %if building is a bungalow without a basement, assign floor and ceiling uvals with no intermediates
    
RoomDataMatrix(6,1:12)=floorU;
RoomDataMatrix(7,1:12)=ceilingU;
IsTop(1,1:12)=1;    

else
    
end

end
