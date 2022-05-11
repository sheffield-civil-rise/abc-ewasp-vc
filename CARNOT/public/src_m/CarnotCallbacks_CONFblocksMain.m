%% Callback for all CONFblocks Main 
%% Function Call
%  [ok, param] = CarnotCallbacks_CONFblocksMain(fname, bhandle)
%% Inputs   
%  fname - function name for the callback:
%          'UserEdit' - disable / enable editing of filename+pathname or parameters
%          'GetFilename' - get the filename and pathname, set these variables in the mask
%          'SaveFilename' - save parameter set with new filename and pathname
%          'SetParameters' - load parameterfile and set parameters
%          'SetParameterFile' - set parameterfile to the respective lower mask CONF blocks
%  bhandle - block handle (result of matlab function gcbh)
%  blockpath - path to the parameter files (*.mat) of the block relative to
%              the result of path_carnot('libsl')
%              example: fullfile('Source','Solar_Thermal', 'Collector_EN12975_CONF','parameter_set')
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
%  Function is used by: All Config Models
%  see also CarnotCallbacks_CONFblocksFunctions

function varargout = CarnotCallbacks_CONFblocksMain(varargin)
%% Main function CarnotCallbacks_Vitobloc
% check correct number of input arguments
if nargin >= 2 && ischar(varargin{1})
    command = varargin{1};
else
    error(['CarnotCallbacks_CONFblocksMain: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.'])
end

% switch for command line calls
switch command      % switch for command line calls
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_CONFblocks('UserEdit', varargin{2:end});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_CONFblocks('GetFilename', varargin{2:end});
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_CONFblocks('SaveFilename', varargin{2:end});
    case 'SetParameters'
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_CONFblocks('SetParameters', varargin{2:end});
    case 'SetParameterFile'
        % set parameterfile to respective CONF blocks automatically
        [ok, param] = CarnotCallbacks_CONFblocks('SetParameterFile',varargin{2:end});
    otherwise
        % something went wrong
        ok = false;
end

varargout{1} = ok;
varargout{2} = param;
end % of function

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
% *************************************************************************************************************************************************
%  VERSIONS
% 
%  author list:     hf -> Bernd Hafner
%                   ptia -> Amruta Patil
%
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     12nov2015
%  6.1.1    hf      added userParam as 2nd input parameter      13nov2017
%  6.2.0    hf      adapted to new mask concept                 21sep2018
%                   and to new callback concept           
%  6.2.1    PtiA    renamed and adapted                         14jul2020
%                   new: CarnotCallbacks_CONFblocksMain
%                   adapted new command 'SetParameterFile'      
%                   removed blockpath from the function
%  7.1.0    hf      moved function to carnot/public             14mar2021
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
