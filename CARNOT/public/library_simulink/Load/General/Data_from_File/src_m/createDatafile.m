%% createDatafile creates a datafile for Carnot block Data_from_File
%% Function Call
%  data = createDatafile(outputfilename, datasets)
%% Inputs   
%  outputfilename - optional parameter: string with the name of the output file 
%                   (the extension .mat is added automatically)
%  datasets       - optional parameter: filenames or variables with the dataset(s)
%% Outputs
%  data  -  data matrix 
%           col 1   : time in s
%           col 2   : first dataset
%           col N+1 : dataset N
% 
%% Description
%  The function creates a matrix with the format of the data output. The
%  data is also saved to a file in the .mat format. 
%  The dataset can be :
%  - a file with the data in a vector
%  - a variable (vector)
%  - entered by the user by setting start and end values (usefull for the
%    time vector)
%  There are several ways to use createDatafile:
% 
%  1) Call the function without parameters: 
%     Output data filename and all datasets are entered by 
%     input dialog windows.
%  Example: createDatafile
% 
%  2) Call the function with the output data filename:
%     All datasets are entered by input dialog windows.
%  Example: createDatafile('mydataFile')
% 
%  3) Call the function with the output data filename and one or several
%     dataset filenames. The function reads all files and creates the
%     output without further user interference.
%  Example: createDatafile('mydataFile', 'Dataset1.mat', 'Dataset2.csv', DataVector)
%
%% References and Literature
%  Function is used by: 
%  see also --

function varargout = createDatafile(varargin)
%% set variables from inputs
% get filename for the data file
if nargin == 0
    prompt = {'Pathname:','Filename:'};
    dlg_title = 'Filename';
    num_lines = 1;
    % choose a filename which is not yet used
    fname = 'MyData';
    ps = 'path_carnot(''intdata'')';
    pname = eval(ps);
    n = 1;
    while exist(fullfile(pname,[fname '.mat']),'file')
        n = n+1;
        fname = ['MyData_' num2str(n)];
    end
    defaultans = {pname,fname};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,'on');
    if isempty(answer)
        return
    end
    pname = answer{1};

    outputfilename = fullfile(pname,[answer{2} '.mat']);
else
    outputfilename = varargin{1};
end

% Check filename and pathname
[pname,fname,~] = fileparts(outputfilename);
if ~isempty(pname) && ~exist(pname, 'dir') % check if directory exists (if not, creae new one)
    ok = false;
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

if exist(outputfilename, 'file')   % if filename exists and shall be kept: stop execution
    choice = questdlg('File exists. Overwrite?', ...
        'File exists !!', 'Yes','No','No');
    if strcmp(choice,'No')
        return
    end
end

% get data vector information
ncol = max(2,nargin);      % input must have at least time and one data vector
if nargin <= 1
    prompt = {'Number of columns:'};
    dlg_title = 'Set number of data columns in the matrix';
    num_lines = 1;
    defaultans = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,'on');
    if isempty(answer)
        return
    end
    ncol = eval(answer{1})+1;  % add one time column
end

% set time and data columns of the matrix
ok_data = false(1,ncol);    
for n = 1:ncol
    if n < nargin
        if ischar(varargin{n})
            if exist(varargin{n+1},'var')
                data(:,n) = varargin{n+1}; %#ok<AGROW>
                ok_data(n) = true;
            elseif exist(varargin{n+1},'file')
                data(:,n) = load(varargin{n+1}); %#ok<AGROW>
                ok_data(n) = true;
            else
                warndlg(['Parameter ' num2str(n) ' has no correct data. ' ...
                    'Set values in the following input dialog.'],'Warning');
            end
        end
    end
    
    if ~ok_data(n)

        if n < ncol
            choice = questdlg('Choice of the data:', ...
                'No data specified.', 'File','Variable','Input Dialog','Input Dialog');
        else
            choice = questdlg('Choice of the time vector:', ...
                'Time vector not specified.', 'File','Variable','Input Dialog','Input Dialog');
        end

        switch choice
            case 'File'
                [fname,pname,ok] = ...
                    uigetfile({'*.mat';'*.dat';'*.txt';'*.csv';'*.*'}, ...
                    'Pick a data file',fname);
                if ~ok
                    return
                end
                filename = fullfile(pname,fname);
                data(:,n) = load(filename); %#ok<AGROW>

                choice = questdlg('Apply a correction factor?', ...
                    'Correction of data', 'No');
                if choice == 'Yes'
                    answer = inputdlg('multiply data with ','Correction',1,{'1'},'on');
                    x = eval(answer{1});
                    data(:,n) = data(:,n).*x; %#ok<AGROW>
                end
                
            case 'Variable'
                answer = inputdlg('Variable name','Variable',1,myData,'on');
                if isempty(answer) || ~exist(answer{1},'var')
                    return
                end
            
            case 'Input Dialog'
                if n == ncol        % time is the last column
                    prompt = {'Set start time in s:','Set end time in s:', 'Set timestep in s'};
                    dlg_title = 'Time vector';
                    num_lines = 1;
                    defaultans = {'0','365*24*3600','60'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,'on');
                    if isempty(answer)
                        return
                    end
                    time = (eval(answer{1}):eval(answer{3}):eval(answer{2}))';
                    if length(time) == size(data,1)+1
                        choice = questdlg('Method of extrapolation for the data:', ...
                            'Time vector is longer than data', ...
                            'Duplicate first data row', ...
                            'Duplicate last data row', ...
                            'Data is average in timestep', ...
                            'Duplicate first data row');
                        switch choice
                            case 'Duplicate first data row'
                                data = [data(1,:); data]; %#ok<AGROW>
                            case 'Duplicate last data row'
                                data = [data; data(end,:)]; %#ok<AGROW>
                            %case 'First data row is zero'   % comment out, only 3 choices possible :-/
                            %    data = [zeros(1,size(data,2)); data]; %#ok<AGROW>
                            case 'Data is average in timestep'
                                data = [data(1,:); data; data(end,:)]; %#ok<AGROW>
                                dt = (time(2)-time(1))/2;
                                time = [time-dt; time(end)+dt];
                            otherwise
                                return
                        end
                    end
                    data(:,n) = time; %#ok<AGROW>
                else
                    prompt = {'First value:','Last value:'};
                    dlg_title = 'Set data vector';
                    num_lines = 1;
                    defaultans = {'0','0'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,'on');
                    if isempty(answer)
                        return
                    end
                    data(:,n) = linspace(eval(answer{1}),eval(answer{2}),length(data(:,1))); %#ok<AGROW>
                end
        end % switch
    end
end

%% save data and set output
[~,fname,~] = fileparts(outputfilename);
eval([fname ' = data;'])
eval([fname '(:,1) = data(:,end);'])            % time is last column in data
eval([fname '(:,2:end) = data(:,1:end-1);'])
save(outputfilename,fname)
if nargout > 0
    varargout{1} = data;
end
end % function


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
%  7.1.0    hf      created                                     27jan2019
% *************************************************************************
