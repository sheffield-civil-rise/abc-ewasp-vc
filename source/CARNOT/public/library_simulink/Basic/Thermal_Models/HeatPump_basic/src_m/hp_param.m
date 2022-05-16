function K = hp_param(A)
% HP_PARAM calculates the parameters K(1), K(2), K(3),
% K(4), K(5), K(6), K(7), K(8) and K(9)
% for the heat-pump model in the CARNOT library.
% K(1), K(2) and K(3) are used to estimate the heating power
% K(4), K(5) and K(6) enable to calculate electric power
% K(7), K(8) and K(9) are used to determine the absorbing power
% The model works with a linear characteristics.
% Specify heating, absorbing and electric power only at lowest and highest
% temperatures. Other values will be interpolated.
%
% syntax:   K = hp_param(A)
%
% input: a matrix A where each row has five elements
%       (specify at least two rows for A)
%   A = [qdot_hot qdot_cold     pel     tcold      thot]
%
%   first column is the heating power       qdot_hot  = A(:,1);
%   second column is the absorbing power    qdot_cold = A(:,2);
%   third column is the electric power      pel       = A(:,3);
%   fourth column is the corresponding source temperature
%       (usually the source side inlet temperature)     tcold = A(:,4);
%   fifth element is the corresponding sink temperature
%       (usually the heating outlet temperature)        thot = A(:,5);
%
%   linear model in primary and seconary temperature, used by
%   the carnot heat_pump model:
%   heating_power = K1 * Tprimary + K2 * Tsecondary + K3 
%   electric_power = K4 * Tprimary + K5 * Tsecondary + K6
%   absorbing_power = K7 * Tprimary + K8 * Tsecondary + K9
%
% output: [K1 K2 K3 K4 K5 K6 K7 K8 K9]


% check the inputs
if nargin ~= 1
   error('hp_param.m : expecting one input parameter') 
end
%  A = [qdot_hot qdot_cold     pel     tcold      thot]
if size(A,1) < 2
   error('hp_param.m : number of rows in input matrix must be >= 2') 
end
if size(A,2) ~= 5
   error('hp_param.m : number of columns in input matrix must be 5') 
end
ebalance = max(abs((A(:,1)-A(:,2)-A(:,3))./A(:,1)));
if ebalance > 0.2 
   warning('hp_param.m : error in energy balance > 20%') 
end
if A(:,4) > A(:,5)
   warning('hp_param.m : hot side temperature below cold side temperature') 
end
if or(A(:,4) > 100, A(:,4) < -50)
   warning('hp_param.m : cold temperatures are in an unusual range') 
end
if or(A(:,5) > 100, A(:,5) < -50)
   warning('hp_param.m : hot temperatures are in an unusual range') 
end

% main calculation: search parameters that fit best to the input matrix
K(1:3) = fminsearch(@(x) hp_param_func(x, A, 'heat'), [100 -10 100]);
K(4:6) = fminsearch(@(x) hp_param_func(x, A, 'electric'), [100 -10 100]);
K(7:9) = fminsearch(@(x) hp_param_func(x, A, 'absorbing'), [100 -10 100]);

end % of function


% -------------------------------------------------------------------------
%      subfunctions in this file
% -------------------------------------------------------------------------


function f = hp_param_func(x, A, type)
if (strcmp(type,'heat'))
    f = sum((A(:,1) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
elseif (strcmp(type,'electric'))
    f = sum((A(:,3) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
else   
    f = sum((A(:,2) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
end
end

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
% 
% ***********************************************************************
% Author        Changes                                         Date
% FarG          add electric and absorbing power estimation     23sep2010
% hf              added input check                             18feb2018
%
% $Revision: 408 $
% $Author: carnot-hafner $
% $Date: 2018-02-18 18:46:24 +0100 (So, 18 Feb 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_simulink/Basic/Thermal_Models/HeatPump_basic/src_m/hp_param.m $
