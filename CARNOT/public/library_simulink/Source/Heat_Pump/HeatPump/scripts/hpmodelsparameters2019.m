%% Vitocal 300-G BW301.B06 (2019)
disp('------ Vitocal 300-G 301.B06 ------')
% pressure drop primary side data sheet values: 
mdot = [0  1.0  2.0  2.5]*1040/3600;
dp   = [0  30   100  145]*1e2;
dpcoeffp = fit_quadratic(mdot,dp,2);
% pressure drop secondary side data sheet values: 
mdot = [0  1.0  2.0  2.5]*1000/3600;
dp   = [0  35   110  170]*1e2;
dpcoeffs = polyfit(mdot,dp,2);
% power matrix from data sheet
Thout = [35 55]; 
Tcin = [-5 10 25]; 
%  Thout 35 °C  55 °C
Qdoth = [4950,  4470; ...   % Tcin = -5°C
         7510,  6890; ...   % Tcin = 10°C
         11220, 9480];      % Tcin = 25°C
Qdotc = [3800,  2690; ...   % Tcin = -5°C
         6350,  5120; ...   % Tcin = 10°C
         10040, 7540];      % Tcin = 25°C
Pel =   [1240,  1920; ...   % Tcin = -5°C
         1240,  1900; ...   % Tcin = 10°C
         1270,2080];        % Tcin = 25°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)];
Thout_temp = [];
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 25e3;              % hot side thermal capacity
HP.capc = 16e3;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 5;                  % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301B06', 'HP')

%% Vitocal 300-G B08 (2019)
disp('------ Vitocal 300-G 301.B08 ------')
% pressure drop primary side data sheet values: 
mdot = [0  1.0  2.0  2.5]*1040/3600;
dp   = [0  30   70   100]*1e2;
dpcoeffp = fit_quadratic(mdot,dp,2);
% pressure drop secondary side data sheet values: 
mdot = [0  1.0  2.0  2.5]*1000/3600;
dp   = [0  30   90   130]*1e2;
dpcoeffs = polyfit(mdot,dp,2);
% power matrix from data sheet
Thout = [35 55]; 
Tcin = [-5 10 25]; 
%  Thout 35 °C  55 °C
Qdoth = [6680,  6210; ...   % Tcin = -5°C
        10180,  9250; ...   % Tcin = 10°C
        14760, 12500];      % Tcin = 25°C
Qdotc = [5180,  3740; ...   % Tcin = -5°C
         8740,  6910; ...   % Tcin = 10°C
        13320, 10030];      % Tcin = 25°C
Pel =   [1550,  2660; ...   % Tcin = -5°C  % pel(1,1) data sheet : 1620
         1550,  2520; ...   % Tcin = 10°C
         1540,  2660];      % Tcin = 25°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)];
Thout_temp = [];
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 28e3;              % hot side thermal capacity
HP.capc = 17e3;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 5.5;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301B08', 'HP')


%% Vitocal 300-G 301.B10 (2019)
disp('------ Vitocal 300-G 301.B10 ------')
% pressure drop primary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1040/3600;
dp   = [0  20   40    85]*1e2;
dpcoeffp = fit_quadratic(mdot,dp,2);
% pressure drop secondary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1000/3600;
dp   = [0  20   65   140]*1e2;
dpcoeffs = polyfit(mdot,dp,2);
% power matrix from data sheet
Thout = [35 55]; 
Tcin = [-5 10 25]; 
%  Thout 35 °C  55 °C
Qdoth = [9020,  8280; ...   % Tcin = -5°C
        13510, 12280; ...   % Tcin = 10°C
        19860, 16780];      % Tcin = 25°C
Qdotc = [7010,  5180; ...   % Tcin = -5°C
        11600,  9290; ...   % Tcin = 10°C
        17940, 13610];      % Tcin = 25°C
Pel =   [2060,  3330; ...   % Tcin = -5°C 
         2050,  3220; ...   % Tcin = 10°C
         2060,  3410];      % Tcin = 25°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)];
Thout_temp = [];
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 32e3;              % hot side thermal capacity
HP.capc = 18e3;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 6;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301B10', 'HP')

%% Vitocal 300-G 301.B13 (2019)
disp('------ Vitocal 300-G 301.B13 ------')
% pressure drop primary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1040/3600;
dp   = [0  20   50   100]*1e2;
dpcoeffp = fit_quadratic(mdot,dp,2);
% pressure drop secondary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1000/3600;
dp   = [0  20   65   140]*1e2;
dpcoeffs = polyfit(mdot,dp,2);
% power matrix from data sheet
Thout = [35 55]; 
Tcin = [-5 10 25]; 
%  Thout 35 °C  55 °C
Qdoth = [11230, 10460; ...  % Tcin = -5°C
         16890, 15460; ...  % Tcin = 10°C
         25690, 21510];     % Tcin = 25°C
Qdotc = [8820,  6620; ...   % Tcin = -5°C
        14460, 11680; ...   % Tcin = 10°C
        23120, 17540];      % Tcin = 25°C
Pel =   [2590,  4140; ...   % Tcin = -5°C 
         2610,  4060; ...   % Tcin = 10°C
         2760,  4027];      % Tcin = 25°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)];
Thout_temp = [];
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 36e3;              % hot side thermal capacity
HP.capc = 19e3;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 6.5;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301B13', 'HP')

%% Vitocal 300-G 301.B17 (2019)
disp('------ Vitocal 300-G 301.B17 ------')
% pressure drop primary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1040/3600;
dp   = [0  15   35    70]*1e2;
dpcoeffp = fit_quadratic(mdot,dp,2);
% pressure drop secondary side data sheet values: 
mdot = [0  1.0  2.0  3.0]*1000/3600;
dp   = [0  18   60   120]*1e2;
dpcoeffs = polyfit(mdot,dp,2);
% power matrix from data sheet
Thout = [35 55]; 
Tcin = [-5 10 25]; 
%  Thout 35 °C  55 °C
Qdoth = [15190, 14100; ...   % Tcin = -5°C
         22590, 20690; ...   % Tcin = 10°C
         33590, 28990];      % Tcin = 25°C
Qdotc = [11870,  8890; ...   % Tcin = -5°C
         19170, 15400; ...   % Tcin = 10°C
         30080, 23230];      % Tcin = 25°C
Pel =   [3280,  5600; ...   % Tcin = -5°C  % pel(1,1) data sheet : 1620
         3680,  5690; ...   % Tcin = 10°C
         3780,  6200];      % Tcin = 25°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)];
Thout_temp = [];
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 40e3;              % hot side thermal capacity
HP.capc = 20e3;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 7;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301B17', 'HP')


%% BW 301.A21 (2019)
disp('------------ bw301A21 -------------')
mdot = [0  2.7  4.0  5.7  7.2  9.0]*1000/3600;
dp   = [0  50   100  200  300  450]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  2.2  3.5  5.0  6.1  8.1]*1000/3600;
dp   = [0  50   100  200  300  500]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
% power matrix from data sheet
Thout = [35 45 55 60]; 
Tcin = [2 10 15]; 
% Ts_out    35    45    55    60 °C
Qdoth = [22580 21640 20410 19590; ...   % Tp_in = 2°C
         28100 26640 24920 24100; ...   % Tp_in = 10°C
         32150 30190 28320 27360];      % Tp_in = 15°C
Qdotc = [18340 16450 14070 12590; ...   % Tp_in = 2°C
         23700 21440 18590 17130; ...   % Tp_in = 10°C
         27950 25030 21970 20370];      % Tp_in = 15°C
Pel   = [ 4530  5580  6820  7520; ...   % Tp_in = 2°C
          4730  5580  6800  7500; ...   % Tp_in = 10°C
          4570  5550  6830  7520];      % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 4182*8;              % hot side thermal capacity
HP.capc = 3800*8;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 7;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301A21', 'HP')

%% BW 301.A29 (2019)
disp('------------ BW301A29 -------------')
mdot = [0  3.0  4.3  6.5  8.2  10.4]*1000/3600;
dp   = [0  50   100  200  300  450]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  3.0  4.3  6.4  7.8  9.6]*1000/3600;
dp   = [0  50   100  200  300  450]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
% power matrix from data sheet
Thout = [35 45 55 60]; 
Tcin = [2 10 15]; 
% Ts_out    35    45     55     60 °C
Qdoth = [30460  29680  27700  25070; ...   % Tp_in = 2°C   % Punkt 2/60 wäre eigentlich 20070
         37100  36230  34110  32810; ...   % Tp_in = 10°C
         44180  41210  38060  36780];      % Tp_in = 15°C
Qdotc = [24920  22450  18670  14080; ...   % Tp_in = 2°C   % Punkt 2/60 wäre eigentlich 12080
         31400  29050  25270  24500; ...   % Tp_in = 10°C
         38310  34070  29340  27120];      % Tp_in = 15°C
Pel   = [ 6010   7780   9700  10000; ...   % Tp_in = 2°C   % Punkt 2/60 wäre eigentlich 8600
          6200   7730   9500  10300; ...   % Tp_in = 10°C
          6310   7690   9380  10390];      % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1);
A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
% set HP structure and save it
HP.caph = 4182*10;              % hot side thermal capacity
HP.capc = 3800*10;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 7;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301A29', 'HP')


%% BW 301.A45 (2019)
disp('------------ BW301A45 -------------')
mdot = [0  3.5  5.1  7.5  9.5]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  3.4  4.9  7.1  9.0  9.7]*1000/3600;
dp   = [0  50   100  200  300  350]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [2 10 15]; 
% Ts_out    35    45    55    60 °C
Qdoth = [46200 43720 40230 38820; ...   % Tp_in = 2°C
         58900 52620 48740 46280; ...   % Tp_in = 10°C
         66050 59420 55000 52790];      % Tp_in = 15°C
Qdotc = [37140 32740 26920 24120; ...   % Tp_in = 2°C
         48900 41600 35410 31640; ...   % Tp_in = 10°C
         56590 48400 41760 38190];      % Tp_in = 15°C
Pel   = [ 9560 11810 14330 15790; ...   % Tp_in = 2°C
         10070 11850 14330 15750; ...   % Tp_in = 10°C
         10170 11850 14230 15690];      % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*13;              % hot side thermal capacity
HP.capc = 3800*13;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 7;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw301A45', 'HP')

%% BW 302_DS090
disp('------------ BW302DS090 -------------')
mdot = [0  7.6  11.5 17   20.8]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis 
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  14.3 18.1 23   26.5 30]*1000/3600;
dp   = [0  50   100  150  200  250]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [5 10 15]; 
% Ts_out    35    45    55      60 °C
Qdoth = [95700  91400   87200   87600; ...   % Tp_in = 5°C
         108700 102800  98000   94800; ...   % Tp_in = 10°C
         125900 114000  108800  106600];     % Tp_in = 15°C
Qdotc = [78000  70200   62100   58900; ...   % Tp_in = 5°C
         90600  81200   72700   66300; ...   % Tp_in = 10°C
         107800 93200   82700   78300];      % Tp_in = 15°C
Pel   = [18810  22550   26730   30330; ...   % Tp_in = 5°C
         19210  22950   26830   30230; ...   % Tp_in = 10°C
         19270  22150   27630   30130];      % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*15.2;              % hot side thermal capacity
HP.capc = 3800*10.5;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 20.18;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw302DS090', 'HP')

%% BW 302_DS110
disp('------------ BW302DS110 -------------')
mdot = [0  10   14.5 20.5 25]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  15   23   27.5 32.5 35]*1000/3600;
dp   = [0  50   100  150  200  250]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [5 10 15]; 
% Ts_out    35    45    55      60 °C
Qdoth = [124100 117700  112400  114000; ...   % Tp_in = 5°C
         141700 133300  127000  123800; ...   % Tp_in = 10°C
         164700 148500  141800  139800];      % Tp_in = 15°C
Qdotc = [101300 90400   79600   76400; ...    % Tp_in = 5°C
         118300 105400  94000   86400; ...    % Tp_in = 10°C
         141100 121400  107800  102600];      % Tp_in = 15°C
Pel   = [24420  29080   34820   39720; ...    % Tp_in = 5°C
         24920  29680   35020   39620; ...    % Tp_in = 10°C
         25120  28680   36020   39520];       % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*19.2;              % hot side thermal capacity
HP.capc = 3800*13.1;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 20.18;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw302DS110', 'HP')


%% BW 302_DS140
disp('------------ BW302DS140 -------------')
mdot = [0  15   18   26   32]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  17   25   32   36.5 41]*1000/3600;
dp   = [0  50   100  150  200  250]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [5 10 15]; 
% Ts_out    35    45    55      60 °C
Qdoth = [153500 146200  138200  139200; ...   % Tp_in = 5°C
         174900 165000  156000  151200; ...   % Tp_in = 10°C
         202700 183600  174000  170800];      % Tp_in = 15°C
Qdotc = [124400 111900  96800   92400; ...    % Tp_in = 5°C
         145200 130300  114400  104000; ...   % Tp_in = 10°C
         173200 150100  131200  124400];      % Tp_in = 15°C
Pel   = [31300  37270   43810   49610; ...    % Tp_in = 5°C
         31900  37870   44010   49410; ...    % Tp_in = 10°C
         32000  36570   45210   49210];       % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*23.2;              % hot side thermal capacity
HP.capc = 3800*17.4;              % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 26.21;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw302DS140', 'HP')

%% BW 302_DS180
disp('------------ BW302DS180 -------------')
mdot = [0  15   22.5 32   40]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  21   30   35   41.5 45]*1000/3600;
dp   = [0  50   100  150  200  250]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [5 10 15]; 
% Ts_out    35    45    55      60 °C
Qdoth = [206100 194100  187200  185000; ...   % Tp_in = 5°C
         235100 220100  212000  207000; ...   % Tp_in = 10°C
         267100 247100  239000  232000];      % Tp_in = 15°C
Qdotc = [168500 148400  132500  124100; ...   % Tp_in = 5°C
         197500 174200  156500  146300; ...   % Tp_in = 10°C
         228700 200600  184100  171100];      % Tp_in = 15°C
Pel   = [40030  48560   58050   64450; ...    % Tp_in = 5°C
         40230  48760   58250   64250; ...    % Tp_in = 10°C
         40830  49160   58250   64450];       % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*28.3;              % hot side thermal capacity
HP.capc = 3800*23;                % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 26.21;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw302DS180', 'HP')

%% BW 302_DS230
disp('------------ BW302DS230 -------------')
mdot = [0  21.5 30   43   53]*1000/3600;
dp   = [0  50   100  200  300]*1e2; % Primaerkreis
dpcoeffp = fit_quadratic(mdot,dp,2);
mdot = [0  23.5 33.5 42   49.5 54.5]*1000/3600;
dp   = [0  50   100  150  200  250]*1e2; % Sekundaerkreis
dpcoeffs = fit_quadratic(mdot,dp,2);
Thout = [35 45 55 60]; 
Tcin = [5 10 15]; 
% Ts_out    35    45    55      60 °C
Qdoth = [258200 245200  239100  233100; ...   % Tp_in = 5°C
         296200 281200  274100  267100; ...   % Tp_in = 10°C
         341200 322200  311100  299100];      % Tp_in = 15°C
Qdotc = [211700 188900  172100  158100; ...   % Tp_in = 5°C
         248700 223700  205700  191300; ...   % Tp_in = 10°C
         291700 263700  242700  222700];      % Tp_in = 15°C
Pel   = [49500  59290   71320   79120; ...    % Tp_in = 5°C
         50900  60690   72320   79920; ...    % Tp_in = 10°C
         52500  61890   73120   80920];       % Tp_in = 15°C
% Matrix construction for hp_param
A = reshape(Qdoth',numel(Qdoth),1); A = [A reshape(Qdotc',numel(Qdotc),1)];
A = [A reshape(Pel',numel(Pel),1)]; 
Thout_temp = []; 
Tcin_temp = [];
for i=1:numel(Tcin)
    for j=1:numel(Thout)
        Tcin_temp = [Tcin_temp ; Tcin(i)]; %#ok<AGROW>
    end
    Thout_temp = [Thout_temp ; Thout']; %#ok<AGROW>
end
A = [A Tcin_temp Thout_temp];
HP.caph = 4182*53.6;              % hot side thermal capacity
HP.capc = 3800*52.4;                % cold side thermal capacity
HP.K = hp_param(A);
HP.linh = dpcoeffs(2);
HP.quah = dpcoeffs(1);
HP.linc = dpcoeffp(2);
HP.quac = dpcoeffp(1);
HP.UA = 26.21;                 % thermal losses
HP.relQdotMin = 1;
save('Vitocal300G_bw302DS230', 'HP')
