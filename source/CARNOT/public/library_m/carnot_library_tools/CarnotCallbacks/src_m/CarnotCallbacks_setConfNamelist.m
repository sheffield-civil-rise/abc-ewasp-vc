%% Callback for Carnot models to set parameter file list
%% Function Call
%  ok = CarnotCallbacks_setConfNamelist(intpath,pubpath)
%% Inputs   
%  blockpath - relative path to the parameter files (*.mat) of the block
%
%% Outputs
%  ok - update of the popup menue with the file list was successfull
% 
%% Description
%  Sets the parameter list for configurated blocks. The function is 
%  searching for parameter sets in public and internal folder of the block
%  defined in blockpath.
% 
%% References and Literature
%  Function is used by: Carnot Simulink _CONF blocks
%  Function calls: CarnotCallbacks_getConfNamelist
%  see also CarnotCallbacks_getConfNamelist, CarnotCallbacks_loadConfParameters

function ok = CarnotCallbacks_setConfNamelist(blockpath)
%% Calculations
ok = false;
if ~ BlockIsInCarnotLibrary       % if not located in library
    ok = true;
    namelist = CarnotCallbacks_getConfNamelist(blockpath);

    blockHandle = get(gcbh);
    MaskNames = get_param(blockHandle.Handle, 'MaskNames');
    MaskStyles = get_param(blockHandle.Handle, 'MaskStyles');
    MaskParamInitValue = get_param(blockHandle.Handle, 'parameterfile');
    
    for k = 1:length(MaskNames)
        if strcmp(MaskNames{k},'parameterfile')
            MaskStyles{k} = ['popup(', namelist,')'];
            set_param(blockHandle.Handle, 'MaskStyles', MaskStyles)
            break
        end
    end
    
    if ~isempty(regexp(MaskParamInitValue,namelist, 'once'))
        set_param(blockHandle.Handle, 'parameterfile', MaskParamInitValue)
    else
        warning(['Block ''', gcb, ''': initial parameter file ''', MaskParamInitValue, ''' not found'])
    end
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
%  Version   Author  Changes                                     Date
%  6.1.0     hf      created                                     20oct2017
% *************************************************************************
% $Revision: 315 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_getConfNamelist.m $
% *************************************************************************
