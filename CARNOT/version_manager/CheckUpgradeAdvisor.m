%CheckUpgradeAdvisor.m
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
% 6.1.0     aw      created                                     10apr2017


function CheckUpgradeAdvisor(reportfile)
    
    StartDir = pwd;
    chdir('..');
    CarnotDir = pwd;
    %CarnotDir=strrep('C:\carnot-svn\trunk\public\library_simulink\Basic\Hydraulics\THBCreator', '\', '/');
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
        thisreportfile = CheckOneFile([FileSLX(Count).folder, '/', FileSLX(Count).name]);
        bdclose('all');
        AddToReport(reportfile, thisreportfile, [strrep(FileSLX(Count).folder, '\', '/'), '/', FileSLX(Count).name]);
    end
    
    for Count = 1:numel(FileMDL)
        fprintf('Checking %s/%s\n', strrep(FileMDL(Count).folder, '\', '/'), FileMDL(Count).name);
        thisreportfile = CheckOneFile([FileMDL(Count).folder, '/', FileMDL(Count).name]);
        bdclose('all');
        AddToReport(reportfile, thisreportfile, [strrep(FileMDL(Count).folder, '\', '/'), '/', FileMDL(Count).name]);
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


function AddToReport(reportfile, thisreportfile, name)
    fid = fopen(reportfile, 'at');
    thisfid = fopen(thisreportfile, 'rt');
    
    
    while(numel(strfind(fgets(thisfid),'h3')) == 0)
    end
    
    fprintf(fid,['<h2>',name,'</h2>']);
    
    ThisLine = fgets(thisfid);
    while(numel(strfind(ThisLine,'</html>')) == 0)
        fprintf(fid, ThisLine);
        ThisLine = fgets(thisfid);
    end
    
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    fprintf(fid, '<br>\n');
    
    fclose(fid);
    fclose(thisfid);
end


function thisreportfile=CheckOneFile(filename)
    upgrader=upgradeadvisor(filename);
    upgrader.SkipBlocksets = false;
    upgrader.ShowReport = false;
    upgrader.SkipLibraries = true;
    analyze(upgrader);
    thisreportfile=upgrader.ReportFile;
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
