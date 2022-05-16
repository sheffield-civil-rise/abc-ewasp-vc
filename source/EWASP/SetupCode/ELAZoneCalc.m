function [ELA_H_Up,ELA_L_Up,ELA_H_Down,ELA_L_Down,ELA_H_Up2,ELA_L_Up2]=ELAZoneCalc(NESWLengths,upDown,roomHeight,ACR,WindDir,rotation,flip,bungalow)

%%This function converts the leakage area of the upstairs and downstairs
%%north, east, south, and west walls of a room to the upstairs high pressure, 
%%upstairs low pressure, downstairs high pressure and downstairs low 
%%pressure leakage areas of the room. This allows easier wind effect and
%%stack effect analysis of the building envelope.

%INPUTS example:

% upDn=[0 0 0 0 1 1 1 1 1 1 1];
% WindDir='N';
% rotation=0;%turns the house enveloped the specified number of degrees (must be quarter circles)
% flip='N';%mirror images the house (west becomes east, east becomes west)
ACR=ACR(1,1:11);
 N=(NESWLengths(1,:).*ACR)*roomHeight*7.24;
 E=(NESWLengths(2,:).*ACR)*roomHeight*7.24;
 S=(NESWLengths(3,:).*ACR)*roomHeight*7.24;
 W=(NESWLengths(4,:).*ACR)*roomHeight*7.24;

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

if WindDir =='N'
    
    HP=N;
    LP=E+S+W;
    
elseif WindDir =='E'
    
    HP=E;
    LP=N+S+W;
    
elseif WindDir =='S'
    
    HP=S;
    LP=N+E+W;
    
elseif WindDir =='W'
    
    HP=W;
    LP=N+E+S;
    
else
    
    error('WindDir must equal N, E, W, or S')
    
end


%initialise ELA arrays by setting all components to zero
ELA_H_Down=zeros(1,11);
ELA_L_Down=zeros(1,11);
ELA_H_Up=zeros(1,11);
ELA_L_Up=zeros(1,11);
ELA_H_Up2=zeros(1,11);
ELA_L_Up2=zeros(1,11);        


for i=1:size(upDown,1)
    
    if upDown(i,1) == 1 %room is upstairs
        
ELA_H_Down(1,i)=0; %the downstairs high pressure wall leakage are associated with this room is set to zero
ELA_L_Down(1,i)=0; %the downstairs low pressure wall leakage are associated with this room is set to zero
ELA_H_Up(1,i)=HP(1,i); %the upstairs high pressure wall leakage are associated with this room is set to the value in HP
ELA_L_Up(1,i)=LP(1,i); %the upstairs low pressure wall leakage are associated with this room is set to the value in HP
ELA_H_Up2(1,i)=0; 
ELA_L_Up2(1,i)=0;

    elseif upDown(i,1) == 2 %room is on 2nd floor/loft conversion
        
ELA_H_Down(1,i)=0; %the downstairs high pressure wall leakage are associated with this room is set to zero
ELA_L_Down(1,i)=0; %the downstairs low pressure wall leakage are associated with this room is set to zero
ELA_H_Up(1,i)=0; %the upstairs high pressure wall leakage are associated with this room is set to the value in HP
ELA_L_Up(1,i)=0; %the upstairs low pressure wall leakage are associated with this room is set to the value in LP
ELA_H_Up2(1,i)=HP(1,i); %the upstairs high pressure wall leakage are associated with this room is set to the value in HP
ELA_L_Up2(1,i)=LP(1,i);

    elseif upDown(i,1) == 0 %if room is downstairs
        
ELA_H_Up(1,i)=0; %opposite of above - assign leakage ares to downstairs high and low pressure walls
ELA_L_Up(1,i)=0; 
ELA_H_Down(1,i)=HP(1,i); 
ELA_L_Down(1,i)=LP(1,i); 
ELA_H_Up2(1,i)=0; 
ELA_L_Up2(1,i)=0;
        
        
    else
        
        error('all elements of updn must equal 1 (upstairs) or 0 (downstairs) or 2 (2nd floor/loft conversion)')
        
    end     
    
end


if bungalow==1
        
        for i=1:size(upDown,1)
            
ELA_H_Up(1,i)=HP(1,i)/2; %model the top half of the room as upper ELA and bottom half as lower, thus allowing air to enter the envelop and leave within the same room on the vertical axis
ELA_L_Up(1,i)=LP(1,i)/2; 
ELA_H_Down(1,i)=HP(1,i)/2; 
ELA_L_Down(1,i)=LP(1,i)/2; 
ELA_H_Up2(1,i)=0; 
ELA_L_Up2(1,i)=0;
            
        end
        
    else
        
end
