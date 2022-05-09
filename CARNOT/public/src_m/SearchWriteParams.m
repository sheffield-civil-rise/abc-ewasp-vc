%% gets mask parameters of Simulink models
%% Function Call
%   ttt = SearchWriteParams(modelname,fid)
%% Inputs   
%  modelname - name of the Simlink model (typically set to bdroot)
%  fid - file identifier for the [modelname '_params.txt'] file
%
%% Outputs
%  namelist - character strings of the filenames
% 
%% Description
% This function searches the Simulink model <modelname> for parameters in masks, 
% constant, FromFile and FromWorkspace blocks. It writes the information in a 
% structured way into the file wit id <fid>.
% This function is an example of recursive programming as it calls itself
% in its definition
% 
%% References and Literature
%  Function is used by: --
%  Function calls: --
%  see also bdroot

function ttt = SearchWriteParams(modelname,fid)
%% Calculations
ttt = 1;
lineSep  = '---------------------------------------------------------------------------';
lineHead = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -';
CC=find_system(modelname,'FollowLinks','on','LookUnderMasks','all', ...
    'SearchDepth',1,'BlockType','Constant');
CCsize=size(CC);
for ic=1:CCsize(1) 
    if ~isempty(get_param(CC{ic},'Value'))
        VV=get_param(CC{ic},'Value');
        NN=get_param(CC{ic},'Name');
        fprintf(fid,'%s\r\n','Constant Block');
        fprintf(fid,'%s',NN,':  :',VV);
        fprintf(fid,'%s\r\n\n','');
    end
end
CC=find_system(modelname,'FollowLinks','on','LookUnderMasks','all', ...
    'SearchDepth',1,'BlockType','FromWorkspace');
CCsize=size(CC);
for ic=1:CCsize(1) 
    if ~isempty(get_param(CC{ic},'VariableName'))
        VV=get_param(CC{ic},'VariableName');
        fprintf(fid,'%s\r\n','From Workspace');
        fprintf(fid,'%s',VV);
        fprintf(fid,'%s\r\n\n','');
    end
end
CC=find_system(modelname,'FollowLinks','on','LookUnderMasks','all', ...
    'SearchDepth',1,'BlockType','FromFile');
CCsize=size(CC);
for ic=1:CCsize(1)
    if ~isempty(get_param(CC{ic},'FileName'))
        VV=get_param(CC{ic},'FileName');
        fprintf(fid,'%s\r\n','From File');
        fprintf(fid,'%s',VV);
        fprintf(fid,'%s\r\n\n','');
    end
end
Subs=find_system(modelname,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1,'BlockType','SubSystem');
AAsize=size(Subs);
if AAsize(1)>1
    for i=2:AAsize(1) % Subs(1) is the model itself and must not be analysed again
        FN=fieldnames(get_param(Subs{i},'ObjectParameters'));
        AAA=strjoin(FN');
        if ~isempty(regexp(AAA,'MaskNames', 'once'))
            MN=get_param(Subs{i},'MaskNames');
            MV=get_param(Subs{i},'MaskValues');
            MNV=strcat(MN,':   :',MV);
            if ~isempty(MNV)
                ZZ=size(MNV);
                fprintf(fid,'%s\r\n',lineSep);
                fprintf(fid,'%s\r\n',Subs{i});
                fprintf(fid,'%s\r\n',lineHead);
                for j=1:ZZ(1)
                    fprintf(fid,'%s\r\n',MNV{j});
                end
                fprintf(fid,'%s\r\n','');
            end
        end
        ttt=SearchWriteParams(Subs{i},fid); % This recursive step makes sure that subsystems are treated as complete models
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
% **********************************************************************
%  VERSIONS
%  author list:     jg -> Joachimg Goettsche
%                   hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    jg      created                                     21dec2016
%  6.1.1    hf      adapted to publish, added 'once' to regexp  23oct2017
% *************************************************************************
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/airmass.m $
% *************************************************************************

