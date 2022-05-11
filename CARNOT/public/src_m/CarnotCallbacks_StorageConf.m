%% CarnotCallbacks_StorageConf - Callback for Carnot model Storage_TypeN
%% Function Call
%  [ok, param] = CarnotCallbacks_StorageConf(fname, bhandle, storagetype)
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%  bhandle - block handle (result of matlab function gcbh)
%  storagetype  - 0: buffer storage with inlet and outlet connection
%               - 1: buffer storage with charging and discharging pipes
%% Outputs
%  ok       - true if loading of parameters was successfull, false otherwise
%  param    - parameter set (or other return value)
% 
%% Description
%  Search for the parameterfile in the folders parameter_set of the model
%  and load the parameter set. The function is used by the mask of the
%  Carnot Simlink block.
%  Sets geometry values and sets the initial temperature 
%  vector to a vector with the length of the storage nodes. 
%  The input initial temperature vector can be of any size.
%  The user can specify whether the parameters are read from file or edited
%  by the user.
% 
%% References and Literature
%  Function is used by: Simulink block Storage_Type_1 ... Storage_Type_5
%  see also CarnotCallbacks_CONFblocks


function varargout = CarnotCallbacks_StorageConf(varargin)
%% Main function CarnotCallbacks_StorageConf
% check correct number of input arguments
if nargin >= 3 && ischar(varargin{1})
    command = varargin{1};
    % storagetype = varargin{2}; -> dummy argument, not used any more
else
    error(['CarnotCallbacks_StorageConf: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.' ...
        'Third argument must be the storage type.'])
end

% set relative path in carnot to the block
stgtype = get_param(gcb,'stgtype');   % get storagetype from the calling block
foldername = ['Storage_Type_', num2str(stgtype)];
if (~exist(fullfile(path_carnot('libsl'),'Storage','Thermal',foldername,'parameter_set'), 'file')) ...
        && (~exist(fullfile(path_carnot('intlibsl'),'Storage','Thermal',foldername,'parameter_set'), 'file'))
    error('Storage_CONF: Unknown storage type')
end
blockpath = fullfile('Storage','Thermal',foldername,'parameter_set');

% switch for command line calls
switch command
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_CONFblocks('UserEdit', varargin{3});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_CONFblocks('GetFilename', varargin{3:end}, blockpath);
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_CONFblocks('SaveFilename', varargin{3:end}, blockpath);
    case {'SetParam', 'SetParameters'}
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_CONFblocks('SetParameters', varargin{3:end}, blockpath);
        
        % set height according to position 
        % (height is not stored in parameter set)
        pos = get_param(gcb,'standing');
        x = get_param(gcb,'dia');
        if ischar(x)       % if value is a char array (assume that its a variable name)
            try
                dia = evalin('caller', x);
            catch
                dia = evalin('base', x);
            end
        else
            error('parameter ''diameter'' is not numeric and not a variable name')
        end
        x = get_param(gcb,'volume');
        if ischar(x)       % if value is a char array (assume that its a variable name)
            try
                volume = evalin('caller', x);
            catch
                volume = evalin('base', x);
            end
        else
            error('parameter ''volume'' is not numeric and not a variable name')
        end
        if strcmp(pos,'standing cylinder')
            h = volume/(0.25*dia.^2*pi);
        else
            h = dia;
        end
        set_param(gcb,'hgt',num2str(h));

        % set indices to measurement points 
        % (only number of sensors is stored in parameter set)
        x = get_param(gcb,'mpoints');
        if ischar(x)       % if value is a char array (assume that its a variable name)
            try
                mpoints = evalin('caller', x);
            catch
                mpoints = evalin('base', x);
            end
        else
            error('parameter ''number of node temperatures'' is not numeric and not a variable name')
        end
        x = get_param(gcb,'nodes');
        if ischar(x)       % if value is a char array (assume that its a variable name)
            try
                nodes = evalin('caller', x);
            catch
                nodes = evalin('base', x);
            end
        else
            error('parameter ''number of nodes'' is not numeric and not a variable name')
        end
        mpoints = max(mpoints,1);
        mpts = round(nodes/mpoints/2:nodes/mpoints:nodes);
        set_param(gcb,'mpts',mat2str(mpts));
        
        % set initial temperature (value is not in parameter set)
        x = get_param(gcb,'t0');
        if ischar(x)       % if value is a char array (assume that its a variable name)
            try
                t0 = evalin('caller', x);
            catch
                t0 = evalin('base', x);
            end
        else
            error('parameter ''initial temperature'' is not numeric and not a variable name')
        end
        n0 = length(t0);
        if n0 > 1
            x = linspace(0,1,n0);
            xx = linspace(0,1,nodes);
            tini = spline(x,t0,xx);
            tmin = min(t0);
            tmax = max(t0);
            tini = min(tini, tmax);
            tini = max(tini, tmin);
        else
            tini = ones(1,nodes).*t0;
        end
        set_param(gcb,'tini',mat2str(tini));
    
    otherwise
        % something went wrong
        ok = false;
        param = [];
end
varargout{1} = ok;
varargout{2} = param;
end     % end of function CarnotCallbacks_StorageConf

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2019, Solar-Institute Juelich of the FH Aachen.
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
%                   aw -> Arnold Wohlfeil
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     03oct2014
%  6.1.1    hf      direct subsystem mask parameters and        20dec2014
%                   storage sensor position is taken from s.Tsensor
%  6.1.2    hf      integrated getConfNamelist                  15feb2015
%  6.2.0    hf      set promoted parameters in top mask         13oct2017
%                   instead of parameters in submask, nconnect
%                   is no longer a top mask parameter
%  6.2.1    hf      revised for pubish function,                19oct2017
%                   replace function call to getConfNamelist
%                   by _CarnotCallbacks_getConfNamelist
%  6.3.0    hf      adapted to new callback concept             27oct2017
%  6.4.0    hf      implemented the use of functions in         03jan2018
%                   CarnotCallbacks_CONFblocks 
%  6.4.1    aw      update comments and copyright               11jan2018
%  6.4.2    hf      new structure of output arguments           13jan2018
%  6.4.3    hf      added case 'SetParam' for new CONF model    14sep2018
%  6.4.4    hf      added Storage_Type_0                        03oct2018
%  6.4.5    hf      additional otherwise in switch storagetype  08oct2018
%  6.5.0    hf      'SetParam' and 'SetParameters' use          23nov2018
%                   the same case 
%                   changed evaluation of dia, nodes, mpoints, t0
%  7.1.0    hf      new block name Storage_TypeN                20mar2019
%                   (old name Storage_TypeN_CONF)
%  7.1.1    hf      general functionality for storagetypes in   13mar2021
%                   public and internal carnot folders
%                   parameter storagetype of the function call
%                   has become a dummy argument
% *************************************************************************
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% *************************************************************************
