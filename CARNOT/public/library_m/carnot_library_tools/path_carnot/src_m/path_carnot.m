%% path_carnot - management and definition of paths for carnot
%   path_carnot()           lists the defined paths and their SHORTCUTs
%   path_carnot('setpaths') adds the paths needed for Carnot your MATLAB path
%   path_carnot(SHORTCUT)   returns the full path (on your machine)
%       SHORTCUT        : to path
%       'root'          : Carnot root (home of carnot.slx libary)
%       'pub'           : public folder
%       'int'           : internal folder
%       'src'           : public folder for c-files
%       'intsrc'        : internal folder for c-files
%       'bin'           : public binary (mex) files
%       'intbin'        : internal binary (mex) files
%       'm'             : public m-files
%       'intm'          : internal m-files
%       'data'          : public data files (.mat or .csv files), e.g. weather data files
%       'intdata'       : internal data files (.mat or .csv files), e.g. weather data files
%       'help'          : public help files (html files)
%       'inthelp'       : internal help files (html files)
%       'vm'            : version manager folder
%       'libc'          : public folder for C libraries
%       'intlibc'       : internal folder for C libraries
%       'libsl'         : public Carnot block library folder (Simulink models)
%       'intlibsl'      : internal Carnot block library folder (Simulink models)
%       'libm'          : public m-file library folder
%       'intlibm'       : internal m-file library folder
%       'carlibsrc'     : Carlib folder
%       'examples'      : public examples folder
%       'intexamples'   : internal examples folder

function p = path_carnot(ctrl)
%% start of the function
% find root path of carnot
if exist('carnot','file') == 4
    rootpath = fileparts(which('carnot'));
else % paths might not be added yet, so carnot.mdl won't be found
    fprintf('carnot.slx could not be found on the current Matlab path. Trying to identify the correct path.\n')
    ptemp = pwd;
    % assume we're in rootpath/public/srs_m
    cd([fileparts(mfilename('fullpath')) filesep '..' filesep '..']);
    if exist('carnot','file') ~= 4
        warning('carnot.slx (or .mdl) could not be found. Check consistency of your installation and subpaths or use init_carnot.m first.')
    end
    rootpath = pwd;
    cd(ptemp)
end

% define standardized carnot paths
carnotpaths = {...
    'root'          fullfile(rootpath);...
    'pub'           fullfile(rootpath,'public');...
    'int'           fullfile(rootpath,'internal');...
    'src'           fullfile(rootpath,'public','src');...
    'intsrc'        fullfile(rootpath,'internal','src');...
    'bin'           fullfile(rootpath,'public','bin');...
    'intbin'        fullfile(rootpath,'internal','bin');...
    'm'             fullfile(rootpath,'public','src_m');...
    'intm'          fullfile(rootpath,'internal','src_m');...
    'data'          fullfile(rootpath,'public','data');...
    'intdata'       fullfile(rootpath,'internal','data');...
    'help'          fullfile(rootpath,'public','tutorial','doc');...
    'inthelp'       fullfile(rootpath,'internal','tutorial','doc');...
    'vm'            fullfile(rootpath,'version_manager');...
    'libc'          fullfile(rootpath,'public','library_c');...
    'intlibc'       fullfile(rootpath,'internal','library_c');...
    'libsl'         fullfile(rootpath,'public','library_simulink');...
    'intlibsl'      fullfile(rootpath,'internal','library_simulink');...
    'libm'          fullfile(rootpath,'public','library_m');...
    'intlibm'       fullfile(rootpath,'internal','library_m');...
    'carlibsrc'     fullfile(rootpath,'public','library_c','carlib','src'); ...
    'examples'      fullfile(rootpath,'public','tutorial','examples');...
    'intexamples'   fullfile(rootpath,'internal','tutorial','examples');...
    };

% display paths and break if no argin specified
if nargin < 1
    disp(carnotpaths)
    error('Input argument missing. Specify path reference or ''setpaths''')
end

% set paths mode: adds carnot paths to matlab path
if strcmp(ctrl,'setpaths')
    % specify which paths should be added
    paths2add = { ...               %first to add is last in path
        'help','inthelp', ...       
        'src','intsrc', ...
        'm','intm', ...
        'data','intdata', ...
        'bin','intbin',...
        'root','int', ...
        };
    disp('Adding CARNOT paths...')
    for i = 1:length(paths2add)
        for j = 1:size(carnotpaths,1)
            if strcmp(carnotpaths(j,1),paths2add(i))
                addpath(cell2mat(carnotpaths(j,2)))
                disp(['  ... ' cell2mat(carnotpaths(j,2))])
                break
            end
        end
    end
elseif strcmp(ctrl,'rmpaths')
    % specify which paths should be added
    paths2remove = { ...               %first to add is last in path
        'help','inthelp', ...
        'src','intsrc', ...
        'm','intm', ...
        'data','intdata', ...
        'bin','intbin',...
        'root','int', ...
        };
    disp('Removing CARNOT paths...')
    for i = 1:length(paths2remove)
        for j = 1:size(carnotpaths,1)
            if strcmp(carnotpaths(j,1),paths2remove(i))
                rmpath(cell2mat(carnotpaths(j,2)))
                disp(['  ... ' cell2mat(carnotpaths(j,2))])
                break
            end
        end
    end
else % return demanded path as string
    for i = 1:size(carnotpaths,1)
        if strcmp(carnotpaths(i,1),ctrl)
            p = cell2mat(carnotpaths(i,2));
            break
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
%  **********************************************************************
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%                   pahm -> Marcel Paasche
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  5.1.0    hf      created                                     03feb2014
%  5.1.1    PahM    rework path management                      10oct2014
%  5.1.2    PahM    move to scripts; add documentation          12aug2014
%  6.1.0    hf      renamed to path_carnot                      16dec2014
%                   (old name path_carnot_6)
%  6.1.1    pahm    changed cd('..\..')                         02jun2015
%  7.1.0    hf      replaced warning('MATLAB:Path', by fprintf  02feb2020
%  7.1.1    hf      added 'examples' and 'intexamples'          04aug2020
%  7.1.2    hf      added 'libm' and 'intlibm'                  08aug2020
%  7.1.3    hf      removed 'mfiledoc'                          09aug2020
% **********************************************************************
% $Revision: 731 $
% $Author: carnot-hafner $
% $Date: 2020-08-13 23:50:35 +0200 (Do, 13 Aug 2020) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/src_m/path_carnot.m $
