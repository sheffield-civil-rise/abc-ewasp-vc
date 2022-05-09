%wind effects not included (c3 and c6 are zero)

A_COLL=3.5; %m^2 of colector area
Q_SOLAR=2000;
T_panel=20;
T_amb=10;
T_inlet=20;
m_dot=0.4;

c=[0.7
    0.001
    0
    0
    7000
    0];


    T_diff = (T_panel - T_amb); % difference between mean collector temperature and ambient */
	POWER = 2.0*m_dot*4180*(T_panel - T_inlet); %this is the heat lost from the panel energy due to flow of water in and out of the panel, the 2 arises due to transforming (Tout-Tin) to (2Tm-2Tin) using Tout=2Tm-Tin

    
    delta_T_Panel = (Q_SOLAR - T_diff *(c(1,1) + c(2,1)*T_diff)-POWER/A_COLL) / c(5,1);