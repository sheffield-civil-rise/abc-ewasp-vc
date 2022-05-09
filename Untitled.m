%profiles=0;
profiles=occFreegainHotwaterElecTestPassiveOcc3(1:10080,1:4);
p1=repmat(profiles,52,1);
p1(524160+1:524160+1440,1:4)=p1(1:1440,1:4);
%%
occFreegainHotwaterElecTestPassiveOcc3=p1;
%%
occFreegainHotwaterElecTestPassiveOcc3=0;