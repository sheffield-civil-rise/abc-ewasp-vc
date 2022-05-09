modelfile = 'create_verification_weather_file';
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Weather/Weather_from_Workspace/scripts/create_verification_weatherdata.m $
load_system(modelfile)
simOut = sim(modelfile);
close_system(modelfile)
verification_weather_file = [[0:24]'*3600, simout];
save verification_weather_file verification_weather_file