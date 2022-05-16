function [AirFlowID]=createUniqueIDforHouseLayout(rotation,flip,C_d,roomVol,HCM_State_1,verticalConnectMatrix)



A=HCM_State_1;
U = triu(A);
B=[U(1,1:11),U(2,2:11),U(3,3:11),U(4,4:11),U(5,5:11),U(6,6:11),U(7,7:11),U(8,8:11),U(9,9:11),U(10,10:11),U(11,11)];
HCMID=binaryVectorToHex(B);

A=verticalConnectMatrix;
U = triu(A);
k = find(U);
k=reshape(k,[1,numel(k)]);
k=num2str(k);
VCMID = regexprep(k, '\s+', '');

rV=round(roomVol);
k=num2str(rV);
volID = regexprep(k, ' +', '_');

orientationAndFlowID=[num2str(rotation) flip num2str(C_d)];

AirFlowID=strcat('AFID-',HCMID,'-',VCMID,'-',volID,'-',orientationAndFlowID);
end