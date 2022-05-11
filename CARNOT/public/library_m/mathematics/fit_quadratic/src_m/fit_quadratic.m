%% function fit_quadratic fits a quadratic polynom to the input data
%% Function Call
%  a = fit_quadratic(x,y,[c])
%% Inputs
%  x : x-data for the polynom p(x) 
%  y : y-data or result of the polynom p(x)
%  c : [optional] boundary conditions
%% Outputs
%  a : vector with the 3 coefficients 
% 
%% Description
%  Fit a polynom to data in a least square sense:
%  y = p(x) = a(1)*x^2 + a(2)*x^1 + a(3)*x^0
%  Best estimate for the coefficients found by 
%  solving A*[a(1) a(2) a(3)]' = y
%  is [a(1) a(2) a(3)] = A\y
%  Boundary conditions:
%  c = 1 : coefficients a(2) and a(3) are zero
%  c = 2 : coefficient a(3) is zero
%  c = 3 : none - fit_quadratic is uses same function as polyfit(x,y,2)
% 
%% References and Literature
%  
%  
%  see also polyfit


function a = fit_quadratic(varargin)
%% handle input errors variable number of input arguments
if nargin < 2
    error('fit_quadratic needs at least x and y data as input')
else
    x = varargin{1};
    y = varargin{2};
end
if ~isequal(size(x),size(y))
    error('')
end
if nargin < 3
    c = 1;              % default is fitting of 3 coeffs
else
    c = varargin{3};
end

%% Calculations
% Vandermonde matrix V has the powers of the polynomial 
a = zeros(1,3);
switch c                % switch case of boundary conditions
    case 3              % fit 3 coefficients a: y = a(1)*x^2 + a(2)*x + a(3)
        V = bsxfun(@power, x(:), [2 1 0]);
        a(1:3) = V\y(:);
    case 2              % fit 2 coefficients a: y = a(1)*x^2 + a(2)*x
        V = bsxfun(@power, x(:), [2 1]);
        a(1:2) = V\y(:);
    case 1              % fit 1 coefficients a: y = a(1)*x^2
        V = bsxfun(@power, x(:), 2);
        a(1) = V\y(:);
    otherwise 
        error('fit_quadratic : parameter c has to be 1, 2 or 3')
end


%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2021, Solar-Institute Juelich of the FH Aachen.
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
%  author list:      hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     22feb2021
%  ************************************************************************
%  $Revision: 1 $
%  $Author: carnot-hafner $
%  $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/tutorial/templates/template_carnot_m_function.m $
