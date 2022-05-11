function weather_data = read_weather(filename, date)
% date is the number of seconds since the 1rst Jnuary

fid = fopen(filename);

weather_data = textscan(fid, '%f %f %f %f %f %f %*[^\n]');
weather_data = cell2mat(weather_data);

fclose(fid);

[aaa,bbb,zenith,azimuth,ccc] = sunangles(weather_data(:,1)+date,51.13,-9.28,1);
weather_data = [weather_data zenith azimuth];
