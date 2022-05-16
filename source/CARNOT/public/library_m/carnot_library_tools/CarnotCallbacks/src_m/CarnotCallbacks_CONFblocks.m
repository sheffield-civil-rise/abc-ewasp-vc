%% CarnotCallbacks_CONFblocks handles the parameters of _CONF blocks
%% Function Call
%  varargout = CarnotCallbacks_CONFblocks(varargin)
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%  bhandle - block handle (result of matlab function gcbh)
%  blockpath - path to the parameter files (*.mat) of the block relative to
%              the result of path_carnot('libsl')
%              example: fullfile('Source','Solar_Thermal', 'Collector_EN12975_CONF','parameter_set')
%% Outputs
%  ok - true, if loading and setting of params was successfull
%  paramStruct - strucutre with the parameter set
% 
%% Description
%  Search for the parameter set in the public and internal folders 
%  Blockname\parameter_set and load the parameter set.
%  When using this file as a template: The two parameters before
%  'userPath' are interpreted as pathname and filename. All parameters 
%  after 'userParam' are interpeted as part of the parameter set. 
%  See Collector_Unglazed_CONF block in Carnot for the settings of the mask.
%  Get their names and values with:
%         mnames = get_param(bhandle,'MaskNames');
%         mvalues = get_param(bhandle,'MaskValues');
%         idx = find(strcmp(mnames,'userParam'))+1;
%         for i = idx:length(mnames)
%             s = [variableName '.' mnames{i} ' = ' mvalues{i} ';'];
%             eval(s)
%         end
% 
%% References and Literature
%  Function is used by: Mask of CONF blocks in Carnot
%  see also CarnotCallbacks_CollectorUnglazedConf, CarnotCallbacks_SimpleHouseISOgmConf, 
%           BlockIsInCarnotLibrary

function varargout = CarnotCallbacks_CONFblocks(varargin)
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
    error(['CarnotCallbacks_CONFblocks: First argument must be a valid ' ...
        'function name. Second argument must be the blockhandle.'])
end
end % function CarnotCallbacks_CONFblocks


function [ok, param] = UserEdit(bhandle)
%% function UserMaskEnable enables editing of parameters, filename and pathname
userparam = get_param(bhandle, 'UserParam');
userpath = get_param(bhandle, 'UserPath');
me = get_param(bhandle, 'MaskEnables');

% find the index to the parameter named 'userPath'
idx = find(strcmp(get_param(bhandle,'MaskNames'),'userPath')); 
% the two parameters before 'userPath' are the pathname and filename
for i = idx-2:idx-1
    me{i} = userpath;
end
% find the index to the parameter named 'userParam'
idx = find(strcmp(get_param(bhandle,'MaskNames'),'userParam')); 
% all parameters after "userParam" are part of the parameter set
for i = idx+1:length(me)
    me{i} = userparam;
end
set_param(bhandle, 'MaskEnables', me);

% change filename if user wants to edit the parameters
if strcmp(userparam, 'on')
    set_param(bhandle, 'FileName', mat2str('<user defined>'));
    param = 1;
else
    param = 0;
end
ok = true;
end


function [ok, file] = SaveFilename(bhandle,folder,variableName,blockpath) %#ok<DEFNU>
%% function SaveFilename opens a user interface to save a parameter set
userparam = get_param(bhandle, 'UserParam');
file = '';          % default file name is an empty string

% set relative path in carnot to the block
if strcmp(userparam, 'on')
    switch folder
        case 'selected'
            path = eval(get_param(bhandle, 'PathName'));
        case 'internal'
            path = fullfile(path_carnot('intlibsl'),blockpath);
        otherwise
            path = eval(get_param(bhandle, 'PathName'));
    end
    
    % check if path exists
    if ~exist(path, 'dir')
        ok = false;
        % Construct a questdlg with two options
        choice = questdlg('Directory does not exist! Create it?', ...
            'Not existing directory', ...
            'Yes','No','No');
        if strcmp(choice,'Yes')
            % create a new directory
            [success,~,~] = mkdir(path);
            if success > 0
                ok = true;
            end
        end
    else
        ok = true;
    end
    if ~ok
        return
    end
    
    % change to new path
    oldpath = pwd;  % keep current (original) path
    cd(path)        % change directory to working path

    % choose a filename which is not yet used
    file = [variableName, '_set1.mat'];
    n = 1;
    while exist(file,'file')
        n = n+1;
        file = [variableName, '_set' num2str(n) '.mat'];
    end
    
    [file,path,ok] = uiputfile('*.mat', 'Save parameter set as', file);
    if ok
        set_param(bhandle, 'FileName', mat2str(file));
        set_param(bhandle, 'PathName', mat2str(path));
        
        % pack the parameters in a struct
        mnames = get_param(bhandle,'MaskNames');
        mvalues = get_param(bhandle,'MaskValues');
        % all parameters after "userParam" are part of the parameter set
        idx = find(strcmp(mnames,'userParam'))+1;
        for i = idx:length(mnames)
            if isnan(str2double(mvalues{i}))
                eval([variableName '.' mnames{i} ' = ''' mvalues{i} ''';'])
            else
                eval([variableName '.' mnames{i} ' = ' mvalues{i} ';'])
            end
        end
        % save parameter struct in the file
        eval(['save(file, ' mat2str(variableName) ')'])
        
        % turn off user editing
        set_param(bhandle, 'UserParam', 'off');
        UserEdit(bhandle);
    end
    cd(oldpath)     % back to the original path
else
    ok = false;
    warndlg('User parameters is not active. Only user edited parameters can be saved.')
end
end


function [ok, file] = GetFilename(bhandle,folder,blockpath)
%% function GetFilename opens a user interface to choose a filename
% set relative path in carnot to the block
userparam = get_param(bhandle, 'UserParam');
file = '';          % default file name is an empty string

if strcmp(userparam, 'on')
    % Construct a questdlg with two options
    choice = questdlg('"User defined parameters" is active! Overwrite parameter values?', ...
        'Choice of parameters', ...
        'Yes','No','No');
    if ~strcmp(choice,'Yes')
        ok = false;
        return
    end
    set_param(bhandle, 'UserParam', 'off');
    UserEdit(bhandle);
end

switch folder
    case 'selected'
        pathname = eval(get_param(bhandle, 'PathName'));
    case 'public'
        pathname = fullfile(path_carnot('libsl'),blockpath);
    case 'internal'
        pathname = fullfile(path_carnot('intlibsl'),blockpath);
    otherwise
        pathname = eval(get_param(bhandle, 'PathName'));
end

% check if path exists
if ~exist(pathname, 'dir')
    ok = false;
    warndlg('Path does not exist!');
    return
end

filename = erase(get_param(bhandle, 'FileName'),'''');
oldpath = pwd;
cd(pathname)
[filename,pathname,ok] = ...
    uigetfile({'*.mat';'*.dat';'*.txt';'*.csv';'*.*'}, ...
    'Pick a data file',filename);
cd(oldpath)
if ok
    set_param(bhandle, 'FileName', mat2str(filename));
    set_param(bhandle, 'PathName', mat2str(pathname));
    [~,~] = SetParameters(bhandle, pathname, filename);
    file = fullfile(pathname,filename);
end
end


function [ok, paramStruct] = SetParameters(bhandle, pathname, filename, blockpath)
%% load parameterfile and set parameters to the block in bhandle
ok = false;
paramStruct = [];
if ~BlockIsInCarnotLibrary
    file = fullfile(pathname, filename);
    s = get(bhandle);
    if strcmp(filename, '<user defined>')
        disp(['Block ' s.Path, '/', s.Name, ': user defined parameters, no parameter set loaded.'])
        return
    elseif exist(file,'file')
        paramStruct = importdata(file);
        disp([s.Path, '/', s.Name, ': loading parameter set ''', file, ''''])
        ok = true;
    else
        choice = questdlg({['Block ' s.Path, '/',s.Name]; ...
            ['Parameter set: ', file]; 'not found.'}, 'File not found', ...
            'Use previous values','Load from Carnot public data', ...
            'Load from Carnot internal data','Use previous values');
        % Handle response
        switch choice
            case 'Use previous values'
                return
            case 'Load from Carnot internal data'
                [ok, file] = GetFilename(bhandle,'internal',blockpath);
            case 'Load from Carnot public data'
                [ok, file] = GetFilename(bhandle,'public',blockpath);
        end
        paramStruct = importdata(file);
        disp([s.Path, '/', s.Name, ': loading parameter set ''', file, ''''])
    end
    paraNames = fieldnames(paramStruct);    % get parameter names
    
    % Get block properties
    maskNames = get_param(bhandle, 'MaskNames');
    
    for k = 1:length(maskNames)
        for l = 1:length(paraNames)
            if strcmp(maskNames{k},paraNames{l})
                if ischar(paramStruct.(paraNames{l})) % parameter is already char
                    set_param(bhandle, maskNames{k}, ...
                        paramStruct.(paraNames{l}));
                else
                    set_param(bhandle, maskNames{k}, ...
                        mat2str(paramStruct.(paraNames{l})));
                end
            end
        end
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
% *************************************************************************
% $Revision: 2 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_StorageConf.m $
%  ************************************************************************
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     27dec2017
%  6.1.1    hf      choicedlg in SetParameters when file        11jan2018
%                   or path is wrong
%  6.1.2    hf      set file to emtpy string in SaveFilename    18feb2018
% *************************************************************************
