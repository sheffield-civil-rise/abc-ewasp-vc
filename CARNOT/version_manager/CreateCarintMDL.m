function CreateCarintMDL
% function CreateInternalMDL
% Use this function to assemle the atomic libraries in the
% internal folder to carint.slx.

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
% $Revision: 646 $
% $Author: carnot-hafner $
% $Date: 2019-11-27 20:37:57 +0100 (Mi., 27 Nov 2019) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/version_manager/CreateCarnotMDL.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      pk -> Patrick Kefer
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 7.0.1     pk      created                                     jan2020
% 7.0.2     pk      carnot init no more necessary               28may2020
VersionManagerDirectory = pwd;
addpath(VersionManagerDirectory);
cd('..');
%%set up paths
CarIntDirectory = fullfile(pwd,'internal');
LibDirectory = [CarIntDirectory,'\library_simulink'];

%set up information
SimulinkVersion = ver('Matlab');
SimulinkVersion = regexprep(SimulinkVersion.Release,'\(|\)','');
CopyrightInfo = '';
IntLibName = 'carint';
CarintVersion = '7.0';% default if carint doesn't exist
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
    %% set up information
    try
        load_system(fullfile(CarIntDirectory,IntLibName));
        CarintVersion = get_param(gcs,'ModelVersion');
    catch
        warning([IntLibName,' not found: default model version number ',CarintVersion,' used']);        
    end
    [split, idx] = regexp(CarintVersion,'\.','split');
    ModelVersion = str2double(split{end});
    MainVersion = CarintVersion(1:idx(end));
    close_system(IntLibName);
    
    % check if carint already existis
    if exist('carint.mdl','file') || exist('carint.slx','file')
        button = questdlg('Carint already exists. ','Question','abort','delete','rename','abort');
        if strcmpi(button, 'delete')
        elseif strcmpi(button, 'rename')
            defAns{1,1} = 'carint_old.slx';
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
                    if exist('carint.mdl','file')
                        movefile(fullfile('internal','carint.mdl'), fullfile('internal',newName{1}));
                    end
                    if exist('carint.slx','file')
                        movefile(fullfile('internal','carint.slx'), fullfile('internal',newName{1}));
                    end
                else
                    uiwait(msgbox('File already exists.'));
                end
            end
        else
            error('Aborting ...')
        end
    end
    % create new carint libary file
    new_system('carint','Library');
        
    %% add all blocks
    %add internal blocks
    AddToCarnotMDL(LibDirectory, CarIntDirectory, 0, 0, IntLibName, []);
    load_system(IntLibName);
    set_param(IntLibName,'Lock','off');
    set_param(IntLibName,'ModelVersionFormat',MainVersion+"%<AutoIncrement:"+ModelVersion+">");
    set_param(IntLibName,'EnableLBRepository','on');
    save_system(IntLibName, [IntLibName,'.slx']);
    close_system(IntLibName, 0);
    rmpath(VersionManagerDirectory);
    cd(VersionManagerDirectory);
end
end
%% Copyright and Versions
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
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_THBCreator.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      pk -> Patrick Kefer

% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 7.1.0     pk      created                                     30.sept2020
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

