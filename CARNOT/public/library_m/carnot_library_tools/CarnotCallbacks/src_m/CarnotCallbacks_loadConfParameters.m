%% Callback to load parameters for CONF blocks
%% Function Call
%  [paramStruct, ok] = CarnotCallbacks_loadConfParameters(blockpath,paramfile)
%% Inputs   
%  blockpath - relative path to the parameter files (*.mat) of the block
%  parameterfile - filename of the selected parameter set
% 
%% Outputs
%  paramStruct - strucutre with the parameter set
%  of - true, if loading and setting of params was successfull
% 
%% Description
%  Search for the parameterfile in the public and internal folders 
%  parameter_set of the model and load the parameter set. 
% 
%% References and Literature
%  Function is used by: Mask of CONF blocks in Carnot.
%  Function calls: CarnotCallbacks_getConfNamelist.m
%  see also CarnotCallbacks_getConfNamelist

function [paramStruct, ok] = CarnotCallbacks_loadConfParameters(blockpath,paramfile)
%% Calculations
ok = false;
paramStruct = [];
if ischar(paramfile)
    if ~BlockIsInCarnotLibrary
        intfile = fullfile(path_carnot('intlibsl'), blockpath,[paramfile '.mat']);
        pubfile = fullfile(path_carnot('libsl'), blockpath, [paramfile '.mat']);
        
        if exist(intfile,'file')
            paramStruct = importdata(intfile);
            disp(['Block ''', gcb, ''': loading internal parameter set ''', paramfile, ''''])
        elseif exist(pubfile,'file')
            paramStruct = importdata(pubfile);
            disp(['Block ''', gcb, ''': loading parameter set ''', paramfile, ''''])
        else
            warning(['Block ''', gcb, ''': parameter set ''', paramfile, ''' not found. No changes are applied.'])
            return
        end
        ok = true;
        
        paraNames = fieldnames(paramStruct);    % get parameter names
        
        % Get block properties
        blockHandle = get(gcbh);
        maskNames = get_param(blockHandle.Handle, 'MaskNames');
        
        for k = 1:length(maskNames)
            for l = 1:length(paraNames)
                if strcmp(maskNames{k},paraNames{l})
                    if ischar(paramStruct.(paraNames{l})) % parameter is already char
                        set_param(blockHandle.Handle, maskNames{k}, ...
                            paramStruct.(paraNames{l}));
                    else
                        set_param(blockHandle.Handle, maskNames{k}, ...
                            mat2str(paramStruct.(paraNames{l})));
                    end
                end
            end
        end
    end
else
    warning(['Block ''', gcb, ''': parameter file is not a valid character array'])
end

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
%  ************************************************************************
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     20oct2017
%  6.2.0    hf      paramStruct as additional output            26oct2017
% *************************************************************************
% $Revision: 315 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_StorageConf.m $
% *************************************************************************
