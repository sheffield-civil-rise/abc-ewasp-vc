%% cloudindex : calculation of the cloudiness degree in 1/8
%% Function call
%  c = cloudindex(time,I,latitude,longitude,longitudenull,SkyType)
%% Inputs
%            time          :   time in Seconds
%            I             :   global radiation on horizontal, W/m2
%            latitude      :   geographical latitude ([-90,90],north positive)
%            longitude     :   geographical longitude ([-180,180],West positive)
%            longitudenull :   Referenzlängengrad (Zeitzone)
%            SkyType       :   1,2,3,4		
%       Eingabe des Typs der Atmosphäre am Standort (SkyType):
%           1 - Hochgebirge
%           2 - Flachland
%           3 - Großstadt
%           4 - Industriegebiet
%% Outputs
%            1. c             :   cloudiness degree in 1/8, range 0...1

function erg = cloudindex(time,I,latitude,longitude,longitudenull,SkyType)

% Stützstellen für Transmissionsfaktoren "TauXY" (nach Meliß,1993, S.38):
SunAngleRef	= [0 2.5 5 10 20 30 40 60 90];
% a)Transmssion nach Rayleigh-Streuung in der Atmosphäre:
TauRS = [.01 .450 .575 .681 .790 .837 .870 .895 .906];
% b)Transmission nach Absorption durch Spurengase in der Atmosphäre:
TauAB = [.01 .750 .805 .838 .870 .888 .900 .908 .913];	
% c)Transmission nach Streuung und Absorption durch Aerosol in der Atmosphäre ...
TauMS1 = [.01 .650 .754 .846 .920 .959 .980 .993 1;...	% ... über Hochgebirge
   		.01 .340 .465 .613 .750 .823 .870 .911 .925;...	% ... über Flachland
  	      .01 .150 .274 .417 .600 .688 .740 .790 .839;...	% ... über Großstadt
     	   .01 .070 .135 .257 .430 .551 .620 .705 .744];	% ... über Industriegebiet
   
   
   % Skytype wird als Ziffer von der Popup-Liste der Maske geliefert;
   % Achtung: In Popup-Liste auf richtige Reihenfolge achten!
TauMS = TauMS1(SkyType,:);


% Besetzen diverser Variablen mit Default-Werten:
% DeclDayAmpl = -23.45 * pi/180; 
a = 0.75;                       % Parameter für Berechnung von "CloudIndex"
b = 3.2;                        % Parameter für Berechnung von "CloudIndex"

DEG2RAD =  0.01745329251994;
RAD2DEG =  57.29577951308232;

CloudIndex = 0;
day = time/24/3600;     % Tage + Tage in den Vormonaten
   
% Tagesmittelwert der extraterrestrischen Strahlung "IextraDay", die senkrecht
% auf eine zur Sonne orientierten Fläche fällt (nach Duffie/Beckman,1993,S.10):
IextraDay = 1353 * (1+0.033*cos(2*pi*day/365));

% -------------------------------------------------------------------------------
% 	"Decl"			Deklination der Sonne
%	"HourAngle" 	Stundenwinkel der Sonne
%	"zenit"			Zenithwinkel
%	"SunAngle"		Sonnenhöhenwinkel
% 	"azimut"			Azimutwinkel
%	"Iextra"			Extraterrestrische Strahlung auf HORIZONTALE Fläche
%	"SunHour"		Tag-/Nachterkennung Êrkennung
%	"dimness"		Trübungsfaktor der Atmosphäre
% 	"Idirclear"		direkte Strahlung auf der Erdoberfläche für KLAREN Himmel
% 	"Idfuclear"		diffuse Strahlung auf der Erdoberfläche für KLAREN Himmel
% -------------------------------------------------------------------------------
zeitgz = time;        % standard time in seconds */

% declination of the sun */
xj = 0.9856*(time/86400.)-2.72;
xbogen = DEG2RAD*xj;
arg2 = DEG2RAD*(xj - 77.51 + 1.92*sin(xbogen));
arg3 = sin(arg2);
delta = asin(0.3978*arg3);                      % declination angle */
% deltaangle = RAD2DEG*delta;
arg5 = DEG2RAD*2.0*xj+24.99+3.83*sin(xbogen);

% determine solar hour angle in radian (noon = 0,  6 a.m. = -PI) */
z   = 60.0*(-7.66*sin(xbogen)-9.87*sin(arg5));  % z is in seconds */
moz = zeitgz + (longitudenull-longitude)*240.0;
woz = moz + z;                                  % true local time */
HourAngle = DEG2RAD*(woz - 43200.0)*0.00416666666667; % is in seconds */
latitude  = DEG2RAD*latitude;

% solar zenith angle in degrees (0° = zenith position, 90° = horizont) */
coszenit = sin(latitude)*sin(delta) ...
    + cos(latitude)*cos(delta)*cos(HourAngle);
zenith  =  acos(coszenit)*RAD2DEG;

% Sonnenhöhenwinkel "SunAngle":
SunAngle = 90 - zenith;
if SunAngle < 0.01
    SunAngle = 0.01; % da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.
end

% Auf eine HORIZONTALE (= der Erdoberfläche parallelen) Fläche unter dem
% Winkel "zenit" treffende extraterrestrische Strahlung "Iextra":
Iextra = IextraDay * coszenit;
% Kennung für Tagesstunden "SunHour":
if (Iextra > 0)
    SunHour = 1;
else
    SunHour = 0;
end

% Spline-Interpolation der Zwischenwerte der Transmissionsfaktoren "TauXY":
Trs = interp1(SunAngleRef,TauRS,SunAngle,'pchip');
Tab = interp1(SunAngleRef,TauAB,SunAngle,'pchip');
Tms = interp1(SunAngleRef,TauMS,SunAngle,'pchip');

% Trübungsfaktor "dimness" (nach Meliß, 1993, S.38ff):
dimness = 1 + ( (log(Tms) + log(Tab)) / log(Trs) );

% KLARER Himmel: Transmissionsfaktor "Taudir" und DIREKTstrahlung "Idirclear"
% auf eine zur Einfallsrichtung senkrechte Fläche (nach Kasten/Meliß,1993,S.38ff):
Taudir = exp( -dimness/(0.9 + 9.4 * coszenit) );
Idirclear = Iextra * Taudir;

% KLARER Himmel: Transmissionsfaktor "Taudfu" und DIFFUSstrahlung "Idfuclear"
% auf eine zur Einfallsrichtung senkrechte Fläche
%(nach Liu/Jordan bzw. nach Duffie/Beckman,1991,S.75):
Taudfu = 0.2710 - 0.2939 * Taudir;
Idfuclear	= Iextra * Taudfu;

% KLARER Himmel: Globalstrahlung auf HORIZONTALE "Iclear":
Iclear= Idirclear + Idfuclear;

% Unterdrückung von nächtlichen Offset-Werten in "I":
if (SunHour == 0)&&(I > 0)
    I = 0;
end

% -------------------------------------------------------------------------------
% 	"ClearIndex"	Klarheitsindex der Atmosphäre (TAG)
% 	"CloudIndex"	Bedeckungsgrad des Himmels (TAG)
% 	"Idir"			direkte Strahlung auf der Erdoberfläche
% 	"Idfu"			diffuse Strahlung auf der Erdoberfläche
% -------------------------------------------------------------------------------
if SunHour == 1
    CloudFraction = I/Iclear;
    
    if CloudFraction > 1
        % ggfs. Korrektur, damit "CloudIndex" <= 1 bleibt:
        CloudFraction = 1;
    end
    CloudIndex = ( 1/a * (1 - CloudFraction) )^(1/b);
    
    if CloudIndex > 1
        CloudIndex = 1;
    end
end

% Diskretisierung von "CloudIndex" in Okta [0, 1/8, 2/8, ... ,8/8]:
if CloudIndex >= 1
    CloudIndex = 1;
elseif CloudIndex >= .875
    CloudIndex = .875;
elseif CloudIndex >= .75
    CloudIndex = .75;
elseif CloudIndex >= .625
    CloudIndex = .625;
elseif CloudIndex >= .5
    CloudIndex = .5;
elseif CloudIndex >= .375
    CloudIndex = .375;
elseif CloudIndex >= .25
    CloudIndex = .25;
elseif CloudIndex > 0
    CloudIndex = .125;
elseif CloudIndex == 0
    CloudIndex = 0;
end

erg = CloudIndex;
% erg(1) = CloudFraction;
end % of function


% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%
% Modifizierung des M-Skriptes metcalc.m von Markus Werner, Solar-Institut Juelich
%
% Thomas Wenzel, 18.10.1999
% Bernd Hafner,  07feb2020    adapted comments to publish function
