function [d]=makecondUDMatrix(conductiveConnectMatrix)

for i=1:11
       
       if sum(conductiveConnectMatrix(i,:) == 1) == 2
           
            k=1;
            
            for o=1:11
                  
                  if conductiveConnectMatrix(i,o) == 1
                  d(k+2,i)=o;
                  k=k+1;
                  else
                  end
           
            end
            
       elseif sum(conductiveConnectMatrix(i,:) == 1) == 1
           
            for o=1:11
                  
                  if conductiveConnectMatrix(i,o) == 1
                  d(3:4,i)=[o;o];
                  
                  else
                  end
           
            end
                 
            elseif sum(conductiveConnectMatrix(i,:) == 1) == 0
                
                d(3:4,i)=[14;14]; %assume that it is the loftspace/outside above
           
       else
           
           error('In conductiveConnectMatrix, there must be between 0 and 2 entries with the value 1 in each row')
    
       end
     
       if sum(conductiveConnectMatrix(i,:) == -1) == 2
           
            k=1;
            
            for o=1:11
                  
                  if conductiveConnectMatrix(i,o) == -1
                  d(k,i)=o;
                  k=k+1;
                  else
                  end
           
            end
            
       elseif sum(conductiveConnectMatrix(i,:) == -1) == 1
           
            for o=1:11
                  
                  if conductiveConnectMatrix(i,o) == -1
                  d(1:2,i)=[o;o];
                  
                  else
                  end
           
            end
                        
            elseif sum(conductiveConnectMatrix(i,:) == -1) == 0
                
                d(1:2,i)=[13;13]; %assume that it is floorspace/concrete slab below         
       else
           
           error('In conductiveConnectMatrix, there must be between 0 and 2 entries with the value -1 in each row')
    
       end

end