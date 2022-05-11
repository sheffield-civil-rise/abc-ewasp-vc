%% test mask with different settings for the parameters
%  all of the following settings should work:
%  - numerical value as parameter
%  - variable name as parameter
%  - struct name as parameter

mdlname = 'test_with_variables_CondensingBoilerCONF';

% parameters Tamb and Pgas as numerical value, variable and struct
Tamb = 20;
ambiantCond.Tamb = Tamb;
pgas = 20e3;
boiler.pgas = pgas;

% some initial values
t0 = 0:300:3600;
idx = 0;

% check model with numerical value of Tamb as parameter
set_param([gcs, '/Condensing_Boiler_CONF'], 'Tini', num2str(Tamb));
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;

%% check model with variable name  of Tamb 
set_param([gcs, '/Condensing_Boiler_CONF'], 'Tini', 'Tamb');
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;

%% check model with struct name  of Tamb
set_param([gcs, '/Condensing_Boiler_CONF'], 'Tini', 'ambiantCond.Tamb');
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;

%% check model with numerical value of Pgas as parameter
set_param([gcs, '/Condensing_Boiler_CONF'], 'Pgas', num2str(pgas));
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;

%% check model with variable name  of Pgas 
set_param([gcs, '/Condensing_Boiler_CONF'], 'Pgas', 'pgas');
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;

%% check model with struct name  of Pgas
set_param([gcs, '/Condensing_Boiler_CONF'], 'Pgas', 'boiler.pgas');
simOut = sim(mdlname, 'SrcWorkspace','current', ...
    'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout'); % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
idx = idx+1;
y2(:,idx) = yt.data;


plot(t0,y2)