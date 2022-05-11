%% CarnotCallbacks_EWS callback for the Ground_Source_Heat_Exchanger model in Carnot
%% Function Call
%  [Ad,Bd,Cd,Dd, Au,Bu,Cu,Du, Ad0,Bd0, Au0,Bu0, ...
%     Ar,Br,Cr,Dr, Cdl, c1, c3, c31, c33, c4, c41, c5, c6, ...
%     L1, L2, L10, L20, dl, Rechenradius, np, ...
%     Tearth_anf, T_null, teta_fluid_ini, Tdown_0, Tup_0, ...
%     Ts_Trichter, t_Trichter, r_Trichter, gfunction, t_start ...
%     ] = ...
%     CarnotCallbacks_EWS(startfall, LastYear, dTdesign, ...
%     SondenFall, B_sondenabstand, Sondenlaenge, Sondendurchmesser, ...
%     Bohrdurchmesser, Bu_param, Wanddicke_Sondenrohr, ...
%     Jahresmitteltemp_C, TGrad, ...
%     lambdaErde, rhoErde, cpErde, ...
%     lambdaFill, cpFill, rhoFill, lambda_Sondenrohr, ...
%     DimAxi, DimRad, Gitterfaktor, show)
% 
%% Inputs
%  startfall            1: single probe g-function approximation (Eskilon 1987)
%                       2: g-function single probe and field of probes (Eskilon 1987)
%  LastYear             Last year of (pre-)simulation 
%                       LastYear = 0  : start with Jahresmitteltemp_C
%                       LastYear = 50 : approximatly steady state
%  dTdesign             design temperature difference inlet-outlet 
%                       (used for heat transfer coefficient calculation)
%  SondenFall           1 : single probe
%                       2 : two probes with B/H = 0.1
%                       3 : two pobes B/H = 0.05
%                       4 : 3x6 Sonden B/H = 0.1
%                       5 : 5x10 Sonden B/H = 0.1
%  B_sondenabstand      B : distance of probes in m
%  Sondenlaenge         H : length of probes in m 
%  Sondendurchmesser    outer diameter of pipe in m
%  Bohrdurchmesser      diameter of borehole
%  Bu_param             distance between the down and up pipe of the U 
%                       „shank spacing“, must be < Bohrdurchmesser
%  Wanddicke_Sondenrohr thickness of pipe wall in m
%  Jahresmitteltemp_C   average ambient temperature in °C
%  TGrad                ground temperature increase per meter of depth in K/m
%  lambdaErde           thermal conductivity the ground in W/m/K (typically 2..3)
%  rhoErde              density of the ground in kg/m³ (typically 2200..2700)
%  cpErde               heat capacity of the ground in J/kg/K (typically 1000..1500)
%  lambdaFill           thermal conductivity the borehole filling in W/m/K (typically 1..2)
%  cpFill               heat capacity borehole filling in J/kg/K (typically 1000..2000)
%  rhoFill              density of the borehole filling in kg/m³ (typically 1000..2000)
%  lambda_Sondenrohr    thermal conductivity pipe material in W/m/K (0.48 for PE)
%  DimAxi               number of nodes in the pipe (number of vertical
%                       nodes in the ground is 0.5*DimAxi)
%  DimRad               number of radial nodes
%  Gitterfaktor         grid factor (> 1, typical 2.5)
%  show                 display and save start conditions (initial
%                       temperatures, time constants, thermal borehole
%                       resistance)
%  
%% Outputs
%  Ad,Bd,Cd,Dd, Au,Bu,Cu,Du, Ad0,Bd0, Au0,Bu0, ...
%     Ar,Br,Cr,Dr, Cdl, c1, c3, c31, c33, c4, c41, c5, c6, ...
%     L1, L2, L10, L20, dl, Rechenradius, ...
%     Tearth_anf, T_null, teta_fluid_ini, Tdown_0, Tup_0, ...
%     Ts_Trichter, t_Trichter, r_Trichter, gfunction, t_start
%  np           number of hydraulic parallel connected ground probes
%  
% 
%% Description
%  Callback of the Ground_Source_Heat_Exchanger model in Carnot
%  For geothermal probe fields it is assumed that all probes are connected
%  in parallel.
% 
%% References and Literature
%  Bianchi M. A. (2006): Adaptive modellbasierte prädiktive Regelung einer 
%           Kleinwärmepumenanlage, Diss. ETH Zuerich, No. 16892, 
%  Huber A, Schuler O. (1997): Berechnungsmodul für Erdwärmesonden (EWS). 
%           ENET Bericht Nr. 9658807-1
%           http://www.hetag.ch/download/HU_EWS1_SB.pdf (accessed 10/04/2021)
%  Huber A. (1999): Erweiterung des Programms EWS für Erdwärmesondenfelder, 
%           Forschungsprogramm Umgebungs- und Abwärme, 
%           Waerme-Kraft-Kopplung (UAW) im Auftrag des Bundesamtes für
%           Energie (Schweiz)
%           http://www.hetag.ch/download/HU_EWS2_SB.pdf (accessed 10/04/2021)
%  Huber, A. (2020): Benutzerhandbuch zum Programm EWS, Version 5.4, 
%           Huber Energietechnik AG, http://www.hetag.ch/download/Bed_EWS54.pdf
%           English version: http://www.hetag.ch/download/Bed_EWS54_Eng.pdf 
%           (accessed 29/04/2021)
%  Eskilson, P. (1987): Thermal Analysis of Heat Extraction Boreholes. 
%           Department of Mathematical Physics, Lund Institute of Technology, 
%           Lund, Sweden. ISBN 91-7900-298-6
%  Hellström, G. (1991): Ground Heat Storage. Thermal Analyses of Duct 
%           Storage Systems. Theory. Dep. of Mathematical Physics,
%           University of Lund, Sweden. ISBN 91-628-0290-9
% 
%  Function is used by: Ground_Source_Heat_Exchanger.slx
%  see also FluidEnum, Carnot_Fluid_Types


function [Ad,Bd,Cd,Dd, Au,Bu,Cu,Du, Ad0,Bd0, Au0,Bu0, ...
    Ar,Br,Cr,Dr, Cdl, c1, c3, c31, c33, c4, c41, c5, c6, ...
    L1, L2, L10, L20, dl, Rechenradius, np, ...
    Tearth_anf, T_null, teta_fluid_ini, Tdown_0, Tup_0, ...
    Ts_Trichter, t_Trichter, r_Trichter, gfunction, t_start ...
    ] = ...
    CarnotCallbacks_EWS(startfall, LastYear, dTdesign, ...
    SondenFall, B_sondenabstand, Sondenlaenge, Sondendurchmesser, ...
    Bohrdurchmesser, Bu_param, Wanddicke_Sondenrohr, ...
    Jahresmitteltemp_C, TGrad, ...
    lambdaErde, rhoErde, cpErde, ...
    lambdaFill, cpFill, rhoFill, lambda_Sondenrohr, ...
    DimAxi, DimRad, Gitterfaktor, show)

%% set model parameters
%  Parameters for precalculation of the ground temperatures
qdot_precalc = 10;          % 10 W/m for the precalculation of the temperature field
qdot_hi = 50;               % 50 W/m for the precalculation of the temperature field
if SondenFall == 1          % 1 Sonde
    np = 1;                 % number of parallel connected probes
elseif SondenFall == 2      % 2 Sonden B/H = 0.1
    np = 2;                 % number of parallel connected probes
elseif SondenFall == 3      % 2 Sonden B/H = 0.05
    np = 2;                 % number of parallel connected probes
elseif SondenFall == 4      % 3x6 Sonden B/H = 0.1
    np = 18;                % number of parallel connected probes
elseif SondenFall == 5      % 5x10 Sonden B/H = 0.1
    np = 50;                % number of parallel connected probes
end
% SondenAnzahl = np;            % number of probes (equal to number of parallel probes)

% Fluid
teta_m = 2;     % average fluid temperature in °C
p0 = 1e5;
fluid = 5;      % water gylcol mixture
mix = 0.25;     % 25 % gylcol

% Ground Properties
% Jahresmitteltemp = Jahresmitteltemp_C + 273.15; % °C to K
% Bodenerwaermung = 1;  % Original von Fabian             % °C
Bodenerwaermung = 0;                            % K
Bodentemp = Jahresmitteltemp_C + Bodenerwaermung; % K

%% Calculations
% geometry
Rechenradius = B_sondenabstand/2;           % calculation radius is half of the borehole distance
Gitterfaktor = max(1.1,Gitterfaktor);       % grid factor must be > 1    
DimAxi05 = DimAxi/2;                        % DimAxi is number of nodes for down and up

% bei Huber 1999 (Gl 2-11) ist dl = Sondenlaenge/DimAxi. Hier ein Problem?
% wenn das hier korrigiert wird muss ggf. auch die Maske des Modells angepasst werden
H = Sondenlaenge;
dl = H/DimAxi05;                % axial length of a pipe segment
rs = Sondendurchmesser/2;       % outer radius of the pipe
r0 = rs-Wanddicke_Sondenrohr;   % inner radius of the pipe
Di = 2*r0;                      % inner diameter
Ac = 2*pi*r0^2;                 % crossection of the pipes : times two for double U
r1 = Bohrdurchmesser/2;         % radius of the borehole
r2 = r1+(Rechenradius-r1)*(1-Gitterfaktor)/(1-Gitterfaktor^(DimRad-1))*Gitterfaktor^0;
rz1 = sqrt(0.5*(r1^2+r0^2));
rz2 = sqrt(0.5*(r2^2+r1^2));
ln_rsr0 = log(rs/r0);           % log of outer radius / inner radius of the pipe
B_u = min(Bohrdurchmesser-Di, max(Bu_param, Di));        % shank spacing

% material properties
aErde = lambdaErde/(rhoErde*cpErde);                    % temperature conductivity in m²/s
lambdaSole = thermal_conductivity(teta_m,p0,fluid,mix); % W/(m K)
cpSole = heat_capacity(teta_m,p0,fluid,mix);            % J/Kg*K
rhoSole = density(teta_m,p0,fluid,mix);                 % kg/m^3
vSole = kinematic_viscosity(teta_m,p0,fluid,mix);       % m²/s
mcpSole = cpSole*rhoSole*dl*Ac;                         % thermal mass of the fluid in one pipe node

% massflow and velocity
Massenstrom = qdot_hi*H/(cpSole*dTdesign);
Geschw_Sole = Massenstrom/rhoSole/Ac;

% heat transfer of pipe to fluid (see Huber 1997)
Re = Geschw_Sole*Di/vSole;              % Reynolds number
Pr = vSole*rhoSole*cpSole/lambdaSole;   % Prandtl number
zeta = 1/(1.82*log10(Re)-1.64)^2;       % Petukhov equation
K1 = 1+27.2*zeta/8;
K1_o = 1.106886;
K2 = 11.7+1.8*Pr^(-1.3);
Ceta_0 = 0.031437;
St_o = Ceta_0/8/(K1_o+K2*(Ceta_0/8)^0.5*(Pr^(2/3)-1));
Nu_o = St_o*1e4*Pr;                     % Nu equation for Re = 1e4
St = zeta/8/(K1+K2*(zeta/8)^0.5*(Pr^(2/3)-1));

b_e = B_u/(2*r1);      % eccentricity of the pipes in a double U-tube
sigma = (lambdaFill-lambdaErde)/(lambdaErde+lambdaFill); % conduction parameter
R_s = 1/(2*pi*lambda_Sondenrohr)*ln_rsr0;

% VDI Waermeatlas (2006), Springer Verlag
Nu_mq_1 = 4.36;
Nu_mq_2 = 1.953*(Re*Pr*Di/H)^(1/3);
Nu_laminar = (Nu_mq_1^3+0.6^3+(Nu_mq_2-0.6)^3)^(1/3);

if Re >= 10000                          % fully turbulent flow
    Nu = St*Re*Pr;                      
elseif Re > 2300                        % intermediate flow
    Nu = Nu_laminar*exp(log(Nu_o/Nu_laminar)*log(Re/2300)/log(10000/2300));
else                                    % fully laminar flow
    Nu = Nu_laminar;        
end

% heat transfer coefficoents
alpha = Nu*lambdaSole/Di;                               % heat transfer coeff. with massflow
alpha_eff = 1/(1/alpha+r0/lambda_Sondenrohr*ln_rsr0);   % and with conduction in the pipe wall
alpha0 = lambdaSole/(r0*(1-sqrt(1/2)));                 % heat transfer coeff. without massflow
alpha0_eff = 1/(1/alpha0+r0/lambda_Sondenrohr*ln_rsr0); % and with conduction in the pipe wall

% thermal resistance (Huber 1997)
R1_EWS = 1/4*(1/(2*pi*alpha_eff*r0*dl)+1/(2*pi*lambdaFill*dl)*log((r1-rz1)/r0)); % eq. 2-16 Huber 1997
R2_EWS = 1/(2*pi*dl)*(1/lambdaFill*log(r1/rz1)+1/lambdaErde*log(rz2/r1));        
R10_EWS = 0.25*(1/(2*pi*alpha0_eff*r0*dl)+1/(2*pi*lambdaFill*dl)*log((r1-rz1)/r0));
R20_EWS = 1/(2*pi*dl)*(1/lambdaFill*log(r1/rz1)+1/lambdaErde*log(rz2/r1));        

% Ra : internal thermal resistance, Rb: borehole thermal resistance
% equations of Hellström (1991)
Ra = 1/(pi*lambdaFill) ...
    *(log((sqrt(2)*b_e*r1)/r0)-1/2*log(2*b_e*r1/r0)-1/2*sigma*log((1-b_e^4)/(1+b_e^4))) ...
    +(1/(2*pi*r0*alpha))+R_s;
Ra0 = 1/(pi*lambdaFill) ...
    *(log((sqrt(2)*b_e*r1)/r0)-1/2*log(2*b_e*r1/r0)-1/2*sigma*log((1-b_e^4)/(1+b_e^4))) ...
    +(1/(2*pi*r0*alpha0))+R_s;


beta = lambdaFill*(1/(r0*alpha)+1/lambda_Sondenrohr*ln_rsr0);
% old equation
% Rb = (1/(8*pi*lambdaFill)) ...
%     *(beta+log(r1/r0)+log(r1/B_u)+sigma*log(r1^4/(r1^4-B_u^4/16)) ...
%     -(r0^2/B_u^2*(1-sigma*(B_u^474)/(r1^4-B_u^4/16)^2)) ...
%     /((1+beta)/(1-beta)+r0^2/B_u^2*(1+sigma*B_u^4*r1^4/(r1^4-B_u^4/16)^2)));
% new equation, corrected according to Huber (2020), Hf 21/04/2021
Rb = (1/(8*pi*lambdaFill)) ...
    *(beta+log(r1/r0)+log(r1/B_u)+sigma*log(r1^4/(r1^4-B_u^4/16)) ...
    -(r0^2/B_u^2*(1-sigma*0.25*B_u^4/(r1^4-B_u^4/16))^2) ...
    /((1+beta)/(1-beta)+r0^2/B_u^2*(1+sigma*B_u^4*r1^4/(r1^4-B_u^4/16)^2)));

% old equation
% Rb0 = (1/(8*pi*lambdaFill)) ...
%     *(beta+log(r1/r0)+log(r1/B_u)+sigma*log(r1^4/(r1^4-B_u^4/16)) ...
%     -(r0^2/B_u^2*(1-sigma*(B_u^474)/(r1^4-B_u^4/16)^2)) ...
%     /((1+beta)/(1-beta)+r0^2/B_u^2*(1+sigma*B_u^4*r1^4/(r1^4-B_u^4/16)^2)));

% new equation, Hf 21/04/2021
beta0 = lambdaFill*(1/(r0*alpha0)+1/lambda_Sondenrohr*ln_rsr0);
Rb0 = (1/(8*pi*lambdaFill)) ...
    *(beta0+log(r1/r0)+log(r1/B_u)+sigma*log(r1^4/(r1^4-B_u^4/16)) ...
    -(r0^2/B_u^2*(1-sigma*0.25*B_u^4/(r1^4-B_u^4/16))^2) ...
    /((1+beta0)/(1-beta0)+r0^2/B_u^2*(1+sigma*B_u^4*r1^4/(r1^4-B_u^4/16)^2)));

if Ra < 4 * Rb
    R1 = Ra/(4*dl);
    R2 = (Rb-Ra/4)/dl+1/(2*pi*dl*lambdaErde)*log(rz2/r1);
    R10 = Ra0/(4*dl);
    R20 = (Rb0-Ra0/4)/dl+1/(2*pi*dl*lambdaErde)*log(rz2/r1);        
else
    R1 = R1_EWS;
    R2 = R2_EWS;
    R10 = R10_EWS;
    R20 = R20_EWS;
end

% temperaturverlauf axialer Richtung
L0  = cpSole*Massenstrom;      % konstant
L00 = 0;
L1  = 1/R1;
L2  = 1/R2;
L10 = 1/R10;
L20 = 1/R20;

% matrizen Ad,Bd,Cd,Dd für Tdown
Ad = zeros(DimAxi05,DimAxi05);
Ad0 = zeros(DimAxi05,DimAxi05);
for h = 1:DimAxi05
    Ad(h,h) = -(L0/(mcpSole)+L1/(2*mcpSole));
    Ad0(h,h) = -(L00/(mcpSole)+L10/(2*mcpSole));
end
  
for h = 1:DimAxi05-1
    Ad(h+1,h)=L0/(mcpSole);
    Ad0(h+1,h)=L00/(mcpSole);
end

Bd=zeros(DimAxi05,DimAxi05+1);
Bd0=zeros(DimAxi05,DimAxi05+1);
Bd(1,1)=L0/(mcpSole);
Bd0(1,1)=L00/(mcpSole);

for h=1:DimAxi05
    Bd(h,h+1)=L1/(2*mcpSole);
    Bd0(h,h+1)=L10/(2*mcpSole);
end

Cd = eye(DimAxi05);
Dd = zeros(DimAxi05,DimAxi05+1);

% Matrizen Au,Bu,Cu,Du für Tup
Au = zeros(DimAxi05,DimAxi05);
Au0 = zeros(DimAxi05,DimAxi05);

for h = 1:DimAxi05
    Au(h,h) = -(L0/(mcpSole)+L1/(2*mcpSole));
    Au0(h,h) = -(L00/(mcpSole)+L10/(2*mcpSole));
end
  
for h = 1:DimAxi05-1
    Au(h+1,h) = L0/(mcpSole);
    Au0(h+1,h) = L00/(mcpSole);
end

Bu = zeros(DimAxi05,DimAxi05+1);
Bu0 = zeros(DimAxi05,DimAxi05+1);
Bu(1,1) = L0/(mcpSole);
Bu0(1,1) = L00/(mcpSole);

for h = 1:DimAxi05
    Bu(h,h+1)=L1/(2*mcpSole);
    Bu0(h,h+1)=L10/(2*mcpSole);
end

Cu = Cd;
Du = zeros(DimAxi05,DimAxi05+1);

% berechnung von Tradial, von Luzi Valär
Dim1 = (DimRad-2)*DimAxi05;
% r = zeros(1:DimRad);
r = zeros(DimRad,1);    % corrected, Hf 01/05/2021
r(1) = r1;
r(2) = r2;
for h = 3:DimRad
    r(h) = r(h-1)+(Rechenradius-r1)*(1-Gitterfaktor)/(1-Gitterfaktor^(DimRad-1))*Gitterfaktor^(h-2);
end
    
% rz = zeros(1:DimRad); 
rz = zeros(DimRad,1);   % corrected, Hf 01/05/2021
rz(1) = sqrt((r(1)^2+r0^2)/2);
for h = 2:DimRad
    rz(h) = sqrt((r(h)^2+r(h-1)^2)/2);
end

% L = zeros(1:DimRad);  
L = zeros(DimRad,1);    % corrected, Hf 01/05/2021
L(1) = L1; 
L(2) = L2;
for h = 3:DimRad-1
    L(h)=1/(1/(2*pi*dl)*(1/lambdaErde*log(rz(h)/rz(h-1))));
end
L(DimRad)=1/(1/(2*pi*dl)*(1/lambdaErde*log(r(DimRad)/rz(DimRad-1))));


% C = zeros(1:DimRad);
C = zeros(DimRad,1);    % corrected, Hf 01/05/2021
C(1) = cpFill*rhoFill*pi*(r(1)^2-4*r0^2)*dl;
for h = 2:DimRad
    C(h) = cpErde*rhoErde*pi*(r(h)^2-r(h-1)^2)*dl;
end

a = zeros(DimRad-2,DimRad-2);
for h = 1:DimRad-2
    a(h,h) = (-L(h)-L(h+1))/C(h);
end
for h = 1:DimRad-3
    a(h,h+1) = L(h+1)/C(h);
    a(h+1,h) = L(h+1)/C(h+1);
end

b = zeros(DimRad-2,2);
b(1,1) = L(1)/C(1);
b(DimRad-2,2) = L(DimRad-1)/C(DimRad-2);
    
Ar = a;
Ar(DimRad-1:2*(DimRad-2),DimRad-1:2*(DimRad-2)) = a;

for h = 2:DimAxi05-1
    Ar(h*(DimRad-2)+1:(h+1)*(DimRad-2),h*(DimRad-2)+1:(h+1)*(DimRad-2)) = a;
end

Br = b;

for h=1:DimAxi05-1
    Br(h*(DimRad-2)+1:(h+1)*(DimRad-2),2*h+1:2*h+2)=b;   
end
    
Cr = eye((DimRad-2)*DimAxi05);
Dr = zeros((DimRad-2)*DimAxi05,DimAxi);

% andere Matrizen
Cdl = zeros(DimAxi05,1);
Cdl(DimAxi05,1) = 1;
Cdl = Cdl';
c1 = zeros(DimAxi05,Dim1);
for h = 1:DimAxi05
    c1(1,1)=1;
    c1(h,(h-1)*(DimRad-2)+1)=1;
end
c31 = zeros(1,DimAxi05);
c3(1,1)=1;
for h = 1:DimAxi05-1
    c3(1+2*h,1+h)=1;
end
c33 = zeros(DimAxi,DimAxi05);
c33(1:DimAxi-1,1:DimAxi05) = c3;
c41 = zeros(1,DimAxi05);
c4 = c41;
c4(2:DimAxi,1:DimAxi05) = c3;
c5 = ones(DimAxi05,1);           
c6 = zeros(DimRad-2,3*(DimRad-2));
for i=2:DimRad-2
    c6(1,DimRad-1)=1;
    c6(i,DimRad+i-2)=1;
end

%% Randbedingungen
Ts_Trichter = 7*24*3600;    % in s (1 week according to Huber)
Dr_Trichter = 1;
t_Trichter = linspace(Ts_Trichter,Ts_Trichter*5000,5000);
r_Trichter = linspace(Dr_Trichter,Dr_Trichter*20,20);
ts = H^2/(9*aErde);         % Zeitkonstante der Sonde
Es = t_Trichter/ts;         % Eskilon number
lnEs = log(Es);

% g-function, approach of Eskilon
if startfall == 2
    xS = [-4 -2 0 2 3];
    if SondenFall == 1          % 1 Sonde
        yS = [4.82 5.69 6.29 6.57 6.6]; % coeffs for single probe
    elseif SondenFall == 2      % 2 Sonden B/H = 0.1
        yS = [4.99 6.37 7.62 8.06 8.08];
    elseif SondenFall == 3      % 2 Sonden B/H = 0.05
        yS = [5.30 6.92 8.20 8.67 8.71];
    elseif SondenFall == 4      % 3x6 Sonden B/H = 0.1
        xS = [-4 -3 -2 0 2 3];  % extra y-value for x = -3
        yS = [5.00 7.00 9.15 16.40 19.75 20.05];
    elseif SondenFall == 5      % 5x10 Sonden B/H = 0.1
        xS = [-4 -3 -2 0 2 3];  % extra y-value for x = -3
        yS = [5.00 7.8 10.2 22.75 29.5 30.05];
    end
    
    % polynomial part of the g-function
    npol = 4;
    p = polyfit(xS,yS,npol);
    g = polyval(p,lnEs);
    
    % correct the values for log(Es) <= -4
    idx = logical(lnEs <= -4);
    g(idx) = yS(1) + 0.5*(lnEs(idx)+4);
    % correct for log(Es) >= 2.5
    idx = find(lnEs>=2.5, 1, 'first');  % index to first value above 2.5
    g(logical(lnEs >= 2.5)) = g(idx);   % set all values above Es 2.5 to g(2.5)

else % startfall ~= 2
    % g-function values for single probe (Eskilon 1987)
    g = ones(1,length(Es))*log(H/2/Rechenradius); 
    idx = logical(lnEs >= 1);     % index to Es < 1
    g(idx) = g(idx) + 0.5*lnEs(idx); 
end

% Radial temperature funnel
gfunction = zeros(length(t_Trichter),length(r_Trichter));
for ii = 1:length(r_Trichter)
    % rb/H = 0.0005 for the g-function values
    % g(rm) = g(rb) - log(rm/rb), rb = 0.0005*H
    gfunction(:,ii) = max(0,g - log(r_Trichter(ii)/H/0.0005));
end

% Randbedingungen für Tearth
mu = linspace(0,H,DimAxi05);
TEarth0 = zeros(DimRad-1,DimAxi05);
if LastYear >= 1                                % lastyear of calculation is 1 or bigger
    t_start = (LastYear-1)*8760*3600;           % start time is last year of precalc - 1
    t_start_init = (LastYear-1/3)*8760*3600;    % Huber 1999: init with 2/3 of the last year
    Es_start = t_start_init*9*aErde/H^2;        % Eskilon number at start time
    idx = find(Es >= Es_start, 1, 'first');     % find first entry when Es values are above Es_start
    g_start = g(idx);                           % take the value of the g-function as start condition
    for ii = 1:DimAxi05                         % initialize TEarth
        for iii = 1:DimRad-1                    % Fit mit g-function
            TEarth0(iii,ii) = Bodentemp + mu(ii)*TGrad ...
                - qdot_precalc/(DimAxi05)*((g_start-log(rz(iii+1)/H/0.0005))...
                /(2*pi*lambdaErde));
        end
    end    
    % das Vorgehen hier entspricht noch nicht so ganz
    % der Beschreibung von Huber 1999 im Kapitel 2.5
else                                            % LastYear is assumed to be 0
    t_start = 0;
    for ii = 1:DimAxi05
        TEarth0(:,ii) = Bodentemp + mu(ii)*TGrad;
    end
end
T_null = TEarth0(end,:)';
teta_fluid_ini = mean(T_null);
Tearth_anf = TEarth0(1:end-1,:);

% Anfangsbedingungen für Tdown,Tup
Tdown_0 = Tearth_anf(1,:)';
Tup_0 = flipud(Tdown_0);

% display initial conditions
if show
    % plot(lnEs,g)        % plot g-function
    disp(['Time constant of the probe field (in years) = ' num2str(ts/3600/8760)])
    disp(['Year of precalculation of the ground temperatures = ' num2str(LastYear)])
    disp(['Ra = ', num2str(Ra)])
    disp(['Rb = ', num2str(Rb)])
    Rb_check = R1_EWS*dl + 1/(2*pi*lambdaFill)*log(r1/rz1);
    disp(['alternative calculated Rb = ', num2str(Rb_check)])
    disp('saving parameters to ''GSHX_init.mat''')
    save GSHX_init
end
end % end of function

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2021, Solar-Institute Juelich of the FH Aachen.
%  Additional Copyright for this file see list auf authors.
%  All rights reserved.
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are 
%  met:
%  1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
%  2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%  3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
%  THE POSSIBILITY OF SUCH DAMAGE.
%  
%  ************************************************************************
%  author list:     fab -> Fabian Ochs
%                   hf  -> Bernd Hafner
%
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
%  Ver.     Author  Changes                                     Date
%  5.1.0    fab     created, based on Diss. Bianchi ETH Zurich  01dec2012
%  5.1.1    hf      adapted to carnot input and output struct.  04mar2013 
%  7.1.0    hf      created Callback from initialisation script 18apr2021
%  7.1.1    hf      corrected equation for Rb                   21apr2021
%  7.1.2    hf      avoid extrapolation of g function at start  25apr2021
%  7.1.3    hf      added g-function of Carslaw, Jaeger         29apr2021
%                   changed Kelvin to Celsius temperatures 
%                   values for xS = -3 (3x6 and 5x10 field)
%                   different g-functions for log(Es) < -4 and > 2.5
%  7.1.4    hf      redefinition of startfall                   02may2021