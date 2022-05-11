function [ok, param] = CarnotCallbacks_PvDesoto(varargin)

if nargin >= 2 && ischar(varargin{1})
    command = varargin{1};
else
    error(['CarnotCallbacks_PvDesotoConf: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.'])
end

blockpath = fullfile('Source','Electric_Generator', 'pv_desoto','parameter_set');

% switch for command line calls
switch command      % switch for command line calls
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_PvlBlocks('UserEdit', varargin{2});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_PvlBlocks('GetFilename', varargin{2:end}, blockpath);
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_PvlBlocks('SaveFilename', varargin{2:end}, blockpath);
    case 'SetParameters'
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_PvlBlocks('SetParameters', varargin{2:end}, blockpath);         
    case 'SetTemperatureModel'    
        % set temperature model with popup in user edit mode
        [ok, param] = CarnotCallbacks_PvlBlocks('SetTemperatureModel', varargin{2});         
        param = 1;
        ok = true;
    otherwise     
        % something went wrong
        ok = false;
        param = -1;
end
varargout{1} = ok;
varargout{2} = param;
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
% *************************************************************************
% $Revision: 2 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_StorageConf.m $
%  ************************************************************************
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                       Date
%  6.3.0    pk      created                                      29jan2019
%  
% *************************************************************************
