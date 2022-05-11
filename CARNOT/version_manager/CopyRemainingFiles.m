%% copy files from the block and function folders to the common folders
%  Copy the files to the release directories, e.g. help files, m-files

function CopyRemainingFiles
%% Copy files
disp('Starting to copy the remaining files :')
old_dir = pwd;              % keep current directory

%% Examples, slx and sldd
%  public examples first
%  and internal examples second
disp('... copying examples')
CopyFileType(path_carnot('libsl'), 'examples', path_carnot('examples'), 'example_*.slx');
CopyFileType(path_carnot('libsl'), 'examples', path_carnot('examples'), 'example_*.sldd');
CopyFileType(path_carnot('intlibsl'), 'examples', path_carnot('intexamples'), 'example_*.slx');
CopyFileType(path_carnot('intlibsl'), 'examples', path_carnot('intexamples'), 'example_*.sldd');

%% html and htm help files for blocks and general help
%  first the public folder
%  and than the internal folder
disp('... copying html files')
CopyFileType(path_carnot('libsl'), 'doc', path_carnot('help'), '*.html');
CopyFileType(path_carnot('libm'), 'doc', path_carnot('help'), '*.html');
CopyFileType(path_carnot('libm'), 'doc', path_carnot('help'), '*.css');
CopyFileType(path_carnot('libm'), 'doc', path_carnot('help'), '*.xml');
CopyFileType(path_carnot('intlibsl'), 'doc', path_carnot('inthelp'), '*.html');
CopyFileType(path_carnot('intlibm'), 'doc', path_carnot('inthelp'), '*.html');
CopyFileType(path_carnot('intlibm'), 'doc', path_carnot('inthelp'), '*.css');
CopyFileType(path_carnot('intlibm'), 'doc', path_carnot('inthelp'), '*.xml');

%% Figures for help files 
%  first the public folder
%  and than the internal folder
disp('... copying figures')
CopyFileType(path_carnot('libsl'), 'Figures', fullfile(path_carnot('help'), 'Figures'), '*.*');
CopyFileType(path_carnot('intlibsl'), 'Figures', fullfile(path_carnot('inthelp'), 'Figures'), '*.*');

%% Formulas for help files 
%  first the public folder
%  and than the internal folder
disp('... copying formulas')
CopyFileType(path_carnot('libsl'), 'Formulas', fullfile(path_carnot('help'), 'Formulas'), '*.*');
CopyFileType(path_carnot('intlibsl'), 'Formulas', fullfile(path_carnot('inthelp'), 'Formulas'), '*.*');

%% pdf files 
%  first the public folder
%  and than the internal folder
disp('... copying pdf files')
CopyFileType(path_carnot('libsl'), 'pdf', fullfile(path_carnot('help'), 'pdf'), '*.pdf');
CopyFileType(path_carnot('intlibsl'), 'pdf', fullfile(path_carnot('inthelp'), 'pdf'), '*.pdf');

%% m-files of Carnot blocks
%  as everybody knows : "the truth is in the code" - the internal folder is first
%  and second is the code of the public folder (and also plenty of truth in it)
disp('... copying m-files of Carnot blocks')
CopyFileType(path_carnot('intlibsl'), 'src_m', path_carnot('intm'), '*.m');
CopyFileType(path_carnot('libsl'), 'src_m', path_carnot('m'), '*.m');

%% m-files of Carnot functions
%  its code so the internal folder is first
%  second is the public folder 
disp('... copying m-files of Carnot functions')
CopyFileType(path_carnot('intlibm'), 'src_m', path_carnot('intm'), '*.m');
CopyFileType(path_carnot('libm'), 'src_m', path_carnot('m'), '*.m');

%% .m files of Carnot C-functions
%  first the internal folder
%  and than the public folder
disp('... copying m-files of Carnot C-libraries')
CopyFileType(path_carnot('intlibc'), 'src_m', path_carnot('intm'), '*.m');
CopyFileType(path_carnot('libc'), 'src_m', path_carnot('m'), '*.m');

%% Finalize
disp('Copy Remaining Files terminated')
cd(old_dir);
end

%% CopyFileType(SearchDir, InDir, TargetDir, FileName)
%  SearchDir    : major directory where the files shall be searched
%  InDir        : subfolder in major directory where the files are placed
%  TargetDir    : target directory where the files are copied
%  FileName     : filename and extension
function CopyFileType(SearchDir, InDir, TargetDir, FileName)
olddir = pwd;
cd(SearchDir);
ff = dir(['**/',FileName]);
for n = 1:numel(ff)
    if (strcmp(ff(n).folder(end-length(InDir)+1:end),InDir) ...
            && ~strcmp(ff(n).name,'.') ...
            && ~strcmp(ff(n).name,'..'))
        copyfile(fullfile(ff(n).folder, ff(n).name),TargetDir);
    end
end
cd(olddir);
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
%  author list:     aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    aw      created                                     oct2015
%  7.1.0    hf      use path_carnot for folders                 12aug2020
%                   removed from copying:
%                       public/library_simulink/scripts 
%                   rearranged the comments
%                   MoveFileType commented out as at is not used
%  7.1.1    hf      modified CopyFileType: SearchFiles not      18aug2020
%                   used any more
%  7.1.2    hf      added comments                              24aug2020
%  ************************************************************************
% $Revision$
% $Author$
% $Date$
% $HeadURL$
