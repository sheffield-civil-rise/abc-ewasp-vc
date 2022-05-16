
function [processedProfiles]=NETMODEL_postProcess(inputProfiles)

%Softens pump starts, timeshifts synchronised profiles


for o=1:size(inputProfiles,2)
A=inputProfiles(1:1440,o);
for i=3:1440
   
if A(i-1,1)<10
    
    A(i,1)=A(i,1)*0.3;
else
end
    
if A(i-2,1)<10
    
    A(i,1)=A(i,1)*0.6;
else
end

end

if o<50
    A(240:244,1)=0;
    A(360:367,1)=0;
    A(480:487,1)=0;
    
end

if o<75
A(1:10,1)=0;
end

A=circshift(A,randi([-60 60],1));
processedProfiles(1:1440,o)=A;
end

end


