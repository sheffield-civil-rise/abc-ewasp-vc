%% define parameters for StorageType2_CONF model

s = struct;

%% 300 litre dhw cylinder
s.vol = 0.3;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 1;
s.dia = 0.5;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = [0.1 0.7];
s.pos = 'standing cylinder'; % 'lying cylinder'

s.pipe1inlet = 0.03;
s.pipe1outlet = 0.97;
s.pipe1dplin = 12;
s.pipe1dpqua = 12;

s.hx1inlet = 0.81;
s.hx1outlet = 0.61;
s.hx1dplin = 95;
s.hx1dpqua = 95;
s.hx1uac = 80;
s.hx1uam = 0.19;
s.hx1uat = 0.49;

s.hx2inlet = 0.46;
s.hx2outlet = 0.06;
s.hx2dplin = 95;
s.hx2dpqua = 95;
s.hx2uac = 100;
s.hx2uam = 0.19;
s.hx2uat = 0.49;

save StorageType3_300_L s

%% 400 litre dhw cylinder
s.vol = 0.400;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 0.9;
s.dia = 0.550;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = 0.5;
s.pos = 'standing cylinder'; % 'lying cylinder'

s.pipe1inlet = 0.02;
s.pipe1outlet = 0.98;
s.pipe1dplin = 11;
s.pipe1dpqua = 11;

s.hx1inlet = 0.8;
s.hx1outlet = 0.6;
s.hx1dplin = 100;
s.hx1dpqua = 100;
s.hx1uac = 90;
s.hx1uam = 0.2;
s.hx1uat = 0.5;

s.hx2inlet = 0.45;
s.hx2outlet = 0.05;
s.hx2dplin = 100;
s.hx2dpqua = 100;
s.hx2uac = 110;
s.hx2uam = 0.2;
s.hx2uat = 0.5;

save StorageType3_400_L s

%% 500 litre dhw cylinder
s.vol = 0.400;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 0.8;
s.dia = 0.60;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = 0.5;
s.pos = 'standing cylinder'; % 'lying cylinder'

s.pipe1inlet = 0.01;
s.pipe1outlet = 0.99;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;

s.hx1inlet = 0.79;
s.hx1outlet = 0.59;
s.hx1dplin = 105;
s.hx1dpqua = 105;
s.hx1uac = 120;
s.hx1uam = 0.21;
s.hx1uat = 0.51;

s.hx2inlet = 0.45;
s.hx2outlet = 0.05;
s.hx2dplin = 105;
s.hx2dpqua = 105;
s.hx2uac = 120;
s.hx2uam = 0.21;
s.hx2uat = 0.51;

save StorageType3_500_L s

