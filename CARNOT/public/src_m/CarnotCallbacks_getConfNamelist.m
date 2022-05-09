%% Callback for Carnot models to get parameter file list
%% Function Call
%  namelist = CarnotCallbacks_getConfNamelist(blockpath)
%% Inputs   
%  blockpath - relative path to the parameter files (*.mat) of the block
%
%% Outputs
%  namelist - character strings of the filenames
% 
%% Description
%  Returns the parameter list for configurated blocks. The function is 
%  searching for parameter sets in public and internal folder of the block
%  defined in blockpath.
% 
%% References and Literature
%  Function is used by: Carnot Simulink _CONF blocks, CarnotCallbacks_setConfNamelist
%  Function calls: --
%  see also CarnotCallbacks_setConfNamelist, CarnotCallbacks_loadConfParameters

function namelist = CarnotCallbacks_getConfNamelist(blockpath)
%% Calculations
% get public parameter files
pubfiles = dir(fullfile(path_carnot('libsl'), blockpath,'*.mat'));
% set names in the popup mask
if ~isempty(pubfiles)
    namelist = pubfiles(1).name(1:end-4);
end

% if not in the library any more, add internal parameters sets to the list
intfiles = dir(fullfile(path_carnot('intlibsl'), blockpath,'*.mat'));

% add names from files to namelist
for n = 2:length(pubfiles)
    namelist = [namelist,'|',pubfiles(n).name(1:end-4)]; %#ok<AGROW>
end
for n = 1:length(intfiles)
    if ~exist('namelist', 'var')
        namelist = intfiles(n).name(1:end-4);
    else
        namelist = [namelist,'|',intfiles(n).name(1:end-4)]; %#ok<AGROW>
    end
end

if ~exist('namelist', 'var')
    namelist = '';
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
%  6.1.0     hf      created                                     18dec2014
%  6.1.1     hf      integrated "lib" as return argument         19dec2014
%  6.1.2     hf      new name CarnotCallbacks_getConfNamelist    23feb2015
%  6.1.3     hf      works also when public namelist is empty    08mar2015
%  6.1.4     hf      comments adapted to publish                 19oct2017
% *************************************************************************
% $Revision: 372 $
% $Author: carnot-wohlfeil $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_getConfNamelist.m $
% *************************************************************************
