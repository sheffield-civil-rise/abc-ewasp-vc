function [HCM,HCM_closed,HCM2,HCM_closed2]=makeAirflowInputMatrices(HCM_State_1,HCM_State_2)

HCM=zeros(11,11);
HCM_closed=zeros(11,11);
HCM(HCM_State_1==1)=1;
HCM_closed(HCM_State_1==2)=1;

HCM2=zeros(11,11);
HCM_closed2=zeros(11,11);
HCM2(HCM_State_2==1)=1;
HCM_closed2(HCM_State_2==2)=1;

end