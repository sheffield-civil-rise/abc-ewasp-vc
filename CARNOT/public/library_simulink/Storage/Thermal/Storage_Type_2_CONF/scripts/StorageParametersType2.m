%% define parameters for StorageType2_CONF model

%% 200 litre dhw cylinder
s.vol = 0.200;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 1;
s.dia = 0.450;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = 0.5;
s.pos = 'standing cylinder'; % 'lying cylinder'
s.pipe1inlet = 0;
s.pipe1outlet = 1;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;
s.hx1inlet = 0.45;
s.hx1outlet = 0.1;
s.hx1dplin = 100;
s.hx1dpqua = 100;
s.hx1uac = 70;
s.hx1uam = 0.2;
s.hx1uat = 0.5;

save StorageType2_200_L s

%% 300 litre dhw cylinder
s.vol = 0.300;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 1;
s.dia = 0.500;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = 0.5;
s.pos = 'standing cylinder'; % 'lying cylinder'
s.pipe1inlet = 0;
s.pipe1outlet = 1;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;
s.hx1inlet = 0.45;
s.hx1outlet = 0.1;
s.hx1dplin = 100;
s.hx1dpqua = 100;
s.hx1uac = 80;
s.hx1uam = 0.2;
s.hx1uat = 0.5;

save StorageType2_300_L s

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
s.pipe1inlet = 0;
s.pipe1outlet = 1;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;
s.hx1inlet = 0.45;
s.hx1outlet = 0.1;
s.hx1dplin = 100;
s.hx1dpqua = 100;
s.hx1uac = 100;
s.hx1uam = 0.2;
s.hx1uat = 0.5;

save StorageType2_400_L s

