%% dwd2wdb converts German DWD 2016 TRY to WDB
%% Description
%  dwd2wdb converts weather data from German DWD 2016 TRY file format to 
%  Carnot WDB. The solar position is calculated by carlib
%  functions since TRY do not have this information.
%
%% SYNTAX: 
%  outmat = dwd2wdb(infile, outfile,  lat, long, long0, station, country, comment)
%
% altenative SYNTAX:   outmat = dwd2wdb
%   opens dialog windows for the parameters
%
%% Inputs
% infile : character string of the input file name, created by [DWD 2016]
% The values of infile have to be in following order:
%  1    RW Rechtswert                                                    [m]       {3670500;3671500..4389500}
%  2    HW Hochwert                                                      [m]       {2242500;2243500..3179500}
%  3    MM Monat                                                                   {1..12}
%  4    DD Tag                                                                     {1..28,30,31}
%  5    HH Stunde (MEZ)                                                            {1..24}
%  6    t  Lufttemperatur in 2m Hoehe ueber Grund                        [GradC]
%  7    p  Luftdruck in Standorthoehe                                    [hPa]
%  8    WR Windrichtung in 10 m Hoehe ueber Grund                        [Grad]    {0..360;999}
%  9    WG Windgeschwindigkeit in 10 m Hoehe ueber Grund                 [m/s]
% 10    N  Bedeckungsgrad                                                [Achtel]  {0..8;9}
% 11    x  Wasserdampfgehalt, Mischungsverhaeltnis                       [g/kg]
% 12    RF Relative Feuchte in 2 m Hoehe ueber Grund                     [Prozent] {1..100}
% 13    B  Direkte Sonnenbestrahlungsstaerke (horiz. Ebene)              [W/m^2]   abwaerts gerichtet: positiv
% 14    D  Diffuse Sonnenbetrahlungsstaerke (horiz. Ebene)               [W/m^2]   abwaerts gerichtet: positiv
% 15    A  Bestrahlungsstaerke d. atm. Waermestrahlung (horiz. Ebene)    [W/m^2]   abwaerts gerichtet: positiv
% 16    E  Bestrahlungsstaerke d. terr. Waermestrahlung                  [W/m^2]   aufwaerts gerichtet: negativ
% 17    IL Qualitaetsbit bezueglich der Auswahlkriterien                           {0;1;2;3;4}
% 
% File format information (FORTRAN 77 style):
% I7,1X,I7,1X,I2,1X,I2,1X,I2,1X,F5.1,1X,I4,1X,3I,1X,F4.1,1X,I1,1X,F4.1,1X,I3,1X,I4,1X,I4,1X,I3,1X,I4,2X,I1
% 
%% Outputs
% outfile     : character string of the output file name
%               The outfile should follow the definition:
%                   CC_city.dat 
%               where
%               CC = 2-letter (Alpha 2) code of the country (ISO 3166-1)
%               city = name of the city, use english name if available
% lat         : [-90,90] north positive
% long        : [-180,180] west positive
% long0       : reference longitude (timezone), [-180,180] west positive
% station     : name of the station
% country     : name of the country
% comment     : free comment
%
% The output matrix has the CARNOT form as described in WDB_format.m
% As no collector position is defined, a horizontal plane is assumed.
%
% see also try2wdb, tmy2wdb
% 
%% Literature
% DWD 2016: https://www.dwd.de/DE/leistungen/testreferenzjahre/testreferenzjahre.html

function outmat = dwd2wdb(infile,outfile,lat,long,long0,station,country,comment)
if nargin == 0     % no parameter given
    [infile, pathname, filter] = ...
        uigetfile({'*.dat','TRY data file'; ...
            '*.mat', 'MAT-files'; '*.*', 'All files'}, ...
            'Select input data file');
    if filter == 0  
        return
    end
    infile = fullfile(pathname,infile);
    outfile = input('Name for output weather data file : ', 's');
    station = input('Name of the station : ', 's');
    country = input('Name of the country : ', 's');
    comment = input('Comment : ', 's');
    lat = input('Geographical latitude [-90,90] north positive : '); 
    long = input('Geographical longitude [-180,180] west positive : '); 
    long0 = input('Geographical longitude of the timezone [-180,180] west positive : '); 
elseif nargin ~= 8
  help dwd2wdb
  error('Number of input arguments must be 0 or 8')
end

inmat = txt2mat(infile);
if size(inmat,1) < size(inmat,2)
    inmat = inmat';
end

outmat = zeros(size(inmat,1),19);
% time information in dwd try is the average of the past hour
outmat(:,1) = 1800:3600:(3600*8760);    % time in s
% time comment with tvalue will be set at the end
% outmat(:,2) = tvalue(outmat(:,1));      % tstring

% solar postion from carlib since TRY have no sun information
[~,~,zenith,azimuth,~] = sunangles(outmat(:,1),lat,long,long0);
fb = cos(pi/180*zenith);                % factor for normal beam radiation is cos
fb = max(fb,0.001);                     % limit to 0.001

%  6    t  Lufttemperatur in 2m Hoehe ueber Grund                        [GradC]
%  7    p  Luftdruck in Standorthoehe                                    [hPa]
%  8    WR Windrichtung in 10 m Hoehe ueber Grund                        [Grad]    {0..360;999}
%  9    WG Windgeschwindigkeit in 10 m Hoehe ueber Grund                 [m/s]
% 10    N  Bedeckungsgrad                                                [Achtel]  {0..8;9}
% 11    x  Wasserdampfgehalt, Mischungsverhaeltnis                       [g/kg]
% 12    RF Relative Feuchte in 2 m Hoehe ueber Grund                     [Prozent] {1..100}
% 13    B  Direkte Sonnenbestrahlungsstaerke (horiz. Ebene)              [W/m^2]   abwaerts gerichtet: positiv
% 14    D  Diffuse Sonnenbetrahlungsstaerke (horiz. Ebene)               [W/m^2]   abwaerts gerichtet: positiv
% 15    A  Bestrahlungsstaerke d. atm. Waermestrahlung (horiz. Ebene)    [W/m^2]   abwaerts gerichtet: positiv
% 16    E  Bestrahlungsstaerke d. terr. Waermestrahlung                  [W/m^2]   aufwaerts gerichtet: negativ
% 17    IL Qualitaetsbit bezueglich der Auswahlkriterien                           {0;1;2;3;4}

outmat(:,3) = zenith;                   % zenith from carlib calculation
outmat(:,4) = azimuth;                  % azimuth from carlib calculation
outmat(:,5) = min(1350,inmat(:,13)./fb);% I_dir_norm
outmat(:,6) = inmat(:,14); 				% I_dfu_hor
outmat(:,7) = inmat(:,6);				% Tamb
outmat(:,8) = skytemperature(outmat(:,7),inmat(:,12),inmat(:,10)/8); % skytemperature(Tamb,hum,cloud)
outmat(:,9) = inmat(:,12);				% relative humiditiy
outmat(:,10) = -9999;               	% precipitation is not known
outmat(:,11) = min(1, inmat(:,10)/8);	% cloud index
outmat(:,12) = inmat(:,7)*100;		    % pressure hPa - Pa
outmat(:,13) = inmat(:,9);			    % wind speed
outmat(:,14) = inmat(:,8);			    % wind direction
outmat(:,15) = zenith;					% collector incidence is zenith angle
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = inmat(:,13);             % Idir on horizontal surface 
outmat(:,19) = inmat(:,14);             % Idfu on surface

% plot sun angles to verify geographical position and time reference
figure
plot([(90-zenith).*10, outmat(:,18)+outmat(:,19)])
s = strrep(outfile,'_','');
title(['sunposition and global radiation ' s])
legend('solar horizon angle * 10', 'global radiation')
figure
plot([(90-zenith).*10, outmat(:,5)])
title(['sunposition and direct beam radiation ' s])
legend('solar horizon angle * 10', 'beam radiation')
disp(' ')
disp('try2wformat: Please check sun position and solar radiation in the figure.')
disp('             Solar height and radiation should be 0 an the same moment at sunrise and sunset.')
disp('             If not check longitude, latitude and time reference.')
disp(' ')

% copy first and last row to assure interpolation 
outmat = [outmat(1,:); outmat(:,:); outmat(end,:)];
outmat(1,1) = 0;                        % first row has time 0
outmat(length(outmat),1) = 8760*3600;   % last row is end of the year
% now all the time values are there: set time comment
outmat(:,2) = tvalue(outmat(:,1),2016); % tstring

outmat = outmat';
fout = fopen(outfile,'w');
fprintf(fout,'%% Format of weather data in CARNOT.\n');
fprintf(fout,'%%   station name:  %s   country: %s\n', station, country);
fprintf(fout,'%%   geographical positon: longitude: %f , latitude: %f\n', lat, long);
fprintf(fout,'%%   reference meridian for time (example: 0° = Greenwich Mean Time): %f\n', long0);
fprintf(fout,'%% Data converted from Test Reference Year. %s \n', comment);
fprintf(fout,'%% Use the Carnot block "weather_from_file" to get the data in your model.\n');
fprintf(fout,'%%\n');
fprintf(fout,'%% col   description                                       units\n');
fprintf(fout,'%% 1     time                                                s\n');
fprintf(fout,'%% 2     timevalue (comment line) format YYYYMMDDHHMM        -\n');
fprintf(fout,'%%       Y is the year, M the month, D the day, H the hour\n');
fprintf(fout,'%% 3     zenith angle of sun (at time, not averaged)         degree\n');
fprintf(fout,'%%       (continue at night to get time of sunrise by\n');
fprintf(fout,'%%       linear interpolation)\n');
fprintf(fout,'%% 4     azimuth angle of sun (0°=south, east negative)      degree\n');
fprintf(fout,'%%       (at time, not average in timestep)\n');
fprintf(fout,'%% 5     direct solar radiation on a normal surface          W/m^2\n');             
fprintf(fout,'%% 6     diffuse solar radiation on surface                  W/m^2\n');             
fprintf(fout,'%% 7     ambient temperature                                 degree centigrade\n'); 
fprintf(fout,'%% 8     radiation temperature of sky                        degree centigrade\n'); 
fprintf(fout,'%% 9     relative humidity                                   percent\n');           
fprintf(fout,'%% 10    precipitation                                       m/s\n');               
fprintf(fout,'%% 11    cloud index (0=no cloud, 1=covered sky)             -\n');                 
fprintf(fout,'%% 12    station pressure                                    Pa\n');                
fprintf(fout,'%% 13    mean wind speed                                     m/s\n');               
fprintf(fout,'%% 14    wind direction (north=0° west=270°)                 degree\n');            
fprintf(fout,'%% 15    incidence angle on surface (0° = vertical)          degree\n');          
fprintf(fout,'%%       (= -9999, if surface orientation is unknown)\n');                        
fprintf(fout,'%% 16    incidence angle in plane of vertical and main       degree\n');            
fprintf(fout,'%%       surface axis (the main axis is parallel to heat\n');                       
fprintf(fout,'%%       collecting pipes in a collector, it is pointing\n');                       
fprintf(fout,'%%       to the center of the earth)\n');                                           
fprintf(fout,'%% 17    incidence angle in plane of vertical and second     degree\n');            
fprintf(fout,'%%       surface axis (the second axis is in the surface\n');                       
fprintf(fout,'%%       and a vertical on the heat collecting pipes in \n');                   
fprintf(fout,'%%       a collector, it is pointing to the horizon)\n%%\n');                   
fprintf(fout,'%% 18    direct solar radiation on surface                   W/m^2\n');   
fprintf(fout,'%% 19    diffuse solar radiation on surface                  W/m^2\n');   
fprintf(fout,'%% UNKNOWN: set -9999 for unknown values\n%%\n');
fprintf(fout,'%%   time        tvalue    zenith   azimuth   Ibn Idfuhor Tamb   Tsky   hum    prec  cloud   p      wspeed  wdir  incidence  tetal   tetat   Idirhor Idfuhor\n');
   
% write matrix row by row to define formats
%             time   tvalue  zenit  azimut  Ibn    Idfuh  Tamb   Tsky   hum    prec   cloud  press  wspeed wdir   incid  tetal  tetat  Idirh  Idfuh
fprintf(fout,'%8.0f  %12.0f  %8.2f  %8.2f  %4.0f  %4.0f  %5.1f  %5.1f  %5.1f  %5.0f  %5.3f  %6.0f  %6.2f  %5.1f  %7.1f  %7.1f  %7.1f  %4.0f  %4.0f\n', ...
       outmat);

status = fclose (fout);
if (status == 0)
    outmat = outmat';
else
    outmat = status;
end

%% Copryright and Versions
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2020, Solar-Institute Juelich of the FH Aachen.
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
% $Revision: 372 $
% $Author: carnot-wohlfeil $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/library_m/weather_and_sun/weather_data_format/src_m/try2wformat.m $
% ***********************************************************************
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
% 
% version   author  changes                                     date
% 7.1.0     hf      created from try2wdb                        30dec2019
% 7.2.0     hf      copy last row for last timestep             01mar2020
%                   last input for skytemperature is cloud index
%                   (not diffuse radiation)
% 7.2.1     hf      added reference year 2016 to tvalue call    11nov2021
% ***********************************************************************
