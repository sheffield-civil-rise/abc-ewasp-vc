%% define parameters for StorageType5_CONF model

s = struct;

%% 600 litre combi storage
s.volume = 0.600;
s.uwall = 0.9;
s.ubot = 0.9;
s.utop = 0.9;
s.axcond = 0.9;
s.dia = 0.7;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = [0.2 0.5 0.7];
s.pos = 'standing cylinder'; % 'lying cylinder'

% charging pipe (backup dhw)
s.pipe1inlet = 0.95;
s.pipe1outlet = 0.6;
s.pipe1dplin = 12;
s.pipe1dpqua = 12;

% charging heat exchanger (solar)
s.hx1inlet = 0.4;
s.hx1outlet = 0.1;
s.hx1dplin = 12;
s.hx1dpqua = 12;
s.hx1uac = 700;
s.hx1uam = 0.4;
s.hx1uat = 0.3;

% discharging pipe (house heating)
s.pipe2inlet = 0.45;
s.pipe2outlet = 0.55;
s.pipe2dplin = 12;
s.pipe2dpqua = 12;

% charging pipe (house heating / middle part)
s.pipe3inlet = 0.55;
s.pipe3outlet = 0.45;
s.pipe3dplin = 12;
s.pipe3dpqua = 12;

% discharging heat exchanger (dhw)
s.hx2inlet = 0.02;
s.hx2outlet = 0.98;
s.hx2dplin = 95;
s.hx2dpqua = 95;
s.hx2uac = 650;
s.hx2uam = 0.4;
s.hx2uat = 0.7;

save StorageType5_600_L s

%% 800 litre combi storage
s.volume = 0.800;
s.uwall = 0.8;
s.ubot = 0.8;
s.utop = 0.8;
s.axcond = 0.8;
s.dia = 0.80;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = [0.2 0.5 0.7];
s.pos = 'standing cylinder'; % 'lying cylinder'

% charging pipe (backup dhw)
s.pipe1inlet = 0.96;
s.pipe1outlet = 0.61;
s.pipe1dplin = 11;
s.pipe1dpqua = 11;

% charging heat exchanger (solar)
s.hx1inlet = 0.39;
s.hx1outlet = 0.09;
s.hx1dplin = 13;
s.hx1dpqua = 13;
s.hx1uac = 750;
s.hx1uam = 0.4;
s.hx1uat = 0.3;

% discharging pipe (house heating)
s.pipe2inlet = 0.44;
s.pipe2outlet = 0.56;
s.pipe2dplin = 11;
s.pipe2dpqua = 11;

% charging pipe (house heating / middle part)
s.pipe3inlet = 0.56;
s.pipe3outlet = 0.44;
s.pipe3dplin = 11;
s.pipe3dpqua = 11;

% discharging heat exchanger (dhw)
s.hx2inlet = 0.01;
s.hx2outlet = 0.99;
s.hx2dplin = 94;
s.hx2dpqua = 94;
s.hx2uac = 700;
s.hx2uam = 0.4;
s.hx2uat = 0.7;

save StorageType5_800_L s

%% 1000 litre combi storage
s.volume = 1.00;
s.uwall = 0.7;
s.ubot = 0.7;
s.utop = 0.7;
s.axcond = 0.7;
s.dia = 0.85;
s.nodes = 10;
s.mpts = 10;
s.Tsensor = [0.2 0.5 0.7];
s.pos = 'standing cylinder'; % 'lying cylinder'

% charging pipe (backup dhw)
s.pipe1inlet = 0.97;
s.pipe1outlet = 0.6;
s.pipe1dplin = 10;
s.pipe1dpqua = 10;

% charging heat exchanger (solar)
s.hx1inlet = 0.4;
s.hx1outlet = 0.05;
s.hx1dplin = 14;
s.hx1dpqua = 14;
s.hx1uac = 800;
s.hx1uam = 0.4;
s.hx1uat = 0.3;

% discharging pipe (house heating)
s.pipe2inlet = 0.443;
s.pipe2outlet = 0.551;
s.pipe2dplin = 10;
s.pipe2dpqua = 10;

% charging pipe (house heating / middle part)
s.pipe3inlet = 0.551;
s.pipe3outlet = 0.443;
s.pipe3dplin = 10;
s.pipe3dpqua = 10;

% discharging heat exchanger (dhw)
s.hx2inlet = 0.0;
s.hx2outlet = 1.0;
s.hx2dplin = 96;
s.hx2dpqua = 96;
s.hx2uac = 750;
s.hx2uam = 0.4;
s.hx2uat = 0.7;

save StorageType5_1000_L s
