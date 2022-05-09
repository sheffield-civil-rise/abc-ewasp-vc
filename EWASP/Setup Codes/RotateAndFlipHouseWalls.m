function [NESWLengths]=RotateAndFlipHouseWalls(NESWLengths,rotation,flip)

%%This function flip the buildings wall lengths to create its mirror image
%%if desired, then rotates the building by 0, 90,180,270, or 360 degrees

%INPUTS example:

% rotation=0;%turns the house enveloped the specified number of degrees (must be quarter circles)
% flip='N';%mirror images the house (west becomes east, east becomes west)

 N=(NESWLengths(1,:));
 E=(NESWLengths(2,:));
 S=(NESWLengths(3,:));
 W=(NESWLengths(4,:));

if flip == 'Y'
    
    E1=E;
    W1=W;
    E=W1;
    W=E1;
    
    clear N1 E1 W1 S1
    
elseif flip =='N'
    
    %do nothing
    
else
    
    error('flip parameter must take a Y or N value')
    
end

if rotation == 0
    
elseif rotation == 90 %previous north face is now pointing east
    
    N1=N;E1=E;S1=S;W1=W;
    
    E=N1; %north properties are applied to east face 
    S=E1; %east properties are applied to south face 
    W=S1; %south properties are applied to west face 
    N=W1; %west properties are applied to north face 
    clear N1 E1 W1 S1
    
elseif rotation == 180 %previous north face is now pointing south
    
    N1=N;E1=E;S1=S;W1=W;
    
    E=W1; %west properties are applied to east face 
    S=N1; %north properties are applied to south face 
    W=E1; %east properties are applied to west face 
    N=S1; %south properties are applied to north face
    
    clear N1 E1 W1 S1
    
elseif rotation == 270 %previous north face is now pointing west
    
    N1=N;E1=E;S1=S;W1=W;
    
    E=S1; %south properties are applied to east face 
    S=W1; %west properties are applied to south face 
    W=N1; %north properties are applied to west face 
    N=E1; %east properties are applied to north face 
    
    clear N1 E1 W1 S1
    
else
    
    error('building rotation must be 0,90,180, or 270 degrees')
    
end

 NESWLengths(1,:)=N;
 NESWLengths(2,:)=E;
 NESWLengths(3,:)=S;
 NESWLengths(4,:)=W;

