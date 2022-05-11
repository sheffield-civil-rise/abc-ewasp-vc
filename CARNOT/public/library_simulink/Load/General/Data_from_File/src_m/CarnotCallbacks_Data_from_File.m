%% CarnotCallbacks_Data_from_File loads a variable from file and sets the name in a from workspace block
%% Function Call
%  varargout = CarnotCallbacks_Data_from_File(varargin)
%% Inputs
%  hdl - block handle (result of gcbh function)
%  function GetFilename: folder - indicates the folder where to search for the data file
%  function LoadData: pathname - path where the files are stored
%  function LoadData: filename - filename with extension
%% Outputs
%  ok - true if loading was successfull, false otherwise
%  function LoadData: data - variable with the data (col 1 is the time)
% 
%% Description
%  CarnotCallbacks_Data_from_File is a callback script to load files and 
%  write the filename in a From_Workspace Block.
%  The variable parampath can be used to hand over the path to files which
%  are not stored on the Matlab-path.
% 
%% References and Literature
%  function is used by: Data_from_File, Weather_from_File
 
function varargout = CarnotCallbacks_Data_from_File(varargin)
% Switch for command line calls
if nargin >= 1 && ischar(varargin{1})
    FunctionName = varargin{1};
    % Call the function
    if nargout > 0
        [varargout{1:nargout}] = feval(FunctionName, varargin{2:end});
    else
        feval(FunctionName, varargin{2:end});
    end
else
    error('CarnotCallbacks_Load_from_File: First argument must be a valid function name. Second argument must be the blockhandle.')
end
end
 
function ok = UserMaskEnable(bhandle)  %#ok<DEFNU>
%% function UserMaskEnable enables editing of filename and pathname
userparam = get_param(bhandle, 'UserParam');
switch userparam
    case 'off'
        me = {'off';'off';'on';'off';'off'};
        ok = true;
    case 'on'
        me = {'on';'on';'on';'off';'off'};
        ok = true;
    otherwise
        me = {'off';'off';'on';'off';'off'};
        ok = true;
end
set_param(bhandle, 'MaskEnables', me);
end
 
function ok = GetFilename(bhandle,folder)
%% function GetFilename opens a user interface to choose a filename
switch folder
    case 'selected'
        ps = get_param(bhandle, 'PathName');
    case 'public'
        ps = 'path_carnot(''data'')';
    case 'internal'
        ps = 'path_carnot(''intdata'')';
    otherwise
        ps = get_param(bhandle, 'PathName');
end
pname = eval(ps);
fname = erase(get_param(bhandle, 'FileName'),'''');
oldpath = pwd;
 
% path is 'current' : user selected current working directory only
if ~strcmp(pname,'current')     % not 'current' 
    cd(pname)                   % change to directory given by folder
end
[fname,pname2,ok] = ...
    uigetfile({'*.mat';'*.dat';'*.txt';'*.csv';'*.*'}, ...
    'Pick a data file',fname);
 
if ok
    set_param(bhandle, 'FileName', mat2str(fname));
    if ~strcmp(pname,'current')                 % not 'current' : user selected current working directory only
        if ~strcmpi(pname,pname2(1:end-1))      % if pathes are not the same
            ps = mat2str(pname2(1:end-1));   % new path is one from uigetfile
        end
        set_param(bhandle, 'PathName', ps);  % set new path in mask
    end
end
cd(oldpath)
end
 
 
function [ok,data,t_sample] = LoadData(bhandle,pathname,filename) %#ok<DEFNU>
%% function LoadData loads the data to a variable in the base workspace
ok = false;             % default value
data = [0 0; 3600 0];   % default data
t_sample = 60;          % default sample time
if ~BlockIsInCarnotLibrary          % not in carnot library any more
    [~,file,ext] = fileparts(filename);
    if strcmp(pathname,'current')   % 'current' : user selected current working directory only
        pathname = pwd;
    end
    fullname = fullfile(pathname,filename);
 
    if exist(fullname,'file')    % search on given path
        ok = true;
    else
        choice = questdlg({['Block ' pathname, '/',filename]; ...
            ['Datafile: ', file]; 'not found.'}, 'File not found', ...
            'Load from Carnot public data', 'Load from Carnot internal data', ...
            'Load from selected path', 'Load from Carnot public data');
        % Handle response
        switch choice
            case 'Load from selected path'
                ok = GetFilename(bhandle,'selected');
            case 'Load from Carnot internal data'
                ok = GetFilename(bhandle,'internal');
            case 'Load from Carnot public data'
                ok = GetFilename(bhandle,'public');
        end
        filename = eval(get_param(bhandle, 'FileName'));
        pathname = eval(get_param(bhandle, 'PathName'));
        [~,~,ext] = fileparts(filename);
        fullname = fullfile(pathname,filename);
    end
    
    if ok == true                 % if the file exists
        if strcmp(ext,'.mat')
            data = importdata(fullname);
        else
            data = load(fullname);
        end
        
        % sample time is timestep of data
        if isa(data,'double')                   % if variable is a real matrix
            t_sample = data(3,1) - data(2,1);
        else                                    % else: variable is a timeseries
            t_sample = data.Time(2) - data.Time(1);
        end
        % extend Data to full simulation time (from negative to postive ex-
        % tensions)
        [data] = extendData(data);
    else
        % assignin('base',file,[0 0; 3600 0]) % no data available: assign a flat line of zeros  
        t_sample = 3600;
    end
end
end
 
%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
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
%  $Revision: 1 $
%  $Author: goettsche $
%  $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_GetFiles.m $
%  **********************************************************************
%  VERSIONS
%  author list:      hf -> Bernd Hafner
%                    tob --> Tobias Blanke    
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created on base of CarnotCallbacks_GetFile  23dec2017
%  6.1.1    hf      added questdlg if file does not exist       04mar2018
%  7.1.0    hf      added 'current' option for path             27jan2019
%  7.1.1    hf      removed VariableName in block mask, data    03feb2019
%                   ia nOw assigned to variable DataName        
%                   t_sample is output parameter
%  7.1.2    tob     ExtendData is added to have data the intire 
%                   simulation time from negative to postive ex-
%                   tensions