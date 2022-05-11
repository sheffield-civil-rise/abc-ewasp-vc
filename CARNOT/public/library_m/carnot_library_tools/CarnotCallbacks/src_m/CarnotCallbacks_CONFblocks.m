%% CarnotCallbacks_CONFblocks handles the parameters of _CONF blocks
%% Function Call
%  varargout = CarnotCallbacks_CONFblocks(varargin)
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%          'SetParameterFile' - Set the parameter file to respective lower level CONF block from uppper mask
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
%  Blockname\parameter_set and load the parameter set. The pathname can be
%  set to 'current'. In this case the block searches the parameter set only
%  in the current directory.
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


%% function UserEdit enables editing of parameters, filename and pathname
function [ok, param] = UserEdit(bhandle,uPath,uPara,FileName)

%Check input arguments  
if nargin == 0
    error('Function UserEdit: Not enough input arguments');
elseif nargin <= 1  % CONF blocks function --> [ok, param] = UserEdit(bhandle)
    uPath = 'userPath';
    uPara = 'userParam';
    FileName = 'FileName';
end
  
userpara = get_param(bhandle, 'userParam');
userpath = get_param(bhandle, 'userPath');
me = get_param(bhandle, 'MaskEnables');

% find the index to the parameter named 'userPath'
idx = find(strcmp(get_param(bhandle,'MaskNames'),uPath)); 
% the two parameters before 'userPath' are the pathname and filename
for i = idx-2:idx-1
    me{i} = userpath;
end
% find the index to the parameter named 'userParam'
idx = find(strcmp(get_param(bhandle,'MaskNames'),uPara)); 
% all parameters after "userParam" are part of the parameter set
for i = idx+1:length(me)
    me{i} = userpara;
end
set_param(bhandle, 'MaskEnables', me);

% change filename if user wants to edit the parameters
if strcmp(userpara, 'on')
    set_param(bhandle, FileName, mat2str('<user defined>'));
    param = 1;
else
    param = 0;
end
ok = true;
end


%% function SaveFilename opens a user interface to save a parameter set
function [ok, file] = SaveFilename(bhandle,folder,variableName,blockpath,uPath,uPara,PathName,FileName) %#ok<DEFNU>

%Check input arguments  
if nargin == 0
    error('Function SaveFilename: Not enough input arguments');
elseif nargin <= 4   % default CONF blocks function --> [ok, file] = SaveFilename(bhandle,folder,variableName,blockpath)
    uPath = 'userPath';
    uPara = 'userParam';
    PathName = 'PathName';
    FileName = 'FileName';
end

userpara = get_param(bhandle, 'userParam');
file = '';          % default file name is an empty string

% set relative path in carnot to the block
if strcmp(userpara, 'on')
    pathname = get_param(bhandle, 'PathName');
    if strcmp(folder, 'internal')
        pathname = mat2str(fullfile(path_carnot('intlibsl'),blockpath));
    end
    pname = eval(pathname);
    
    % change path if required
    oldpath = pwd;      % keep current (original) path
    if ~strcmp(pname,'current') % 'current' : user wants to keep current working directory
        % check if path exists
        if ~exist(pname, 'dir')
            ok = false;
            % Construct a questdlg with two options
            choice = questdlg('Directory does not exist! Create it?', ...
                'Not existing directory', 'Yes','No','No');
            if strcmp(choice,'Yes')
                % create a new directory
                [success,~,~] = mkdir(pname);
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
        cd(pname)        % change directory to working path
    end
    
    % choose a filename which is not yet used
    file = [variableName, '_set1.mat'];
    n = 1;
    while exist(file,'file')
        n = n+1;
        file = [variableName, '_set' num2str(n) '.mat'];
    end
    
    [file,pname2,ok] = uiputfile('*.mat', 'Save parameter set as', file);
    if ok
        set_param(bhandle, FileName, mat2str(file));
        if strcmp(folder, 'internal')
            s1 = 'fullfile(path_carnot(''intlibsl''), ''';
            s2 = strsplit(blockpath, filesep);
            for m = 1:length(s2)-1
                s1 = [s1, s2{m}, ''', ''']; %#ok<AGROW>
            end
            s1 = [s1, s2{end}, ''')'];
        else
            s1 = mat2str(pname2);
        end
        if ~strcmp(pname,'current')   % 'current' : user wants to select current path only
            set_param(bhandle, PathName, s1);
        end
        
        % pack the parameters in a struct
        mnames = get_param(bhandle,'MaskNames');
        mvalues = get_param(bhandle,'MaskValues');
        
        % all parameters after "userParam" are part of the parameter set
        idx = find(strcmp(mnames,uPara))+1;
        
        for i = idx:length(mnames)
            try
            if isnan(str2double(mvalues{i}))
                eval([variableName '.' mnames{i} ' = ''' mvalues{i} ''';'])
            else
                eval([variableName '.' mnames{i} ' = ' mvalues{i} ';'])
            end
            catch
                eval([variableName '.' mnames{i} ' = {' mvalues{i} '};'])%KteA
            end
        end
        % save parameter struct in the file
        eval(['save(file, ' mat2str(variableName) ')'])
        
        % turn off user editing
        set_param(bhandle, uPara, 'off');
        UserEdit(bhandle,uPath,uPara,FileName);
    end
    cd(oldpath)     % back to the original path
else
    ok = false;
    warndlg('User parameters is not active. Only user edited parameters can be saved.')
end % if
end % function SaveFilename


%% function GetFilename opens a user interface to choose a filename
function [ok, file] = GetFilename(bhandle,folder,blockpath,uPath,uPara,PathName,FileName)

%Check input arguments  
if nargin == 0
    error('Function GetFilename: not enough input arguments');
elseif nargin <= 3   % default CONF blocks function --> [ok, file] = GetFilename(bhandle,folder,blockpath)
    uPath = 'userPath';
    uPara = 'userParam';
    PathName = 'PathName';
    FileName = 'FileName';
end

% set relative path in carnot to the block
userpara = get_param(bhandle, uPara);
file = '';          % default file name is an empty string

if strcmp(userpara, 'on')
    % Construct a questdlg with two options
    choice = questdlg('"User defined parameters" is active! Overwrite parameter values ?', ...
        'Choice of parameters', ...
        'Yes','No','No');
    if ~strcmp(choice,'Yes')
        ok = false;
        return
    end
    set_param(bhandle, uPara, 'off');
    UserEdit(bhandle,uPath,uPara,FileName);
end

switch folder
    case 'selected'
        pathname = get_param(bhandle, PathName);
    case 'public'
        pathname = 'fullfile(path_carnot(''libsl''), ''';
        s2 = strsplit(blockpath, filesep);
        for m = 1:length(s2)-1
            pathname = [pathname, s2{m}, ''', ''']; %#ok<AGROW>
        end
        pathname = [pathname, s2{end}, ''')'];
    case 'internal'
        pathname = 'fullfile(path_carnot(''intlibsl''), ''';
        s2 = strsplit(blockpath, filesep);
        for m = 1:length(s2)-1
            pathname = [pathname, s2{m}, ''', ''']; %#ok<AGROW>
        end
        pathname = [pathname, s2{end}, ''')'];
    otherwise
        pathname = get_param(bhandle, PathName);
end
pname = eval(pathname);
% change directory
oldpath = pwd;
if ~strcmp(pname,'current') % not 'current' : user selected current working directory only
    % check if path exists
    if ~exist(pname, 'dir')
        ok = false;
        warndlg('Path does not exist!');
        return
    end
    cd(pname)
end

filename = erase(get_param(bhandle, FileName),'''');
[filename,pname2,ok] = ...
    uigetfile({'*.mat';'*.dat';'*.txt';'*.csv';'*.*'}, ...
    'Pick a data file',filename);
cd(oldpath)
if ok
    set_param(bhandle, FileName, mat2str(filename));
   
    if ~strcmp(pname,'current')                     % not 'current' : user selected current working directory only
        if ~strcmpi(pname,pname2(1:end-1))          % if pathes are not the same
            pathname = mat2str(pname2(1:end-1));    % new path is one from uigetfile
        end
        set_param(bhandle, PathName, pathname);   % set new path in mask
    end
    [~,~] = SetParameters(bhandle, pname2, filename, blockpath);
  
    file = fullfile(pathname,filename);
end
end % function GetFilename


%% function SetParameters loads the parameterfile and set parameters to the block in bhandle
function [ok, paramStruct] = SetParameters(bhandle,pathname,filename,blockpath)

%Check input arguments  
if nargin == 0
    error('Function SetParameters: Not enough input arguments');
end

ok = false;
paramStruct = [];
if ~BlockIsInCarnotLibrary
    if strcmp(pathname,'current')
        file = filename;
    else
        file = fullfile(pathname, filename);
    end
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
                elseif iscell (paramStruct.(paraNames{l})) 
                    set_param(bhandle, maskNames{k}, ...
                        cell2mat(paramStruct.(paraNames{l})));
                else
                    set_param(bhandle, maskNames{k}, ...
                        mat2str(paramStruct.(paraNames{l})));     
                end
            end
        end 
    end
end
end
 % function SetParameters 

 
%% function SetParameterFile set the parameter file to the respective CONF blocks
function [ok,paramfile] = SetParameterFile(bhandle,FileName,CONFblock) %#ok<DEFNU> % set parameterfile to respective CONF blocks automatically

%Check input arguments  
if nargin == 0
    error('Function SetParameterFile: Not enough input arguments');
end  

sysIn = find_system(gcb);    % to get the root block path
CONFBlock = get_param(bhandle,CONFblock); % CONF model block name
CONFblock_path = cell2mat(strcat(sysIn,'/',CONFBlock)); % Combines the root block path with CONF model --> CONF block path

filename = get_param(bhandle,FileName);   

set_param (CONFblock_path,'FileName',mat2str(filename));       % set the parameter file to respective CONF block

ok = 1;
paramfile = 1;

end
 % function SetParameterFile
 
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
% *************************************************************************************************************************************************
% $Revision: 2 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_StorageConf.m $
%  ************************************************************************************************************************************************
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                                      Date
%  6.1.0    hf      created                                                 27dec2017
%  6.1.1    hf      choicedlg in SetParameters when file or path is wrong   11jan2018                
%  6.1.2    hf      set file to emtpy string in SaveFilename                18feb2018
%  6.1.3    hf      save on internal path: path is fullfile(...)            18dec2018
%  6.1.4    hf      load button doesn't overwrite 'fullfile()' path         20dec2018
%  6.1.5    hf      path 'current': current working directory only          30dec2018
%  6.1.6    PtiA    added new function (setParameterFile)                   23sep2020
%                   updated all other functions such that they work for the 
%                   existing and new CONF models (especially system models) 
%  6.1.7    hf      function SaveFilename: userPath instead of UserPath     27dec2020
%                                          userParam instead of UserParam
%  7.1.0    hf      all functions  : 'userPath' instead of 'UserPath'       10mar2021
%                                    'userParam' instead of 'UserParam'
% *************************************************************************************************************************************************
