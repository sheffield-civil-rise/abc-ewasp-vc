%% CreateMFileHelp publishes m-files to create html help files
%% Function Call
%  n = CreateMFileHelp(copy_files)
%% Inputs   
%   isInternal: BOOL, Flag to create help for internal library (default = 0)
%% Outputs
%   n(1)    :   number of helpfiles created from src/*.m files
% 
%% Description
%  Create html helpfiles from the Carnot m-files by using the publish 
%  function. 
%  M-files are taken from the src_m folders of each Carnot block or 
%  function. A content html file is created.
%  All helpfiles will be saved in the common public/tutorial/doc folder.
% 
%% References and Literature
%  Function is used by: --
%  see also publish, path_carnot


function ntot = CreateMFileHelp(isInternal)
% set pathes
if nargin < 1
   intLib = "";
   intLibText = "";
elseif nargin == 1 && isInternal
   intLib = "int";
   intLibText = "Internal";
else
    error('two many input parameters.')
end
old_wd = pwd;                       % keep current working directory
docpath = path_carnot(intLib + 'help');

% set publish options
options = struct('format','html', ...
        'outputDir', docpath, ...
        'imageFormat', 'bmp', ...
        'evalCode', false, ...
        'showCode', false ...
    );

%% create html helpfiles for m-Files
car_wd = path_carnot(intLib + 'm');          % get carnot m-files directory
cd(car_wd);
d2 = dir('**/*.m');
ntot = length(d2);                  % number of help files to create
% loop over all mfiles
for n = 1:ntot
    fn = d2(n).name;
    fprintf('Publishing %i of %i: %s \n', n, ntot, fn);
    mydoc = publish(fn,options);
    if strcmp(mydoc, [])
        error('CreateMFileHelp: Something went wrong while trying to publish ' + intLib + 'm-files')
    end
end

%% create overview of Carnot Block help
% change to docpath and open m-file to write, publishing will be done later
cd(docpath);
fid = fopen('CarnotBlocksOverview.m','w');
disp('Creating CARNOT ' + intLib + 'blocks overview')
car_wd = path_carnot(intLib + 'libsl');       % get carnot block directory
fprintf(fid, '%s \n', '%% Carnot ' + intLibText + ' Blocks');
writeHeadlinesAndFunctions(car_wd,fid,'doc',intLib)
cd(docpath);
fclose(fid);
publish('CarnotBlocksOverview',options);

%% create overview of Carnot m-files
% change to docpath and open m-file to write, publishing will be done later
cd(docpath);
fid = fopen('CarnotMFunOverview.m','w');
disp('Creating CARNOT ' + intLib + 'm-files help according to folder structure')
car_wd = path_carnot(intLib + 'libm');       % get carnot m-files library directory
fprintf(fid, '%s \n', '%% Carnot ' + intLibText + ' m-Functions Overview');
writeHeadlinesAndFunctions(car_wd,fid,'src_m',intLib)
cd(docpath);
fclose(fid);
publish('CarnotMFunOverview',options);

%% create overview of Carnot c-files
% change to docpath and open m-file to write, publishing will be done later
cd(docpath);
fid = fopen('CarnotCLibraryOverview.m','w');
disp('Creating CARNOT ' + intLib + 'C-files help according to folder structure')
car_wd = path_carnot(intLib + 'libc');       % get carnot C-files library directory
fprintf(fid, '%s \n', '%% Carnot ' + intLibText + ' C-Functions Overview');
writeHeadlinesAndFunctions(car_wd,fid,'src_m',intLib)
cd(docpath);
fclose(fid);
publish('CarnotCLibraryOverview',options);

%% create overview of Carnot m-functions for blocks
% change to docpath and open m-file to write, publishing will be done later
cd(docpath);
fid = fopen('CarnotMFunBlockOverview.m','w');
disp('Creating CARNOT ' + intLib + 'm-files for blocks help according to folder structure')
car_wd = path_carnot(intLib + 'libsl');       % get carnot Simulink library directory
fprintf(fid, '%s \n', '%% Carnot m-Functions for ' + intLibText + ' Blocks Overview');
writeHeadlinesAndFunctions(car_wd,fid,'src_m',intLib)
cd(docpath);
fclose(fid);
publish('CarnotMFunBlockOverview',options);

% build database for doc search
% builddocsearchdb(docpath) 
% finalize
cd(old_wd)                      % go back to old working directory
end


%% writeHeadlinesAndFunctions(car_wd,fid,sfolder)
%  car_wd is the main directory where the files should be found
%  fid is the file identifier for writing the file to be published
%  sfolder is the name of the subfolder where the files are located
function writeHeadlinesAndFunctions(car_wd,fid,sfolder,intLib)
cd(car_wd);
% get all files with the correct extension with the recursive search dir
if strcmp(sfolder,'doc')
    d2 = dir('**/*.html');
else
    d2 = dir('**/*.m');
end
ntot = length(d2);                      % number of files
fh_last = '';                           % last function headline
for n = 1:ntot
    fd = d2(n).folder;
    [~,fn,~] = fileparts(d2(n).name);   % remove extension
    
    if contains(fd,[filesep sfolder])   % only for m-files from the source folder
        fd = strrep(fd,car_wd,'');      % remove carnot root path
        % create individual strings of the folders
        % start with index 2 since index 1 is the first filesep
        idx = 1;
        dd = '';
        fdd = cell(1,1);
        for m = 2:length(fd)
            if strcmp(fd(m),filesep)
                fdd{idx} = dd;
                dd = '';
                idx = idx+1;
            else
                dd = [dd, fd(m)];       %#ok<AGROW>
                % last run of the loop is discarded since the result in dd is 'src_m'
            end
        end
        % create function headline from path information
        mtot = length(fdd);                     % number of strings
        fh = fdd{1};
        
        for m = 2:mtot-1
            fh = [fh, ' / ', fdd{m}];   %#ok<AGROW>
        end
        if ~strcmp(fh, fh_last)                 % if headline is not the same as the last one
            fprintf(fid, '%s %s\n', '%%', fh);  % print the new sub-headline
            fh_last = fh;
        end
        % fprintf(fid, '%s <matlab:doc(''%s'') %s>\n', '%', fn, fn);
%         fprintf(fid, '%s <matlab:web(fullfile(path_carnot(''help''),''%s.html''),''-helpbrowser'') %s>\n', '%', fn, fn);
        fprintf(fid, "%s <matlab:web(fullfile(path_carnot('" + intLib + "help'),'%s.html'),'-helpbrowser') %s>\n", '%', fn, fn);
        fprintf(fid, '%s \n', '%');
    end
end
end


%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2020, Solar-Institute Juelich of the FH Aachen.
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
%  VERSIONS
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     05aug2020
%  7.1.1    hf      adapted to new folder structure:            24aug2020
%                   all html helpfile are in tutorial/doc
%  ************************************************************************
%  $Revision: 372 $
%  $Author: carnot-wohlfeil $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/tutorial/templates/template_carnot_m_function.m $
 