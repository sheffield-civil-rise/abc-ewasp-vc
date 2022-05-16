
function [neighbourMatrix,convUDMatrix]= simpleConvectionMatrices(horizontalConnectMatrix,verticalConnectMatrix)


for i=1:11
    
    t1(1:5,i)=i;
     k=1;
        
    for o=1:11
        
       if horizontalConnectMatrix(i,o) == 1
           
           if k>5
               error(sprintf('No room may connect horizontally to more than 5 other rooms - row %i of the matrix contains more than this',i))
           else
           t1(k,i)=o;
           k=k+1;
           end
       elseif horizontalConnectMatrix(i,o) == 0
           
       else
           
           error('elements of the horizontalConnectMatrix may only be 0 or 1')
           
       end
        
           
    end
    
end

neighbourMatrix=t1;

for i=1:11
    
   for o=1:11 

       if and(horizontalConnectMatrix(i,o) ~= horizontalConnectMatrix(o,i),horizontalConnectMatrix(i,o)>0)
           
           warning(sprintf('Neighbour connections are not consistent: rooms %i is next to room %i according to row %i, but room %i is not next to room %i according to row %i',i,o,i,o,i,o))

       else
           
       end
       
   end
   
end


clear t1 k o i

for i=1:11
    
    t2(1:2,i)=i;
     k=1;
        g=1;
    for o=1:11
        
       
       if verticalConnectMatrix(i,o) == 1
           
           if k>1
               error(sprintf('No room may connect vertically UPWARDS to more than 1 other room - row %i of the matrix contains more than this',i))
           else
           t2(1,i)=o;
           k=k+1;
           end
           
       elseif verticalConnectMatrix(i,o) == -1
           
           if g>1
               error(sprintf('No room may connect vertically DOWNWARDS to more than 1 other room - row %i of the matrix contains more than this',i))
           else
           t2(2,i)=o;
           g=g+1;
           end   
           
           elseif verticalConnectMatrix(i,o) == 0
               
       else          
           error('elements of the verticallConnectMatrix may only be -1, 0, or 1')         
       end
  
    end
    
end


for i=1:11
    
    
   for o=1:11 
    
       
       if and(verticalConnectMatrix(i,o) ~= -verticalConnectMatrix(o,i),verticalConnectMatrix(i,o)>0)
           
           warning(sprintf('Up-Down connections are not consistent: rooms %i is above room %i according to row %i, but room %i is not below room %i according to row %i',o,i,i,i,o,o))
          
       elseif and(verticalConnectMatrix(i,o) ~= -verticalConnectMatrix(o,i),verticalConnectMatrix(i,o)<0) 
           
           warning(sprintf('Up-Down connections are not consistent: rooms %i is below room %i according to row %i, but room %i is not above room %i according to row %i',o,i,i,i,o,o))
           
       else
           
       end
       
   end
end

convUDMatrix=t2;

clear i o g t2 k

end