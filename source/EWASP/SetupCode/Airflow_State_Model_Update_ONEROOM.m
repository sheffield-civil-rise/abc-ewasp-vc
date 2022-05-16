function [room2roomflowmatrix_N,room2roomflowmatrix_E,room2roomflowmatrix_S,room2roomflowmatrix_W,StateAirInEXPANDED_N,StateAirInEXPANDED_E,StateAirInEXPANDED_S,StateAirInEXPANDED_W,StateAirOutEXPANDED_N,StateAirOutEXPANDED_E,StateAirOutEXPANDED_S,StateAirOutEXPANDED_W,deltaPEXPANDED_N,deltaPEXPANDED_E,deltaPEXPANDED_S,deltaPEXPANDED_W,HCM,HCM_closed,VCM,numRooms]=Airflow_State_Model_Update_ONEROOM(C_d,HCM,HCM_closed,verticalConnectMatrix,NESW_Lengths,upDown,ACR,rotation,flip,bungalow,state)

numRooms=1;%determines how may pressure variables to use
NESW_Lengths=NESW_Lengths(1:4,1:11);
if numRooms < 11
NESW_Lengths(:,numRooms+1:11)=zeros(4,11-numRooms);
else
end

WindspeedLookUp=[0,1,2,3,5,8,12,15,18,21,25,30];
InDensityLookUp=[1.291, 1.246, 1.204];
InTemp=[0, 10, 20]; %actually represents difference between inside and outside temps

WinDirLookUp=['N', 'E', 'S', 'W'];

for dir=1:4
    
    WindDir=WinDirLookUp(1,dir);
    
for o=1:3
for i=1:12

    progress=(dir-1)*25+(o-1)*8.333+(i-1)*0.694;
    disp(sprintf('Airflow State %s Estimation %.1f percent complete',state,progress))
Windspeed=WindspeedLookUp(1,i);    
ThermostatSetting=InTemp(1,o);
roomHeight=2.4;

HCM=HCM(1:numRooms,1:numRooms);
VCM=verticalConnectMatrix(1:numRooms,1:numRooms);

HCM_closed=HCM_closed(1:numRooms,1:numRooms);

[ELA_H_Up,ELA_L_Up,ELA_H_Down,ELA_L_Down,ELA_H_Up2,ELA_L_Up2]=ELAZoneCalc(NESW_Lengths,upDown,roomHeight,ACR,WindDir,rotation,flip,bungalow);

ELA_H_Up=ELA_H_Up';
ELA_L_Up=ELA_L_Up';
ELA_H_Down=ELA_H_Down';
ELA_L_Down=ELA_L_Down';
ELA_H_Up2=ELA_H_Up2';
ELA_L_Up2=ELA_L_Up2';

ELA_H_Up=ELA_H_Up(1:numRooms,1);
ELA_L_Up=ELA_L_Up(1:numRooms,1);
ELA_H_Down=ELA_H_Down(1:numRooms,1);
ELA_L_Down=ELA_L_Down(1:numRooms,1);
ELA_H_Up2=ELA_H_Up2(1:numRooms,1);
ELA_L_Up2=ELA_L_Up2(1:numRooms,1);

TempVec=ones(1,numRooms)*ThermostatSetting;


TR1=repmat(TempVec,numRooms,1)'; %NEXT3 generate the temp difference matrix
TN1=repmat(TempVec,numRooms,1);
dTmat=TR1-TN1; % how much hotter row is than column

cT=(-4.6082E-21)*dTmat.^4 - (7.5431E-05)*dTmat.^3 - (2.5999E-18)*dTmat.^2 + (0.1354)*dTmat; %generate correct linear gradients to use for open neighbours

mT=-0.0005*abs(dTmat).^3 + 0.0301*abs(dTmat).^2 - 0.6426*abs(dTmat) + 7.0657; %generate correct constants to use for open neighbours



Tin=298;

HPWind=0.5*1.025*0.25*Windspeed^2;

LPWind=0.5*1.025*(-0.2)*Windspeed^2;

if bungalow == 1
    
    deltaPStack=1.292*1.2*9.81;  %stack deltaP between bottom and top of the room, assuming a typical room height of 2.4m
    
    PhUp2=HPWind-deltaPStack*2;
PlUp2=LPWind-deltaPStack*2;
PhUp=HPWind-deltaPStack;
PlUp=LPWind-deltaPStack;
PhDown=HPWind;
PlDown=LPWind;
    
else
    
    deltaPStackAout=1.292*0.6*9.81; %outdoor pressure at quarter room height
    deltaPStackBout=1.292*1.8*9.81; %outdoor pressure at 3/4 room height
    deltaPStackAin=InDensityLookUp(1,o)*0.6*9.81; %indoor pressure at quarter room height
    deltaPStackBin=InDensityLookUp(1,o)*1.8*9.81; %indoor pressure at 3/4 room height

deltaPStack=1.292*2.8*9.81; %stack deltaP between upstairs and downstairs


deltaPStack2=1.292*5.6*9.81; %stack deltaP between floor 2 and downstairs (floor1)


PhUp2=HPWind-deltaPStack2;
PlUp2=LPWind-deltaPStack2;

PhUp=HPWind-deltaPStack;
PlUp=LPWind-deltaPStack;

PhDown=HPWind;
PlDown=LPWind;


end

syms  p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11

PN=repelem([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11],11, 1);
PN=PN(1:numRooms,1:numRooms);
PR=PN.';


% OpenNeigh=(mT.*(PR-PN)+cT).*HCM;
% OpenNeighbour=sum(OpenNeigh,2);

OpenNeigh=1.5*(1.3*nthroot(2*(PR-PN).^3,5)).*HCM;
OpenNeigh(isnan(OpenNeigh))=0;
OpenNeighbour=sum(OpenNeigh,2);

% VerticalNeigh=((PR-PN)-2.8*InDensityLookUp(1,o)*9.81.*VCM).*abs(VCM)*91.5;
% VerticalNeighbour=sum(VerticalNeigh,2);

VerticalNeigh=InDensityLookUp(1,o)*C_d*(1.3*nthroot(1.63*((PR-PN)-2.8*InDensityLookUp(1,o)*9.81.*VCM).^3,5)).*abs(VCM);
VerticalNeighbour=sum(VerticalNeigh,2);


ClosedTGrad=repmat(((273.15+TempVec)*(-5.15e-6)+2e-3)',1,numRooms).*HCM_closed;
ClosedNeigh=ClosedTGrad.*nthroot((PR-PN).^3,5);

ClosedNeighbour=sum(ClosedNeigh,2);

if bungalow==1
   
High_Down=(ELA_H_Down/10000).*nthroot((PR(:,1)-PhDown).^3,5);
Low_Down=(ELA_L_Down/10000).*nthroot((PR(:,1)-PlDown).^3,5);
High_Up=(ELA_H_Up/10000).*nthroot(((PR(:,1)-9.81*InDensityLookUp(1,o)*1.2)-PhUp).^3,5);
Low_Up=(ELA_L_Up/10000).*nthroot(((PR(:,1)-9.81*InDensityLookUp(1,o)*1.2)-PlUp).^3,5);
High_Up2=(ELA_H_Up2/10000).*nthroot((PR(:,1)-PhUp2).^3,5);
Low_Up2=(ELA_L_Up2/10000).*nthroot((PR(:,1)-PlUp2).^3,5);
    
else

        deltaPStackAout=1.292*0.6*9.81; %outdoor pressure at quarter room height
    deltaPStackBout=1.292*1.8*9.81; %outdoor pressure at 3/4 room height
    deltaPStackAin=InDensityLookUp(1,o)*0.6*9.81; %indoor pressure at quarter room height
    deltaPStackBin=InDensityLookUp(1,o)*1.8*9.81; %indoor pressure at 3/4 room height

    
High_Down=0.5*(ELA_H_Down/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhDown-deltaPStackAout)  ).^3,5)+0.5*(ELA_H_Down/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhDown-deltaPStackBout)  ).^3,5);
Low_Down=0.5*(ELA_L_Down/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlDown-deltaPStackAout)  ).^3,5)+0.5*(ELA_L_Down/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlDown-deltaPStackBout)  ).^3,5);
High_Up=0.5*(ELA_H_Up/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhUp-deltaPStackAout)  ).^3,5)+0.5*(ELA_H_Up/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhUp-deltaPStackBout)  ).^3,5);
Low_Up=0.5*(ELA_L_Up/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlUp-deltaPStackAout)  ).^3,5)+0.5*(ELA_L_Up/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlUp-deltaPStackBout)  ).^3,5);
High_Up2=0.5*(ELA_H_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhUp2-deltaPStackAout)  ).^3,5)+0.5*(ELA_H_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhUp2-deltaPStackBout)  ).^3,5);
Low_Up2=0.5*(ELA_L_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlUp2-deltaPStackAout)  ).^3,5)+0.5*(ELA_L_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlUp2-deltaPStackBout)  ).^3,5);

end

f=(OpenNeighbour+VerticalNeighbour+ClosedNeighbour)+(High_Down+Low_Down+High_Up+Low_Up+High_Up2+Low_Up2); %add all components of the flow equations to give the full air balance expressions for each room
%[P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11]=solve(f==zeros(11,1),PR(:,1)); %Solve all of the flow equations

out=zeros(1,numRooms);



[out]=vpasolve(f(1:numRooms)==zeros(numRooms,1),PR(1:numRooms,1)); %Solve all of the flow equations

result=out;

%%
if numRooms == 11
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1}); p10=double(result{10,1}); p11=double(result{11,1});
elseif  numRooms == 10
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1}); p10=double(result{10,1});
elseif  numRooms == 9
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1});
elseif  numRooms == 8
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1});
elseif  numRooms == 7
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1});
elseif  numRooms == 6
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1});
elseif  numRooms == 5
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); 
elseif  numRooms == 4
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1});
elseif  numRooms == 3
p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1});
elseif  numRooms == 2
p1=double(result{1,1}); p2=double(result{2,1});
elseif  numRooms == 1
p1=double(result);
else
   error('room count must be between 1 and 11')
end

 PN=repelem([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11],11, 1);
 PN=PN(1:numRooms,1:numRooms);
 PR=PN.';

 %refine
%% THE FOLLOWING COMMENTED CODE RUNS THE EXACT ENERGYPLUS HORIZONTAL OPENING MODEL FOR 2000mm x 750mm OPEN DOORWAYS
%  IT USES THE OUTPUT OF THE APPROXIMATE METHOD TO DETERMINE THE SIGN OF THE AIR FLOW ACROSS EACH OPENING
%  AND USES THIS TO CONTRAIN THE RELATIONSHIP (HIGHER OR LOWER) BETWEEN
% EACH ZONE PRESSURE. USED IN THE RIGHT WAY, WE CAN PREVENT IMAGINARY ROOTS
% (WHICH ACTUALLY JUST REPRESENT FLOW INTO THE ROOM)IN THE SOLUTION

%WHILST YOU MAY RUN THIS, WE RECCOMEND AGAINST DOING SO, AS IT IS MUCH
%  SLOWER TO SOLVE AND GIVES ALMOST EXACTLY THE SAME RESULTS AS THE APPROXIMATION

%  PS1=(PR-PN);
%  PS2=abs(PR-PN);
%  Psign=double((PR-PN)./abs(PR-PN));
%  Psign(isnan(Psign))=0;
%  
%  syms  p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11
% 
% PN=repelem([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11],11, 1);
% PN=PN(1:numRooms,1:numRooms);
% PR=PN.';

% OpenNeigh=1.5*((2*(PR-PN).*Psign).^0.5).*Psign.*HCM;
% OpenNeigh(isnan(OpenNeigh))=0;
% OpenNeighbour=sum(OpenNeigh,2);
% 
% f=(OpenNeighbour+VerticalNeighbour+ClosedNeighbour)+(High_Down+Low_Down+High_Up+Low_Up+High_Up2+Low_Up2); %add all components of the flow equations to give the full air balance expressions for each room
% out=zeros(1,numRooms);
% [out]=vpasolve(f(1:numRooms)==zeros(numRooms,1),PR(1:numRooms,1),[-Inf*ones(numRooms,1) Inf*ones(numRooms,1)]); %Solve all of the flow equations
% result=struct2cell(out);
%  
% 
% if numRooms == 11
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1}); p10=double(result{10,1}); p11=double(result{11,1});
% elseif  numRooms == 10
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1}); p10=double(result{10,1});
% elseif  numRooms == 9
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1}); p9=double(result{9,1});
% elseif  numRooms == 8
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1}); p8=double(result{8,1});
% elseif  numRooms == 7
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1}); p7=double(result{7,1});
% elseif  numRooms == 6
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); p6=double(result{6,1});
% elseif  numRooms == 5
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1}); p5=double(result{5,1}); 
% elseif  numRooms == 4
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1}); p4=double(result{4,1});
% elseif  numRooms == 3
% p1=double(result{1,1}); p2=double(result{2,1}); p3=double(result{3,1});
% elseif  numRooms == 2
% p1=double(result{1,1}); p2=double(result{2,1});
% elseif  numRooms == 1
% p1=double(result{1,1});
% else
%    error('room count must be between 1 and 11')
% end
% 
%  PN=repelem([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11],11, 1);
%  PN=PN(1:numRooms,1:numRooms);
%  PR=PN.';

 %%
 


if bungalow==1
OutHD=(ELA_H_Down/10000).*nthroot((PR(:,1)-PhDown).^3,5);
OutLD=(ELA_L_Down/10000).*nthroot((PR(:,1)-PlDown).^3,5);
OutHU=(ELA_H_Up/10000).*nthroot(((PR(:,1)-9.81*InDensityLookUp(1,o)*1.2)-PhUp).^3,5);
OutLU=(ELA_L_Up/10000).*nthroot(((PR(:,1)-9.81*InDensityLookUp(1,o)*1.2)-PlUp).^3,5);
OutHU2=(ELA_H_Up2/10000).*nthroot((PR(:,1)-PhUp2).^3,5);
OutLU2=(ELA_L_Up2/10000).*nthroot((PR(:,1)-PlUp2).^3,5);
AirOut=double(max(OutHU2,zeros(numRooms,1))+max(OutLU2,zeros(numRooms,1))+max(OutHD,zeros(numRooms,1))+max(OutLD,zeros(numRooms,1))+max(OutHU,zeros(numRooms,1))+max(OutLU,zeros(numRooms,1)));
AirIn=double(min(OutHU2,zeros(numRooms,1))+min(OutLU2,zeros(numRooms,1))+min(OutHD,zeros(numRooms,1))+min(OutLD,zeros(numRooms,1))+min(OutHU,zeros(numRooms,1))+min(OutLU,zeros(numRooms,1)));
else
OutHDA=0.5*(ELA_H_Down/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhDown-deltaPStackAout)  ).^3,5);
OutLDA=0.5*(ELA_L_Down/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlDown-deltaPStackAout)  ).^3,5);
OutHUA=0.5*(ELA_H_Up/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhUp-deltaPStackAout)  ).^3,5);
OutLUA=0.5*(ELA_L_Up/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlUp-deltaPStackAout)  ).^3,5);
OutHUA2=0.5*(ELA_H_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PhUp2-deltaPStackAout)  ).^3,5);
OutLUA2=0.5*(ELA_L_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackAin)-(PlUp2-deltaPStackAout)  ).^3,5);

OutHDB=0.5*(ELA_H_Down/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhDown-deltaPStackBout)  ).^3,5);
OutLDB=0.5*(ELA_L_Down/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlDown-deltaPStackBout)  ).^3,5);
OutHUB=0.5*(ELA_H_Up/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhUp-deltaPStackBout)  ).^3,5);
OutLUB=0.5*(ELA_L_Up/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlUp-deltaPStackBout)  ).^3,5);
OutHUB2=0.5*(ELA_H_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PhUp2-deltaPStackBout)  ).^3,5);
OutLUB2=0.5*(ELA_L_Up2/10000).*nthroot((  (PR(:,1)-deltaPStackBin)-(PlUp2-deltaPStackBout)  ).^3,5);


AirOut=double(max(OutHUA2,zeros(numRooms,1))+max(OutLUA2,zeros(numRooms,1))+max(OutHDA,zeros(numRooms,1))+max(OutLDA,zeros(numRooms,1))+max(OutHUA,zeros(numRooms,1))+max(OutLUA,zeros(numRooms,1)))+double(max(OutHUB2,zeros(numRooms,1))+max(OutLUB2,zeros(numRooms,1))+max(OutHDB,zeros(numRooms,1))+max(OutLDB,zeros(numRooms,1))+max(OutHUB,zeros(numRooms,1))+max(OutLUB,zeros(numRooms,1)));
AirIn=double(min(OutHUA2,zeros(numRooms,1))+min(OutLUA2,zeros(numRooms,1))+min(OutHDA,zeros(numRooms,1))+min(OutLDA,zeros(numRooms,1))+min(OutHUA,zeros(numRooms,1))+min(OutLUA,zeros(numRooms,1)))+double(min(OutHUB2,zeros(numRooms,1))+min(OutLUB2,zeros(numRooms,1))+min(OutHDB,zeros(numRooms,1))+min(OutLDB,zeros(numRooms,1))+min(OutHUB,zeros(numRooms,1))+min(OutLUB,zeros(numRooms,1)));
end




%room2roomflowmatrix{i,o}=double((mT.*(PR-PN)+cT).*HCM+ClosedTGrad.*nthroot((PR-PN).^3,5)+(PR-PN-2.8*InDensityLookUp(1,o)*9.81.*VCM).*abs(VCM)*91.5); %openFlows+closedFlows+VerticalFlows

room2roomflowmatrix{i,o}=double(1.5*(1.3*nthroot((PR-PN).^3,5)).*HCM+ClosedTGrad.*nthroot((PR-PN).^3,5)+(PR-PN-2.8*InDensityLookUp(1,o)*9.81.*VCM).*abs(VCM)*91.5); %openFlows+closedFlows+VerticalFlows

StateAirIn{i,o}=-AirIn; %'-AirIn' Ensures that flow into the room is positive 
StateAirOut{i,o}=AirOut;


t1=abs((((PR-PN).*(VCM))-(2.8*InDensityLookUp(1,o)*9.81)).*abs(VCM));
deltaP(i,o)=mean(nonzeros(t1));
deltaP(isnan(deltaP))=0;

end
end

deltaP_NESW{dir,1}=deltaP;
room2roomflowmatrix_NESW{dir,1}=room2roomflowmatrix;
StateAirIn_NESW{dir,1}=StateAirIn;
StateAirOut_NESW{dir,1}=StateAirOut;

end


%%
room2roomflowmatrix_N=cell2mat(room2roomflowmatrix_NESW{1,1});
room2roomflowmatrix_E=cell2mat(room2roomflowmatrix_NESW{2,1});
room2roomflowmatrix_S=cell2mat(room2roomflowmatrix_NESW{3,1});
room2roomflowmatrix_W=cell2mat(room2roomflowmatrix_NESW{4,1});
StateAirInEXPANDED_N=cell2mat(StateAirIn_NESW{1,1});
StateAirOutEXPANDED_N=cell2mat(StateAirOut_NESW{1,1});
StateAirInEXPANDED_E=cell2mat(StateAirIn_NESW{2,1});
StateAirOutEXPANDED_E=cell2mat(StateAirOut_NESW{2,1});
StateAirInEXPANDED_S=cell2mat(StateAirIn_NESW{3,1});
StateAirOutEXPANDED_S=cell2mat(StateAirOut_NESW{3,1});
StateAirInEXPANDED_W=cell2mat(StateAirIn_NESW{4,1});
StateAirOutEXPANDED_W=cell2mat(StateAirOut_NESW{4,1});
deltaPEXPANDED_N=double(deltaP_NESW{1,1});
deltaPEXPANDED_E=double(deltaP_NESW{2,1});
deltaPEXPANDED_S=double(deltaP_NESW{3,1});
deltaPEXPANDED_W=double(deltaP_NESW{4,1});
 disp(sprintf('Airflow State %s Estimation 100 percent complete',state))
end