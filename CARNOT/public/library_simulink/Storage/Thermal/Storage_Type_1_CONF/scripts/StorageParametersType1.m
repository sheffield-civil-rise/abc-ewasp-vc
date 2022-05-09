%% define parameters for StorageType1_CONF model

%% 300 litre buffer tank
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
s.pipe1inlet = 1;
s.pipe1outlet = 0;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;
s.pipe2inlet = 0;
s.pipe2outlet = 1;
s.pipe2dplin = 10;
s.pipe2dpqua = 10;

save StorageType1_300_L s


%% 500 litre buffer tank
s.vol = 0.500;
s.uwall = 1;
s.ubot = 1;
s.utop = 1;
s.axcond = 0.9;
s.dia = 0.600;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = 0.5;
s.pos = 'standing cylinder'; % 'lying cylinder'
s.pipe1inlet = 1;
s.pipe1outlet = 0;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;
s.pipe2inlet = 0;
s.pipe2outlet = 1;
s.pipe2dplin = 10;
s.pipe2dpqua = 10;

save StorageType1_300_L s


%% 1000 litre buffer tank
s.vol = 1.0;
s.uwall = 1.1;
s.ubot = 1.1;
s.utop = 1.1;
s.axcond = 0.9;
s.dia = 0.800;
s.nodes = 20;
s.mpts = 20;
s.Tsensor = 0.6;
s.pos = 'standing cylinder'; % 'lying cylinder'
s.pipe1inlet = 0.95;
s.pipe1outlet = 0.05;
s.pipe1dplin = 5;
s.pipe1dpqua = 5;
s.pipe2inlet = 0.05;
s.pipe2outlet = 0.95;
s.pipe2dplin = 5;
s.pipe2dpqua = 5;

save StorageType1_1000_L s