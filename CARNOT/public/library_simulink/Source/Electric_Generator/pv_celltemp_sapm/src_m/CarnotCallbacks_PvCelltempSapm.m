%% function SetTemperatureModel loads the temperature model parameters and set parameters to the block in bhandle
function [ok, paramStruct] = CarnotCallbacks_PvCelltempSapm(bhandle)
ok = false;
paramStruct = [];
blockpath = fullfile('Source','Electric_generator', 'pv_celltemp_sapm','parameter_set');
    
if ~BlockIsInCarnotLibrary 
    if exist(fullfile(path_carnot('intlibsl'),blockpath,'sandia_temperature_model.mat'), 'file')
        file = fullfile(path_carnot('intlibsl'),blockpath, 'sandia_temperature_model.mat');
    elseif exist(fullfile(path_carnot('libsl'),blockpath, 'sandia_temperature_model.mat'), 'file')
        file = fullfile(path_carnot('libsl'),blockpath, 'sandia_temperature_model.mat');
    end
    mountOptions = importdata(file);
    TypeMount = get_param(bhandle,'TypeMount');
    MaskInit = get(bhandle,'MaskInitialization');
    MaskInit = ['%',MaskInit];
    if strcmp(TypeMount, '<user defined>')
        maskNames = get_param(bhandle, 'MaskNames');
        maskEnables = get_param(bhandle, 'MaskEnables');
%         enableParams = {'a','b','E0','dTc', 'tau','tini'}; 
        enableParams = {'a','b','E0','dTc'}; 
        idx = cellfun(@(x) strcmp(maskNames,x),enableParams, 'UniformOutput', false);
        idx = find(sum(cell2mat(idx),2));
        maskEnables(idx) = {'on'};     
        set_param(bhandle, 'MaskEnables', maskEnables);  
    elseif strcmp(TypeMount, '<propagated>')
        maskNames = get_param(bhandle, 'MaskNames');
        maskEnables = get_param(bhandle, 'MaskEnables');
%         enableParams = {'a','b','E0','dTc', 'tau','tini'}; 
        enableParams = {'a','b','E0','dTc',}; 
        idx = cellfun(@(x) strcmp(maskNames,x),enableParams, 'UniformOutput', false);
        idx = find(sum(cell2mat(idx),2));
        maskEnables(idx) = {'off'};        
        set_param(bhandle, 'MaskEnables', maskEnables);              
        for i = 1:length(enableParams)
            set_param(bhandle, enableParams{i}, enableParams{i});
        end
    else
        maskNames = get_param(bhandle, 'MaskNames');
        maskEnables = get_param(bhandle, 'MaskEnables');
%         enableParams = {'a','b','E0','dTc', 'tau','tini'};
        enableParams = {'a','b','E0','dTc'};
        idx = cellfun(@(x) strcmp(maskNames,x),enableParams, 'UniformOutput', false);
        idx = find(sum(cell2mat(idx),2));
        maskEnables(idx) = {'off'};
        set_param(bhandle, 'MaskEnables', maskEnables);
        set_param(bhandle, 'E0', '1000');
        %set_param(bhandle, 'tini', '25');
%         set_param(bhandle, 'tau', '300');
        set_param(bhandle, 'dTc', '2');% which value to be used as default ?
        for r1 = 2:length(mountOptions)
            if contains(mountOptions(r1).ModuleTypeMounting, TypeMount)
                set_param(bhandle, 'a', num2str(mountOptions(r1).a));
                set_param(bhandle, 'b', num2str(mountOptions(r1).b));
            end
        end
    end
    MaskInit = MaskInit(2:end);
    set(bhandle,'MaskInitialization', MaskInit);
end
end % function SetTemperatureModel

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
% *************************************************************************
% $Revision: 2 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_CelltempSapm.m $
%  ************************************************************************
%  VERSIONS
%  author list:     pk -> Patrick Kefer
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                       Date
%  7.0.1    pk      created                                      29jan2019
%  
% *************************************************************************