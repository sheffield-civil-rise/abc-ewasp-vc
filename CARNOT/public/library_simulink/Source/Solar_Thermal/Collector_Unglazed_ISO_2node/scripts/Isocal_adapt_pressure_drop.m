%% TUEV Bericht TUV21220633_Kollektortest_Absorber_unglazed.pdf
v = 0:100:700;  % liter/h
dp_kPa = 4.801e-7*v.^2 + 1.529e-3*v;
mdot = v/3600;
lin = 1.529e-3*3600*1000;
qua = 4.801e-7*3600^2*1000;
dp_Pa = qua*mdot.^2 + lin*mdot;
plot(v,dp_kPa, mdot*3600, dp_Pa/1000)
