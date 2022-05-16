% function ChangeCopyrightNotice.m
% Use this function to update the copyright notice to the current year
% in .c, .h, .m and .txt files.
% The algorithm will change recursively all files in all subdirectories.
% input: directoy where to start


% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
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
% $Author: carnot-wohlfeil $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/version_manager/ChangeCopyrightNotice.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                       Date
% 6.2.0     aw      created                                       11jan2015

function ChangeCopyrightNotice(directory)
    StartDirectory = pwd; %save current directory
    cd(directory); %change to the given directoy
    
    DirContent = dir; %get files
    
    for Count=1:numel(DirContent) %for all files
        if DirContent(Count).isdir && (~strcmpi(DirContent(Count).name, '.')) && (~strcmpi(DirContent(Count).name, '..')) %change to the next directory
            ChangeCopyrightNotice(DirContent(Count).name);
        elseif ~DirContent(Count).isdir
            if strcmpi(DirContent(Count).name(end-3:end),'.txt') || strcmpi(DirContent(Count).name(end-1:end),'.m') || strcmpi(DirContent(Count).name(end-1:end),'.c') || strcmpi(DirContent(Count).name(end-1:end),'.h')
                fid = fopen(DirContent(Count).name, 'rt'); %read file
                FileContent = fread(fid,'uint8=>char');
                FileContent = FileContent';
                fclose(fid);
                Position=strfind(FileContent, 'Copyright (c) 1998-'); %get the positions of the copyright string
                if strcmpi(DirContent(Count).name, [mfilename, '.m']) && numel(Position) > 0 %do not change this file expect the first occurence of the copyright string
                    Position = Position(1);
                end
                FileContentNew = FileContent;
                for CountPosition = 1:numel(Position) %change all copyright notices
                    AuxString = FileContentNew(Position(1):Position(1)+length('Copyright (c) 1998-')+3);
                    FileContentNew = strrep(FileContentNew, AuxString, 'Copyright (c) 1998-2018');
                    fprintf('Changing file %s at position %i: %s -> %s\n', DirContent(Count).name, Position(CountPosition), AuxString, FileContentNew(Position(1):Position(1)+length('Copyright (c) 1998-')+3));
                end
                if numel(FileContent)~=numel(FileContentNew) %write new file if the content has been changed (file got bigger)
                    fid = fopen(DirContent(Count).name, 'wt');
                    fwrite(fid, FileContentNew);
                    fclose(fid);
                elseif sum(FileContent~=FileContentNew)>0
                    fid = fopen(DirContent(Count).name, 'wt'); %write new file if the content has been changed (file did not get bigger)
                    fwrite(fid, FileContentNew);
                    fclose(fid);
                else
                    %do nothing
                    %no changes in the file
                end
            end
        else
            %do nothing
            %file name is '.' or '..'
        end
    end
    
    cd(StartDirectory); %go back to starting directory
end
