
TempVector=[20;20;21;19;18;18;18;18;20;21;19];
TempRoomRow=repmat(TempVector,1,11);
wallU=2.1;
%TmpRoomCol=[]
SurfaceHeatCapPerM2=(0.0155*1*1)*800*1090; %plaster specs thickness=(0.0125m plasterboard+0.003m skim), 1090 j/k/kg, 800kg/m3


wallTempOuter=20*ones(11,11);
wallTempOuter(1,:)=15;

conductiveHconnectMatrix=[
0	3.3	0	3.1	0	0	0	0	0	0	0
3.3	0	0	3.8	0	0	0	0	0	0	0
0	0	0	4.1	0	0	0	0	0	0	0
3.1	3.8	4.1	0	0	0	0	0	0	0	0
0	0	0	0	0	4.3	0.6	3.9	2.8	0	2
0	0	0	0	4.3	0	0	1.6	0	2.7	0
0	0	0	0	0.6	0	0	0	0	3.1	3.3
0	0	0	0	3.9	1.6	0	0	0	0	0
0	0	0	0	2.8	0	0	0	0	0	3.3
0	0	0	0	0	2.7	3.1	0	0	0	0
0	0	0	0	2	0	3.3	0	3.3	0	0];

convectiveToSurface=(2.4*conductiveHconnectMatrix)*5.1.*(TempRoomRow-wallTempOuter);
conductiveToOppositeSurface=(2.4*conductiveHconnectMatrix)*(wallU*2).*(wallTempOuter-wallTempOuter');

SurfaceHeatChange=(convectiveToSurface-conductiveToOppositeSurface);

SurfaceDeltaT=SurfaceHeatChange./(SurfaceHeatCapPerM2*2.4*conductiveHconnectMatrix);
RoomHeatLossVector=-sum(convectiveToSurface,2);
