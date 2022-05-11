function [Data] = extendData(Data)
% Inputs:       Data - matrix with input Data without extension
% Outputs:      Data - matrix with extended Data if necessary
% Description:  extend data to the data of the simulation time if necessary
% 

% SYNTAX: [Data] = extendData(Data)
%
% Data is the name of the Data in *.mat format which needs to be extended. 
% The Data needs to have a constant timestep and the timestamp in the 1,
% column.
% 
% During the code first the stop time is catched from the simulink model
% Afterwards the timestep, the length of the data and the necesaary length
% for the simulation time is calculated.
% Afterwards it is checked if an extension is needed otherwise its
% returning the input. 
% else the data is extended in 2 ways 1 for a simulation end smaller then
% the double of the Data size and otherwise.

% ***********************************************************************
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
% $Author: blanke $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/library_m/weather_and_sun/convert_weather/src_m/convert_weather.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  tob -> Tobias Blanke
%               pk  -> Patrick Kefer               
% 
% version   author   changes                                     date
% 7.0.1     tob      created                                     06mar2020
% 7.0.2     tob      negative start time possible as simulation  31mar2020
%                    time and file input 
% 7.0.3     pk       strip lower level block paths from          14aug2020
%                    current_system string (no Stop/StartTime)   

% The current_system is the current simulation block.
current_system = get_param(0, 'CurrentSystem');
current_system = regexprep(current_system,'/.*','');
% get the stop time as string
stop_time_as_str = get_param(current_system, 'StopTime');
% get the start time as string
start_time_as_str = get_param(current_system, 'StartTime');
% cast stop_time_as_str to double
stop_time = str2double(stop_time_as_str);
% cast start_time_as_str to double
start_time = str2double(start_time_as_str);
% catch the error of to be caclulated end times like (365*24*3600 for a
% year instead of 31.536.000‬ sec)
if isnan(stop_time)
    % calc stop time from string
    stop_time = eval(stop_time_as_str);
end
% catch the error of to be caclulated start times like (-365*24*3600 for a
% year instead of -31.536.000‬ sec)
if isnan(start_time)
    % calc stop time from string
    start_time = eval(start_time_as_str);
end
if start_time <Data(1,1)  || stop_time > Data(end,1)
    % get length of the data matrix 
    lenData = length(Data(1:end,1));
    % get number of variables in data matrix
    numVariables = length(Data(1,1:end));
    % calc timestep from 1. column
    timeStep = Data(2,1)-Data(1,1);
    % calc number of pre start timesteps if necessary
    if start_time <Data(1,1) 
        % calc number of pre Start timesteps
        nStart = uint64(abs(start_time)/timeStep+0.5)- uint64(abs(Data(1,1))/timeStep+0.5);
    else
        % set number of pre Start timesteps to 0 because no pre time is
        % used
        nStart = uint64(0);
    end
    % calc number of timesteps in new Data file
    if stop_time > Data(end,1)
        % calc number of after Data timesteps
        nEnd = uint64(stop_time/timeStep+0.5);
    else
        % just the length of Data
        nEnd = uint64(lenData);
    end
    % calc neccessary number of timesteps for used time horizon
    nTimesteps = nStart+nEnd;
    % create new Data matrix with extended size
    newData = zeros(nTimesteps,numVariables);
    % check if a negative start time is used
    if start_time <Data(1,1)
        if -start_time <= Data(end,1)
            % extend necessary data
            newData(1:nStart,:) = Data((lenData-nStart+1):lenData,:);
        else
            % calc number of complete repetation circles
            n = uint64(fix((double(nStart)-1)/lenData));
            % set ending timestep
            start = nStart-(lenData)*n+1;
            % duplicate complete repetation circles
            newData(start:nStart,:) = repmat(Data,n,1);
            % check if there are missing timesteps and if then fill them
            if start>1
                % write missing timesteps
                newData(1:start-1,:) = Data(lenData-start+2:lenData,:);
            end
        end
        % Write new time stamp in new Data matrix until start time of Data
        % file
        newData(1:nStart,1) = (Data(1,1)+sign(start_time)*double(nStart)*timeStep:timeStep:Data(1,1)-timeStep)';
    end
    % write the 1. Data time horizon in the new matrix
    newData(1+nStart:lenData+nStart,:) = Data;
    % Check if an extenstion is necessary
    if stop_time>Data(end,1)
        % check if and extension for more then the double of the Data matrix is
        % needed
        if nEnd-lenData>lenData
            % calc number of complete repetation circles
            n = uint64(fix((double(nEnd)-lenData)/lenData));
            % set start timestep
            ending = nStart + lenData*(n+1);
            % duplicate complete repetation circles
            newData(lenData+1+nStart:ending,:) = repmat(Data,n,1);
            % check if timesteps are missing and if write them 
            if ending<nTimesteps
                % write missing timesteps
                newData(ending:nTimesteps,:) = newData(ending-lenData:nTimesteps-lenData,:);
            end
        else
            % extend necessary data
            newData(lenData+1+nStart:nTimesteps,:) = Data(1:nTimesteps-lenData-nStart,:);
        end
        % Write new time stamp in new Data matrix from start time in Data file until stop time
        newData(1+nStart:nTimesteps,1) = (Data(1,1):timeStep:double(nEnd-1)*timeStep+Data(1,1))';
    end
    % overwrite old Data for the return
    Data = newData;
end
end

