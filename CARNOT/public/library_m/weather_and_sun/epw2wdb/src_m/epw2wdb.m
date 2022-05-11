%% epw2wdb converts weather data from EnergyPlus format epw to Carnot format WDB
% The solar position is calculated by carlib functions since EPW do not 
% have this information.
%
% SYNTAX: outmat = epw2wdb(infile, outfile)
%
% altenative SYNTAX:   outmat = epw2wdb
%   opens dialog windows for the parameters
% 
% Geographical position and location name is taken from the data file (line 1):
% LOCATION, 
%   A1, \field city \type alpha, 
%   A2, \field State Province Region \type alpha
%   A3, \field Country \type alpha
%   A4, \field Source \type alpha
%   N1, \field WMO \note usually a 6 digit field. Used as alpha in EnergyPlus type alpha
%   N2 , \field Latitude \units deg \minimum -90.0 \maximum +90.0 \default 0.0
%       \note + is North , - is South , degree minutes represented in decimal (i.e. 30 minutes is .5) \type real
%   N3 , \field Longitude \units deg \minimum -180.0 \maximum +180.0 \default 0.0
%       \note - is West , + is East , degree minutes represented in decimal (i.e. 30 minutes is .5) \type real
%   N4 , \field TimeZone \units hr - not on standard units list??? \minimum -12.0 \maximum +12.0 \default 0.0
%       \note Time relative to GMT. \type real
%   N5 ; \field Elevation \units m \minimum -1000.0 \maximum < +9999.9 \default 0.0 \type real
% 
% examples
% LOCATION,BERLIN,-,DEU,IWEC Data,103840,52.47,13.40,1.0,49.0
% LOCATION,Montreal Int'l,PQ,CAN,WYEC2-B-94792,716270,45.47,-73.75,-5.0,36.0
%
% infile : character string of the input file name, 
% created from [EnergyPlus Weather Data Sets 2020]
% The values of infile have to be in following order:
% N1, \field Year
% N2, \field Month
% N3, \field Day
% N4, \field Hour
% N5, \field Minute
% A1, \field Data Source and Uncertainty Flags
%     \note Initial day of weather file is checked by EnergyPlus for validity (as shown below)
%     \note Each field is checked for "missing" as shown below. Reasonable values, calculated
%     \note values or the last "good" value is substituted.
% N6, \field Dry Bulb Temperature                     \units C    \minimum> -70   \maximum< 70        \missing 99.9
% N7, \field Dew Point Temperature                    \units C    \minimum> -70   \maximum< 70        \missing 99.9
% N8, \field Relative Humidity                        \minimum 0      \maximum 110        \missing 999.
% N9, \field Atmospheric Station Pressure \units Pa   \minimum> 31000 \maximum< 120000    \missing 999999.
% N10, \field Extraterrestrial Horizontal Radiation   \units Wh/m2    \missing 9999.  \minimum 0          
% N11, \field Extraterrestrial DirectNormalRadiation  \units Wh/m2    \missing 9999.  \minimum 0
% N12, \field Horizontal Infrared Radiation Intensity \units Wh/m2    \missing 9999.  \minimum 0
% N13, \field Global Horizontal Radiation             \units Wh/m2    \missing 9999.  \minimum 0
% N14, \field Direct Normal Radiation                 \units Wh/m2    \missing 9999.  \minimum 0
% N15, \field Diffuse Horizontal Radiation            \units Wh/m2    \missing 9999.  \minimum 0
% N16, \field Global Horizontal Illuminance           \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N17, \field Direct Normal Illuminance               \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N18, \field Diffuse Horizontal Illuminance          \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N19, \field Zenith Luminance                        \units Cd/m2    \missing 9999.   \note will be missing if >= 9999   \minimum 0
% N20, \field Wind Direction                          \units degrees  \missing 999.   \minimum 0  \maximum 360
% N21, \field Wind Speed                              \units m/s      \missing 999.   \minimum 0  \maximum 40
% N22, \field Total Sky Cover                         \missing 99     \minimum 0      \maximum 10
% N23, \field Opaque Sky Cover (used if Horizontal IR Intensity missing) \missing 99 \minimum 0 \maximum 10
% N24, \field Visibility                              \units km       \missing 9999 
% N25, \field Ceiling Height                          \units m        \missing 99999
% N26, \field Present Weather Observation     
% N27, \field Present Weather Codes
% N28, \field Precipitable Water                      \units mm       \missing 999
% N29, \field Aerosol Optical Depth                   \units thousandths \missing .999
% N30, \field Snow Depth                              \units cm       \missing 999
% N31, \field Days Since Last Snowfall                \missing 99
% N32, \field Albedo                                  \missing 999
% N33, \field Liquid Precipitation Depth              \units mm       \missing 999
% N34; \field Liquid Precipitation Quantity           \units hr       \missing 99      
% 
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
% Literature
% EnergyPlus 2020: EnergyPlus™ Version 9.3.0 Documentation, Auxiliary Programs, U.S.
%   Department of Energy, March 27, 2020 (access 02/08/2020):
%   https://energyplus.net/sites/all/modules/custom/nrel_custom/pdfs/pdfs_v9.3.0/AuxiliaryPrograms.pdf
% EnergyPlus Weather Data Sets 2020 (access 02/08/2020):
%   epw data sets: https://energyplus.net/weather


function outmat = epw2wdb(infile,outfile)
%% check number of inputs
if nargin == 0     % no parameter given
    [infile, pathname, filter] = ...
        uigetfile({'*.dat','EPW data file'; ...
            '*.mat', 'MAT-files'; '*.*', 'All files'}, ...
            'Select input data file');
    if filter == 0  
        return
    end
    infile = fullfile(pathname,infile);
    outfile = input('Name for output weather data file : ', 's');
%     station = input('Name of the station : ', 's');
%     country = input('Name of the country : ', 's');
%     comment = input('Comment : ', 's');
%     lat = input('Geographical latitude [-90,90] north positive : '); 
%     long = input('Geographical longitude [-180,180] west positive : '); 
%     long0 = input('Geographical longitude of the timezone [-180,180] west positive : '); 
elseif nargin ~= 2
  help epw2wdb
  error('Number of input arguments must be 0 or 2')
end

%% read LOCATION
delimiter = ',';
endRow = 1;
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';
% Open the text file.
fileID = fopen(infile,'r');
% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');

% check for correct informations
if ~strcmp(dataArray{1}, 'LOCATION')
    error('epw2wdb: Input file must contain LOCATION info in the first line')
end
locstr = cellstr(dataArray);
loc1 = str2double(locstr);
loc2 = loc1(~isnan(loc1));

locName = [locstr{2}, ' ', locstr{3}, ' ', locstr{4}, ' ', locstr{5}, ' ', locstr{6}];
% lat : Geographical latitude [-90,90] north positive
lat = loc2(end-3);
% long = input('Geographical longitude [-180,180] west positive
long = -loc2(end-2);   % west is negative in EPW
% long0 : Geographical longitude of the timezone [-180,180] west positive
long0 = -15 * loc2(end-1); % timezone is in h in EPW, transfer to reference meridian for WBD

%% read data
delimiter = ',';
startRow = 9;
formatSpec = '%f%f%f%f%f%C%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';

% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

% commented out as txt2mat is not working :-(
% t2mOpts = {'NumHeaderLines', 8                          , ...
%            'NumColumns'    , 35                         , ...
%            'Format'        , [repmat('%f,',1,5) '%*s,' repmat('%f,',1,28), '%f'] , ...
%            'BadLineString' , {'Warng'}                  };
% inmat = txt2mat(infile, t2mOpts{:});


%% select columns of imported data and calulate output
% skip column 6 (A1) do be compatible with the N1...N35 indices
nrow = length(dataArray{1});
inmat = zeros(nrow,34);
idx = 1;
for n = [1:5 7:35]
    inmat(:,idx) = dataArray{n};
    idx = idx+1;
end
outmat = zeros(nrow,19);
% time information in epw is the average of the past hour
outmat(:,1) = (0.5:1:8760)*3600;        % time in s
outmat(:,2) = tvalue(outmat(:,1));      % tstring

% solar postion from carlib since epw have no sun information
[~,~,zenith,azimuth,~] = sunangles(outmat(:,1),lat,long,long0);

% N6, \field Dry Bulb Temperature                     \units C    \minimum> -70   \maximum< 70        \missing 99.9
% N7, \field Dew Point Temperature                    \units C    \minimum> -70   \maximum< 70        \missing 99.9
% N8, \field Relative Humidity                        \minimum 0      \maximum 110        \missing 999.
% N9, \field Atmospheric Station Pressure \units Pa   \minimum> 31000 \maximum< 120000    \missing 999999.
% N10, \field Extraterrestrial Horizontal Radiation   \units Wh/m2    \missing 9999.  \minimum 0          
% N11, \field Extraterrestrial DirectNormalRadiation  \units Wh/m2    \missing 9999.  \minimum 0
% N12, \field Horizontal Infrared Radiation Intensity \units Wh/m2    \missing 9999.  \minimum 0
% N13, \field Global Horizontal Radiation             \units Wh/m2    \missing 9999.  \minimum 0
% N14, \field Direct Normal Radiation                 \units Wh/m2    \missing 9999.  \minimum 0
% N15, \field Diffuse Horizontal Radiation            \units Wh/m2    \missing 9999.  \minimum 0
% N16, \field Global Horizontal Illuminance           \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N17, \field Direct Normal Illuminance               \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N18, \field Diffuse Horizontal Illuminance          \units lux      \missing 999999. \note will be missing if >= 999900 \minimum 0
% N19, \field Zenith Luminance                        \units Cd/m2    \missing 9999.   \note will be missing if >= 9999   \minimum 0
% N20, \field Wind Direction                          \units degrees  \missing 999.   \minimum 0  \maximum 360
% N21, \field Wind Speed                              \units m/s      \missing 999.   \minimum 0  \maximum 40
% N22, \field Total Sky Cover                         \missing 99     \minimum 0      \maximum 10
% N23, \field Opaque Sky Cover (used if Horizontal IR Intensity missing) \missing 99 \minimum 0 \maximum 10
% N24, \field Visibility                              \units km       \missing 9999 
% N25, \field Ceiling Height                          \units m        \missing 99999
% N26, \field Present Weather Observation     
% N27, \field Present Weather Codes
% N28, \field Precipitable Water                      \units mm       \missing 999
% N29, \field Aerosol Optical Depth                   \units thousandths \missing .999
% N30, \field Snow Depth                              \units cm       \missing 999
% N31, \field Days Since Last Snowfall                \missing 99
% N32, \field Albedo                                  \missing 999
% N33, \field Liquid Precipitation Depth              \units mm       \missing 999
% N34; \field Liquid Precipitation Quantity           \units hr       \missing 99      

outmat(:,3) = zenith;                   % zenith from carlib calculation
outmat(:,4) = azimuth;                  % azimuth from carlib calculation
outmat(:,5) = inmat(:,14);              % I_dir_norm = N14
outmat(:,6) = inmat(:,15); 				% I_dfu_hor = N15
outmat(:,7) = inmat(:,6);				% Tamb = N6
outmat(:,8) = skytemperature(outmat(:,7),inmat(:,8),inmat(:,22)/10); % skytemperature(Tamb,hum,cloud)
outmat(:,9) = inmat(:,8);				% relative humiditiy = N8
outmat(:,10) = inmat(:,33)*1000/3600;  	% precipitation = N33
outmat(:,11) = min(1, inmat(:,22)/10);	% cloud index = N22 
outmat(:,12) = inmat(:,9);              % pressure = N9
outmat(:,13) = inmat(:,21);			    % wind speed = N21
outmat(:,14) = inmat(:,20);			    % wind direction = N20
outmat(:,15) = zenith;					% collector incidence is zenith angle
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = inmat(:,13)-inmat(:,15); % Idir on horizontal surface 
outmat(:,19) = inmat(:,15);             % Idfu on surface

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
disp('epw2wdb : Please check sun position and solar radiation in the figure.')
disp('          Solar height and radiation should be 0 an the same moment at sunrise and sunset.')
disp('          If not check longitude, latitude and time reference.')
disp(' ')

% copy first and last row to assure interpolation 
outmat = [outmat(1,:); outmat(:,:); outmat(end,:)];
outmat(1,1) = 0;                        % first row has time 0
outmat(length(outmat),1) = 8760*3600;   % last row is end of the year

outmat = outmat';
fout = fopen(outfile,'w');
fprintf(fout,'%% Format of weather data in CARNOT.\n');
fprintf(fout,'%%   station name:  %s   country: %s\n', locName);
fprintf(fout,'%%   geographical positon: longitude: %f , latitude: %f\n', lat, long);
fprintf(fout,'%%   reference meridian for time (example: 0° = Greenwich Mean Time): %f\n', long0);
fprintf(fout,'%% Data converted from epw file. %s \n', infile);
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
% 7.1.0     hf      created from try2wdb                        02aug2020
% ***********************************************************************
