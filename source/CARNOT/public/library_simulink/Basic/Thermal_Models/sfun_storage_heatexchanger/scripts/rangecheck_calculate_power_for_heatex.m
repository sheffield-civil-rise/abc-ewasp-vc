% check parameter range for function calculate_power_for_heatex in the
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Basic/Thermal_Models/sfun_storage_heatexchanger/scripts/rangecheck_calculate_power_for_heatex.m $
% file storage_heatechanger.c

%     /* following equation is derived from
%      * mdot * cp * dThx = U * dA * (Tnode - Thx)
%      * replace (Tnode-Thx) by teta, than dThx is -dteta
%      * mdot * cp * dteta = - U * dA * teta
%      * dteta / teta = - U * dA / (mdot * cp)
%      * integrate from inlet position to outlet position
%      * ln(teta(out)/teta(in)) = - U * A / (mdot * cp)
%      * exponentiate and solve for teta(out)
%      * teta(out) = teta(in) * exp(-U*A/(mdot*cp))
%      * replace teta by (Tnode - Thx) and solve for
%      * Thx(out), the outlet temperature of the
%      * heat exchanger in one node
%      * Thx(out) = Tnode(out) +
%      * ((Thx(in) - Tnode(in)) * exp(-U*A/(mdot*cp))
%      * Tnode(in) and Tnode(out) are the same since nodes
%      * are fully mixed. Remember that in the following
%      * equation Tnode must refer to one node upwars in
%      * flowdirection.
%      */


mdot = 1/3600;      % massflow in kg/s
cphx = 4200;        % cp water
heatex = 20;        % heat exchange in W/K

thx = 40;                   % inlet temperature
t_store = (39+1e-10):0.1:40.2;   % storage node temperature

thxn = t_store + (thx-t_store)*exp(-heatex./(mdot*cphx))
plot(t_store, thxn)
title('Thx')

figure
plot(t_store, (thxn-t_store))

logthx = (thx-t_store)./(thxn-t_store);
logthx = log(abs(logthx));
qhx = heatex.*(thx-thxn)./logthx
figure
plot(t_store, qhx)
title('Qhx')