function CreateCarnotMDL(Mode)
% function CreatePublicMDL
% Use this function to assemble the atomic libraries in the public
% folder to carnot.slx.

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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      aw -> Arnold Wohlfeil
%                   pk -> Patrick Kefer
%                   hf -> Bernd Hafner
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     aw      created                                     oct2015
% 6.1.1     pk      any directory for internal lib possible     sep2016
% 6.1.2		aw		library version changed to 6.1.0            02mar2017
% 6.1.3     aw      update for R2016b                           01dec2017
% 6.2.1     aw      update for 6.2.1
% 7.0.1     pk      updated for 7.0                             05apr2019
% 7.0.2     pk      automatic Library Version numbering
%                   like with manual creation                   22jul2019
% 7.0.3     hf      modified call for help and examples         27nov2019
% 7.0.4		aw		corrected copy paste error for examples		16jan2020
% 7.0.5     pk      add creation of CarInt                      10feb2020
% 7.0.6     pk      carnot init no more necessary               28may2020

if nargin<1 || ~(strcmp(Mode,'pub')||strcmp(Mode,'all'))
    % set default mode to pub -> only create public library
    Mode = 'pub';
end
VersionManagerDirectory = pwd;
addpath(pwd);
cd('..');

close_system('carnot',0);

%%set up paths
CarnotDirectory = pwd;
LibDirectoryPublic = [CarnotDirectory,'\public\library_simulink'];
CarIntDirectory = fullfile(CarnotDirectory,'internal');
LibDirectoryInternal = [CarnotDirectory,'\internal\library_simulink'];

%%set up information
SimulinkVersion = ver('Matlab');
SimulinkVersion = regexprep(SimulinkVersion.Release,'\(|\)','');
Copyright='Copyright Solar-Institute Juelich';
CarnotVersion = '7.1';% default Version according to Toolbox Version
CarnotAnnotation = 'Carnot 7.1';

%%check if carnot already existis
if exist('carnot.mdl','file') || exist('carnot.slx','file')
    % set up information
    % Default Version number can be changed in input dialog if needed
    % --> use with care
    load_system([CarnotDirectory,'\carnot']);
    curCarnotVersion = get_param(gcs,'ModelVersion');    
    bdclose('carnot');
    VersSubIdx = regexp(curCarnotVersion,'\.');
%     CarnotVersion = [curCarnotVersion(1:VersSubIdx(end)),num2str(str2double(curCarnotVersion(VersSubIdx(end)+1:end))+1)]; 
    CurrentVersion = [curCarnotVersion(1:VersSubIdx(end)),num2str(str2double(curCarnotVersion(VersSubIdx(end)+1:end))+1)]; 
    carnotInfo = inputdlg({['Library Version - Default: ',CarnotVersion,' | Current: ',CurrentVersion,':']},'Version Information',[1,50],{CarnotVersion});
    CarnotVersion = carnotInfo{1};       
    CarnotAnnotation = ['Carnot ',CarnotVersion];   
    
    button = questdlg('Carnot already exists. ','Question','abort','delete','rename','abort');
    if strcmpi(button, 'delete')
        delete('carnot.slx')
    elseif strcmpi(button, 'rename')
        defAns{1,1} = 'carnot_old.slx';
        ok=false;
        while (ok==false)
            newName = inputdlg('Please enter the filename:','Filename:',1,defAns);
            if isempty(newName)
                fprintf('aborted\n');
                return;
            end
            defAns{1,1}=newName{1};
            if isempty(dir(newName{1}))
                ok=true;
                if exist('carnot.mdl','file')
                    movefile('carnot.mdl', newName{1});
                end
                if exist('carnot.slx','file')
                    movefile('carnot.slx', newName{1});
                end
            else
                uiwait(msgbox('File already exists.'));
            end
        end
    else
        error('Aborting ...')
    end
end
%%create new carnot libary file
new_system('carnot','Library');
set_param('carnot','Lock','off');

%%add auxblocks
add_block('built-in/SubSystem','carnot/Help');
set_param('carnot/Help','Position', [30 118 58 146]);
set_param('carnot/Help','OpenFcn','helpcarnot');
set_param('carnot/Help','MaskDisplay','disp(''?'');');

add_block('built-in/SubSystem','carnot/License');
set_param(gcb,'Position', [176 111 348 161]);
set_param('carnot/License','ShowName','off');
set_param('carnot/License','MaskDisplay',['disp(''',CarnotAnnotation,'\n','for MATLAB ',SimulinkVersion,'\n',Copyright,''');']);
MyText=sprintf('%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n  \t%s\n  \t%s\n\n %s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n \t%s\n', ...
    'This file is part of the CARNOT Blockset.',...
    'Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.',...
    'Additional Copyright for file and models see list auf authors.',...
    'All rights reserved.',...
    'Redistribution and use in source and binary forms, with or without ',...
    'modification, are permitted provided that the following conditions are met:',...
    '1. Redistributions of source code must retain the above copyright notice, ',...
    '   this list of conditions and the following disclaimer.',...
    '2. Redistributions in binary form must reproduce the above copyright ',...
    '   notice, this list of conditions and the following disclaimer in the ',...
    '   documentation and//or other materials provided with the distribution.',...
    '3. Neither the name of the copyright holder nor the names of its ',...
    '   contributors may be used to endorse or promote products derived from ',...
    '   this software without specific prior written permission.',...
    'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" ',...
    'AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE ',...
    'IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ',...
    'ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE ',...
    'LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR ',...
    'CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF ',...
    'SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS ',...
    'INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN ',...
    'CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ',...
    'ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF ',...
    'THE POSSIBILITY OF SUCH DAMAGE.');
add_block('built-in/Note',['carnot/License/',MyText], 'Position', [50 0 20 0],'FontSize',12,'HorizontalAlignment','left');

add_block('built-in/SubSystem','carnot/Carint');
set_param(gcb,'Position', [380 114 490 157]);
set_param('carnot/Carint','OpenFcn', 'carint');
set_param('carnot/Carint','ShowName','off');
set_param('carnot/Carint','MaskDisplay','disp(''double click to\nload Carnot Internal'');');

add_block('built-in/SubSystem','carnot/examples');
set_param(gcb,'Position', [510 114 623 157]);
set_param('carnot/examples','OpenFcn', 'CarnotCallbacks_LoadExamples');
set_param('carnot/examples','ShowName','off');
set_param('carnot/examples','MaskDisplay','disp(''double click \nto load examples'');');


%%add public blocks
PositionPublic = AddToCarnotMDL(LibDirectoryPublic, CarnotDirectory, 0, 0, 'carnot', []);


if strcmp(Mode, 'all') %%add internal blocks
    % check internal blocks
    DirectoriesExist = true;
    if ~exist(fullfile(CarIntDirectory, 'bin'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(CarIntDirectory, 'src'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(CarIntDirectory, 'src', 'libraries'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(CarIntDirectory, 'library_c'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(CarIntDirectory, 'library_simulink'), 'dir')
        DirectoriesExist = false;
    else
        if numel(dir(fullfile(CarIntDirectory, 'library_simulink'))) <= 2 % directory contains only . and ..
            DirectoriesExist = false;
        end
        if ~exist(fullfile(CarIntDirectory, 'library_simulink', 'status.txt'), 'file')
            DirectoriesExist = false;
        end
    end
    
    if ~DirectoriesExist
        fprintf('Directories for internal models do not exist ... skipping\n');
    else
        AddToCarnotMDL(LibDirectoryInternal, CarnotDirectory, 0, 180, 'carnot', PositionPublic);
    end
end

%% save library in the desired Simulink version
load_system('carnot');
set_param('carnot','Lock','off');
set_param('carnot','ModelVersionFormat',CarnotVersion);
% set_param('carnot','ModelVersionFormat',[CarnotVersion,'.%<AutoIncrement:-1>']);
set_param('carnot','EnableLBRepository','on');
save_system('carnot');
%     save_system('carnot', 'carnot', 'ExportToVersion', SimulinkVersion);
close_system('carnot', 0);
rmpath(VersionManagerDirectory);
cd(VersionManagerDirectory);
end
