function lib = BlockIsInCarnotLibrary()
% lib = BlockIsInCarnotLibrary()
% returns true, if the current block is still in the carnot library or the 
% atomic library
% input: -
% output: lib - true, if block is still in a library
%                                                                          
% See also: --
% 
% Function Calls:
% function is used by: CONF blocks and Callbacks
% this function calls: --
% 
% Literature: -

% all comments above appear with 'help BlockIsInCarnotLibrary' 
% ***********************************************************************
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
% $Revision: 372 $
% $Author: carnot-wohlfeil $
% $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/carnot_library_tools/BlockIsInCarnotLibrary/src_m/BlockIsInCarnotLibrary.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     19dec2014
% 6.1.1     hf      added carint to the library names           13nov2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

csys = bdroot;                 % get current main system
[~, name, ~]= fileparts(gcb);  % get name of block

% if not located in the carnot library, not in carlib and not in the atomic 
% library (name is blockname in the atomic library)
if  ~strcmp(csys,'carnot') && ~strcmp(csys,name) && ~strcmp(csys,'carint')
    lib = false;
else
    lib = true;
end