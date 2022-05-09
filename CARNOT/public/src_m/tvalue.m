function erg = tvalue(time)
%Functions   converts a date in seconds to the time comment format 
%            YYYYMMDDHHMM
%
% Input       date in seconds
%
% Output      date (integer value)

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
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/tvalue.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
% 
% version   author  changes                                     date
% 1.0.0     hf      created                                     20th century
% 4.1.0     hf      vectorized version                          04jan2011

if nargin ~= 1
  help tvalue
  return
end

ergstr = datestr(time/(3600*24)+datenum(2005,1,1),'yyyymmddHHMM'); % 2-dim string
erg = nan(size(ergstr,1),1);
for i=1:size(ergstr,1)
    erg(i) = str2double(ergstr(i,:));
end

