%% hp_param calculates the matrix K for the HeatPump model in CARNOT
%% function call
%  K = hp_param(A, [show])
%% input: 
%   A : matrix where each row has five elements 
%       (give at least two rows for A)
%       A = [qdot_hot qdot_cold  pel tcold  thot]
%       column 1 is the heating power                   qdot_hot  = A(:,1)
%       column 2 is the absorbing power                 qdot_cold = A(:,2)
%       column 3 is the electric power                  pel = A(:,3)
%       column 4 is the corresponding source temperature tcold = A(:,4)
%       (usually the source side inlet temperature)     
%       column 5 is the corresponding sink temperature  thot = A(:,5)
%       (usually the heating side outlet temperature)        
%  show : optional parameter (default: true)
%       1 / true - plot the input data and fit in a graph
%       0 / false - no plot
%% output: 
%  K : vector with 9 elements [K1 K2 K3 K4 K5 K6 K7 K8 K9]
%% Description
%  Linear model in primary and seconary temperature, used by
%  the carnot heat_pump model:
%   heating_power = K1 * Tprimary + K2 * Tsecondary + K3 
%   electric_power = K4 * Tprimary + K5 * Tsecondary + K6
%   cooling_power = K7 * Tprimary + K8 * Tsecondary + K9
%  Hint: Specify heating, cooling and electric power especially at lowest 
%  and highest temperatures. Other values will be interpolated.
%% References
%  see also : block HeatPump in Carnot

function K = hp_param(varargin)
% check the inputs
if nargin < 1
   error('hp_param.m : expecting one input parameter') 
else
    A = varargin{1};
end
if nargin > 1
    show = logical(varargin{2});
else
    show = true;
end
%  A = [qdot_hot qdot_cold pel tcold thot]
if size(A,1) < 2
   error('hp_param.m : number of rows in input matrix must be >= 2') 
end
if size(A,2) ~= 5
   error('hp_param.m : number of columns in input matrix must be 5') 
end
% check power balance: qdot_hot = qdot_cold + pel - losses
% losses are typically 7 % of pel
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
% plot the result
if show
    qdot_hot  = A(:,1);
    qdot_cold = A(:,2);
    pel = A(:,3);
    tcold = A(:,4);
    thot = A(:,5);
    Tc = [(min(tcold)-5) (max(tcold)+5)];
    figure('Name','hp_param: input data and fitted power')
    subplot(3,1,1)
    plot(tcold,qdot_hot,'ro')
    ylabel('power in W')
    title('heating')
    hold on
    for n = 1:length(thot)
        plot(Tc,K(1)*Tc+K(2)*thot(n)+K(3),'k')
    end
    hold off
    subplot(3,1,2)
    plot(tcold,qdot_cold,'bo')
    ylabel('power in W')
    title('cooling')
    hold on
    for n = 1:length(thot)
        plot(Tc,K(7)*Tc+K(8)*thot(n)+K(9),'k')
    end
    hold off
    subplot(3,1,3)
    plot(tcold,pel,'go')
    ylabel('power in W')
    title('electric')
    hold on
    for n = 1:length(thot)
        plot(Tc,K(4)*Tc+K(5)*thot(n)+K(6),'k')
    end
    hold off
end
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

%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2022, Solar-Institute Juelich of the FH Aachen.
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
%  author list:     gf -> Gaelle Faure
%                   hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  1.1.0    hf      created                                     around 1999
%  5.1.0    gf      add electric and absorbing power estimation 23sep2010
%  6.1.0    hf      added input check                           18feb2018
%  7.1.0    hf      comments adapted to publish function        09mar2022
%  7.2.0    hf      added plots                                 10mar2022
