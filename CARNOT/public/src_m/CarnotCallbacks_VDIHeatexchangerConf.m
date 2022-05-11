%% CarnotCallbacks_VDIHeatexchangerConf Callback for Carnot model VDIHeatexchanger
%% Function Call
%  [ok, param] = CarnotCallbacks_VDIHeatexchangerConf(fname, bhandle)
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%  bhandle - block handle (result of matlab function gcbh)
%% Outputs
%  ok       - true if loading of parameters was successfull, false otherwise
%  param    - parameter set (or other return value)
% 
%% Description
%  Search for the parameterfile in the folders parameter_set of the model
%  and load the parameter set. The function is used by the mask of the
%  Carnot Simlink block.
%  The user can specify whether the parameters are read from file or edited
%  by the user.
%  When using this file as a template: The two parameters before
%  'userPath' are interpreted as pathname and filename. All parameters 
%  after 'userParam' are interpeted as part of the parameter set. 
%  See VDIHeatexchanger_CONF block in Carnot for the settings of the mask.
%  Get their names and values with:
%         mnames = get_param(bhandle,'MaskNames');
%         mvalues = get_param(bhandle,'MaskValues');
%         idx = find(strcmp(mnames,'userParam'))+1;
%         for i = idx:length(mnames)
%             s = [variableName '.' mnames{i} ' = ' mvalues{i} ';'];
%             eval(s)
%         end
% 
%% References and Literature
%  Function is used by: Simulink block VDIHeatexchanger_CONF
%  Function calls: CarnotCallbacks_CONFblocks.m
%  see also CarnotCallbacks_CONFblocks

function varargout = CarnotCallbacks_VDIHeatexchangerConf(varargin)
%% Main function CarnotCallbacks_VDIHeatexchangerConf
% check correct number of input arguments
if nargin >= 2 && ischar(varargin{1})
    command = varargin{1};
else
    error(['CarnotCallbacks_VDIHeatexchangerConf: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.'])
end

blockpath = fullfile('Source', 'Heat_Exchanger', 'VDIHeatExchanger',...
    'parameter_set');

switch command      % switch for command line calls
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_CONFblocks('UserEdit', varargin{2});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_CONFblocks('GetFilename', varargin{2:end}, blockpath);
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_CONFblocks('SaveFilename', varargin{2:end}, blockpath);
    case 'SetParameters'
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_CONFblocks('SetParameters', varargin{2:end}, blockpath);
    otherwise
        % something went wrong
        ok = false;
end
varargout{1} = ok;
varargout{2} = param;
end     % end of function CarnotCallbacks_VDIHeatexchangerConf


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
%   
%  7.1.0    ok      created Block VDIHeatexchangerConf         24jun2020
%                   
% *************************************************************************
% $Revision: 1 $
% $Author: carnot $
% $Date: 2020-06-24 11:19:26 +0200 (Mi, 24 Jun 2020) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_VDIHeatexchangerConf.m $
% *************************************************************************
