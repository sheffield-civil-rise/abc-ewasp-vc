%% CarnotCallbacks_Absorption_Chiller_LookUp is used by the Carnot Absorption_Chiller_LookUp 
% The file contains also other subfunctions:
% function CreateMaskAnnotations(block)

function varargout = CarnotCallbacks_Absorption_Chiller_LookUp(varargin)
% Switch for command line calls
if nargin >= 1 && ischar(varargin{1})
    FunctionName = varargin{1};
    % Call the function
    if nargout > 0
        [varargout{1:nargout}] = feval(FunctionName, varargin{2:end});
    else
        feval(FunctionName, varargin{2:end});
    end
else
    error('First argument must be a valid function name. Second argument must be the blockpath.')
end
end


function CreateMaskStyles(block) %#ok<DEFNU>
MaskStyles=get_param(block, 'MaskStyles');
file = fullfile(path_carnot('libsl'),'Source','Chiller', ...
    'Absorption_Chiller_LookUp','parameter_set', 'Absorption_Chiller_LookUp_data');
load(file);
MaskStyles{1}='popup(';
for CountChiller = 1:numel(Absorption_Chiller_LookUp_data) %#ok<USENS>
    MaskStyles{1} = [MaskStyles{1}, Absorption_Chiller_LookUp_data{CountChiller}.name, '|'];
end
MaskStyles{1} = [MaskStyles{1}, 'own data)'];
set_param(block, 'MaskStyles', MaskStyles);
end


function ChillerNumber = GetChillerNumber(ChillerType)
file = fullfile(path_carnot('libsl'),'Source','Chiller', ...
    'Absorption_Chiller_LookUp','parameter_set', 'Absorption_Chiller_LookUp_data');
load(file);
ChillerNumber = 0;
ChillerCount = 0;
while (ChillerCount<numel(Absorption_Chiller_LookUp_data)) && (ChillerNumber==0) %#ok<USENS>
    ChillerCount=ChillerCount+1;
    if strcmp(Absorption_Chiller_LookUp_data{ChillerCount}.name, ChillerType)
        ChillerNumber = ChillerCount;
    end
end
end


function CreateMaskVisibilities(block)  %#ok<DEFNU>
ChillerType = get_param(block, 'chillertype');
ChillerNumber = GetChillerNumber(ChillerType);
if ChillerNumber == 0 %own
    MaskVisibilities={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'};
else
    MaskVisibilities={'on';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off'};
end
set_param(block, 'MaskVisibilities', MaskVisibilities);
end


function data = GetChillerData(chillertype, heating_T_heating, ...
    heating_T_recooling, heating_T_cooling, heating_Qdot, ...
    recooling_T_heating, recooling_T_recooling, recooling_T_cooling, ...
    recooling_Qdot, cooling_T_heating, cooling_T_recooling, ...
    cooling_T_cooling, cooling_Qdot, deadtime_factor, deadtime_exponent) %#ok<DEFNU>
ChillerNumber = GetChillerNumber(chillertype);
if ChillerNumber == 0
    data.heating_T_heating = heating_T_heating;
    data.heating_T_recooling = heating_T_recooling;
    data.heating_T_cooling = heating_T_cooling;
    data.heating_Qdot = heating_Qdot;
    data.recooling_T_heating = recooling_T_heating;
    data.recooling_T_recooling = recooling_T_recooling;
    data.recooling_T_cooling = recooling_T_cooling;
    data.recooling_Qdot = recooling_Qdot;
    data.cooling_T_heating = cooling_T_heating;
    data.cooling_T_recooling = cooling_T_recooling;
    data.cooling_T_cooling = cooling_T_cooling;
    data.cooling_Qdot = cooling_Qdot;
    data.deadtime_factor = deadtime_factor;
    data.deadtime_exponent = deadtime_exponent;
else
    file = fullfile(path_carnot('libsl'),'Source','Chiller', ...
        'Absorption_Chiller_LookUp','parameter_set', ...
        'Absorption_Chiller_LookUp_data');
    load(file);
    data = Absorption_Chiller_LookUp_data{ChillerNumber}; %#ok<USENS>
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
% author list:      aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.2.0     aw      created                                     14dec2017
% 6.2.1     hf      file Absorption_Chiller_LookUp_data moved   21dec2017
%                   to folder 'Absorption_Chiller_LookUp\parameter_set'
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
