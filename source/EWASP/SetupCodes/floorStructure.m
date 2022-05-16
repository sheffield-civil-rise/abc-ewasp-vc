function [dwnAndConcrete]=floorStructure(upDown,floortype)

if size(upDown,1)<11
    upDown(end+1:11,1)=0;
else
    
end

if floortype==1
    
    for i=1:11
        
        if upDown(i,1)==0
           dwnAndConcrete(i,1)=1;
        else
           dwnAndConcrete(i,1)=0; 
        end

    end
    
else
    
    dwnAndConcrete(1:11,1)=0;
end

end