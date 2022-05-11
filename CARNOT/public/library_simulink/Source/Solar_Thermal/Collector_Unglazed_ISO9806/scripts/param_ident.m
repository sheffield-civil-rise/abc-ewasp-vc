% this m-function performs the parameter identification for heatpump model

%names of the parameters in the simulink model
global TCh TCc UA

% initialise parameter for minimisation
F = inline('power_error(p)');
p0 = [20000 10000 10];

% minimisation
p_opt = fminsearch(F,p0,optimset('MaxIter',1000))