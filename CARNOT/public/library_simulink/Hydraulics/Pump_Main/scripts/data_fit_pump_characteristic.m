%% Pump_Main hydraulic and electric parameters
%  pressure - flow characteristics
%   dp = a0 - a1*mdot - a2*mdot^2
%   a0 is the pump head in Pa
%   a1 is the linear coefficient in Pa*s/kg
%   a2 is the quadratic coefficient in Pa*(s/kg)^2
%  electric power consumption
%   Pel = e0 + e1*mdot + e2*mdot^2

%% Parameter Set 'Pump2m.mat'
%  pump with 4 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 30 W (no flow), 40 W (1/2 max flow), 45 W (max flow)
mdotmax = 2.0*1000/3600;
p0 = 2e4;
Pel = [30, 40, 45];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
mdot_plot = linspace(min(mdot),max(mdot),20);
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
title('hydraulic characteristic')
dp_plot = polyval([a2, a1, a0],mdot_plot);
plot(mdot_plot,dp_plot)
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title('Pump 2 m')
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
xlabel('massflow in kg/s')
ylabel('efficiency')
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% Parameter Set 'Pump4m.mat'
%  pump with 4 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 30 W (no flow), 40 W (1/2 max flow), 45 W (max flow)
mdotmax = 3.6*1000/3600;
p0 = 4e4;
Pel = [30, 40, 45];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
mdot_plot = linspace(min(mdot),max(mdot),20);
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
title('hydraulic characteristic')
dp_plot = polyval([a2, a1, a0],mdot_plot);
plot(mdot_plot,dp_plot)
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title('Pump 4 m')
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
xlabel('massflow in kg/s')
ylabel('efficiency')
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% Parameter Set 'Pump5m.mat'
%  pump with 5 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 35 W (no flow), 45 W (1/2 max flow), 50 W (max flow)
mdotmax = 4.0*1000/3600;
p0 = 5e4;
Pel = [35, 45, 50];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
mdot_plot = linspace(min(mdot),max(mdot),20);
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
title('hydraulic characteristic')
dp_plot = polyval([a2, a1, a0],mdot_plot);
plot(mdot_plot,dp_plot)
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title('Pump 5 m')
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
xlabel('massflow in kg/s')
ylabel('efficiency')
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% Parameter Set 'Pump6m.mat'
%  pump with 6 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 50 W (no flow), 65 W (1/2 max flow), 70 W (max flow)
mdotmax = 5.0*1000/3600;
p0 = 6e4;
Pel = [50, 65, 70];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
mdot_plot = linspace(min(mdot),max(mdot),20);
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
title('hydraulic characteristic')
dp_plot = polyval([a2, a1, a0],mdot_plot);
plot(mdot_plot,dp_plot)
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title('Pump 6 m')
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
xlabel('massflow in kg/s')
ylabel('efficiency')
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% Parameter Set 'Pump8m.mat'
%  pump with 8 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 100 W (no flow), 135 W (1/2 max flow), 150 W (max flow)
mdotmax = 9.0*1000/3600;
p0 = 8e4;
Pel = [100, 135, 150];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
mdot_plot = linspace(min(mdot),max(mdot),20);
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
title('hydraulic characteristic')
dp_plot = polyval([a2, a1, a0],mdot_plot);
plot(mdot_plot,dp_plot)
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title('Pump 8 m')
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
xlabel('massflow in kg/s')
ylabel('efficiency')
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% Parameter Set 'Pump10m.mat'
%  pump with 8 m head and linear hydraulic characteristic
%  max flow with no pressure drop 3.5 m³/h 
%  electric power: 200 W (no flow), 270 W (1/2 max flow), 300 W (max flow)
mdotmax = 18.0*1000/3600;
p0 = 10e4;
Pel = [200, 270, 300];
% set variables and determine parameters
mdot = (0:0.5:1)*mdotmax;
a0 = p0;
a1 = -p0/mdotmax;
a2 = 0;
e = polyfit(mdot, Pel, 2);
e0 = e(3);
e1 = e(2);
e2 = e(1);
% plot results and display parameters
tt = 'Pump 10 m';
plotten(tt,a2,a1,a0,e,mdot)
% show hydraulic params
disp('hydraulic parameters')
disp(['    a0 = ' num2str(a0)])
disp(['    a1 = ' num2str(a1)])
disp(['    a2 = ' num2str(a2)])
disp(['pump head dp = ', num2str(a0), ' + (', num2str(a1), '*mdot) + (', num2str(a2), '*mdot^2)'])
disp(' ')
% show electric params
disp('electric parameters')
disp(['    e0 = ' num2str(e0)])
disp(['    e1 = ' num2str(e1)])
disp(['    e2 = ' num2str(e2)])
disp(['electric power Pel = ', num2str(e0), ' + (', num2str(e1), '*mdot) + (', num2str(e2), '*mdot^2)'])

%% internal functions
function plotten(tt,a2,a1,a0,e,mdot)
mdot_plot = linspace(min(mdot),max(mdot),20);
dp_plot = zeros(5,length(mdot_plot));
for n = 1:5
    ctrl = n/5;
    dp_plot(n,:) = polyval([a2, a1*ctrl, a0*ctrl^2], mdot_plot);
end
figure('OuterPosition', [0,0,500,800])
subplot(3,1,1)
plot(mdot_plot,dp_plot)
axis([0, inf, 0, inf])
xlabel('massflow in kg/s')
ylabel('pump head in Pa')
title(tt)
subplot(3,1,2)
e_plot = polyval(e,mdot_plot);
plot(mdot_plot,e_plot)
xlabel('massflow in kg/s')
ylabel('electric power in W')
subplot(3,1,3) % efficiency
eta_plot = mdot_plot./1000.*dp_plot./e_plot;
plot(mdot_plot,eta_plot)
axis([0, inf, 0, inf])
xlabel('massflow in kg/s')
ylabel('efficiency')
end



%% Literature
% /1/ Grundfos: GRUNDFOS DATA BOOKLET UP, UPS, UPSD Circulator Pumps
%     Grundfosliterature-6013408.pdf 
%     http://net.grundfos.com/Appl/ccmsservices/public/literature/filedata/Grundfosliterature-6013408.pdf
%     access on 24dec2018