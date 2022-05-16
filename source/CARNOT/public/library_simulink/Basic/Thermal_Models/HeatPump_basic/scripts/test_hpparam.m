% BW106: Qdoth = [5940 5460; 8670 7910];  Qdotc = [4710 3410; 7500 5990];
%  A = [qdot_hot qdot_cold     pel     tcold      thot]

% limited values, only one element for Tcin 15
Qdoth = [5940; 5460; 8670];  
Qdotc = [4710; 3410; 7500];
Pel   = [1320; 2210; 1270]; 
Thout = [  35;   55;   35]; 
Tcin  = [   0;    0;   15]; 

% correct Matrix construction for hp_param
A = [Qdoth, Qdotc, Pel, Tcin, Thout];
Klim = hp_param(A) %#ok<*NOPTS>

% now all the values
Qdoth = [5940; 5460; 8670; 7910];  
Qdotc = [4710; 3410; 7500; 5990];
Pel   = [1320; 2210; 1270; 2070]; 
Thout = [  35;   55;   35;   55]; 
Tcin  = [   0;    0;   15;   15]; 


% error: temperatures inverted (a warning should appear)
A = [Qdoth, Qdotc, Pel, Thout, Tcin];
Ktinv = hp_param(A)

% error: power inverted (a warning should appear)
A = [Qdotc, Qdoth, Pel, Tcin, Thout];
Kqinv = hp_param(A)

% correct Matrix , but one element is wrong (a warning should appear)
Qdoth_f = [1940; 5460; 8670; 7910];  % correct [5940; ...]
A = [Qdoth_f, Qdotc, Pel, Tcin, Thout];
Kwrng = hp_param(A)

% correct Matrix construction for hp_param
A = [Qdoth, Qdotc, Pel, Tcin, Thout];
K = hp_param(A)

