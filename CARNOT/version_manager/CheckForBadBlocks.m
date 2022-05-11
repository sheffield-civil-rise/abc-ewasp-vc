%CheckForBadBlocks.m
%This file runs the upgrade advisor and saves the output in the file, that
%is given in the parameter "reportfile" as an html file.


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
% $Revision: 143 $
% $Author: carnot-wohlfeil $
% $Date: 2017-03-06 16:28:40 +0100 (Mo, 06 Mrz 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/version_manager/CheckUpradeAdvisor.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 7.0.0     aw      created                                     11jun2019


function CheckForBadBlocks(reportfile)
    
    StartDir = pwd;
    chdir('..');
    CarnotDir = pwd;
    %CarnotDir=strrep('C:\carnot-svn\branches\carnot_7_00_01\public\library_simulink\Basic', '\', '/');
    chdir(StartDir);
    
    
    CreateHeader([strrep(StartDir, '\', '/'), '/', reportfile]);
    
    CheckOneDirectory([strrep(StartDir, '\', '/'), '/', reportfile], CarnotDir);
    
    CreateFooter([strrep(StartDir, '\', '/'), '/', reportfile]);
end


function CheckOneDirectory(reportfile, directory)

    DirContent = dir(directory);
    FileSLX = dir([directory, '/*.slx']);
    FileMDL = dir([directory, '/*.mdl']);
    
    for Count = 1:numel(FileSLX)
        fprintf('Checking %s/%s\n', strrep(FileSLX(Count).folder, '\', '/'), FileSLX(Count).name);
        badlinklist = CheckOneFile([FileSLX(Count).folder, '/', FileSLX(Count).name]);
        bdclose('all');
        AddToReport(reportfile, badlinklist, [strrep(FileSLX(Count).folder, '\', '/'), '/', FileSLX(Count).name]);
    end
    
    for Count = 1:numel(FileMDL)
        fprintf('Checking %s/%s\n', strrep(FileMDL(Count).folder, '\', '/'), FileMDL(Count).name);
        badlinklist = CheckOneFile([FileMDL(Count).folder, '/', FileMDL(Count).name]);
        bdclose('all');
        AddToReport(reportfile, badlinklist, [strrep(FileMDL(Count).folder, '\', '/'), '/', FileMDL(Count).name]);
    end
    
    for Count = 1:numel(DirContent)
       if ~strcmp(DirContent(Count).name, '.')
           if ~strcmp(DirContent(Count).name, '..')
                if DirContent(Count).isdir
                    CheckOneDirectory(reportfile, [strrep(DirContent(Count).folder, '\', '/'), '/', DirContent(Count).name]);
                end
           end
       end
    end
    

end


function AddToReport(reportfile, badlinklist, name)
    fid = fopen(reportfile, 'at');
    fprintf(fid,['<h2>',name,'</h2>']);
    
    for count=1:numel(badlinklist)
       fprintf(fid, '%s\n', badlinklist{count});
    end
	
	if numel(badlinklist) == 0
		fprintf(fid, 'no issues found\n');
	else
		fprintf(fid, 'bad links found\n');
	end
    
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    
    fclose(fid);
end


function badlinklist=CheckOneFile(filename)
    badlinklist={};
    load_system(filename);
    list = find_system(bdroot, 'LookUnderMasks','on');
    for count = 2:numel(list)
        if strcmpi(get_param(list{count}, 'LinkStatus'), 'unresolved')
            badlinklist{numel(badlinklist)+1}=list{count};
        end
    end
    close_system(filename);
    bdclose('all');
end


function CreateHeader(reportfile)
    fid = fopen(reportfile, 'wt');
    fprintf(fid, '<html>\n');
    fprintf(fid, '<head>\n');
    fprintf(fid, '<meta http-equiv="Content-Type" content="text/html;charset=utf-8">\n');
    fprintf(fid, '</head>\n');
    fprintf(fid, '<body>\n');
    fclose(fid);
end

function CreateFooter(reportfile)
    fid = fopen(reportfile, 'at');
    fprintf(fid, '</html>\n');
    fprintf(fid, '</body>\n');
    fclose(fid);
end
