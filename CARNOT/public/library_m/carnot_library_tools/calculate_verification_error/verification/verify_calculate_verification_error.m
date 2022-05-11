%% verification of the Carnot function verify_calculate_verification_error
%% Function Call
%  [v, s] = verify_calculate_verification_error(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  verification of the Carnot function verify_calculate_verification_error
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_calculate_verification_error(varargin)
% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = false;
elseif nargin >= 1
    show = logical(varargin{1});
else
    error('verify_verify_calculate_verification_error:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
% maximum error is for absolute sum, sum is 55
max_error = eps(2*56);      % max error between simulation and reference
v = true;                   % be optimistic, no errors will occur

% ---------- set model file or function name ------------------------------
functionname = 'calculate_verification_error';

%% set the literature reference values
y = ones(10,4,1).*(1:10)';
y0(:,:,1) = y;
y0(:,:,2) = 2*y;
y0(:,:,3) = 3*y;            % reference results
y1 = 0.1*ones(10,4,3);
y1 = y0+y1;                 % simulation results

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim

for n = 1:12
    switch n
        case 1
            r = 'absolute'; 
            s = 'sum';
            eexp = 1;
            yexp = abs(y0-y1);
        case 2
            r = 'absolute'; 
            s = 'mean';
            eexp = 0.1;
            yexp = abs(y0-y1);
        case 3
            r = 'absolute'; 
            s = 'last';
            eexp = 0.1;
            yexp = abs(y0-y1);
        case 4
            r = 'absolute'; 
            s = 'max';
            eexp = 0.1;
            yexp = abs(y0-y1);
        case 5
            r = 'relative'; 
            s = 'sum';
            eexp = (10*0.1)/sum(1:10);
            yexp = abs((y0-y1)./y0);
        case 6
            r = 'relative'; 
            s = 'mean';
            eexp = 0.1/5.5;
            yexp = abs((y0-y1)./y0);
        case 7
            r = 'relative'; 
            s = 'max';
            eexp = 0.1/1;
            yexp = abs((y0-y1)./y0);
        case 8
            r = 'relative'; 
            s = 'last';
            eexp = 0.1/10;
            yexp = abs((y0-y1)./y0);
        case 9
            r = 'relative'; 
            s = 'relmax';
            eexp = 0.1/10;
            yexp = abs((y0-y1)./y0);
        case 10   
            r = 'relative'; 
            s = '';             % check default case for s (should be 'max')
            eexp = 0.1/1;
            yexp = abs((y0-y1)./y0);
        case 11
            r = 'absolute'; 
            s = '';             % check default case for s (should be 'max')
            eexp = 0.1;
            yexp = abs(y0-y1);
        case 12
            r = '';             % check default case for r (should be 'absolute')
            s = '';             % check default case for s (should be 'max')
            eexp = 0.1;
            yexp = abs(y0-y1);
        otherwise
            error('case not defined')
    end     
    %% calculate the errors
    % error in the reference data 
    [e1, ye1] = calculate_verification_error(y0, y1, r, s);
    ee = abs(e1-eexp);
    ye = ye1-yexp;

    %% decide if verification is ok
    if ee > max_error       % calculated error is wrong
        v = false;
        s = sprintf('verification %s with reference FAILED for case %1.0f: error %3.3f > allowed error %3.3f', ...
            functionname, n, e1, max_error);
        show = true;
    elseif ye > max_error   % calculated error matrix is wrong
        v = false;
        s = sprintf('verification %s with reference FAILED for case %1.0f: error %3.3f > allowed error %3.3f', ...
            functionname, n, ye, max_error);
        show = true;
        disp(s) 
    else
        s = sprintf('%s case %1.0f OK: error %3.3f', functionname, n, e1);
    end

    % ------------ diplay and plot options if required ------------------------
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        sx = 'input y0';                    % x-axis label
        st = 'm-Function verification';     % title
        sy1 = 'y0 and y1';                  % y-axis label in the upper plot
        sy2 = 'calculated error';           % y-axis label in the lower plot
        % upper legend
        sleg1 = {'y0','y1'};
        % lower legend
        sleg2 = {'initial vs. current fn call'};
        %   x - vector with x values for the plot
        x = y0(:);
        %   y - matrix with y-values (reference values and result of the function call)
        y = [y0(:), y1(:)];
        %   ye - matrix with error values for each y-value
        ye = ye(:);
        sz = strrep(s,'_',' ');
        display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
    end
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
%  $Revision: 81 $
%  $Author: goettsche $
%  $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/weather_and_sun/airmass/verification/verify_airmass.m $
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version   Author Changes                                     Date
%  6.1.0     hf     created                                     22jan2017
%  6.1.1     hf     comments adapted to publish function        01nov2017
%  7.1.0     hf     added case 'relmax', include yexp           15apr2020
%                   enhance to 3-dimensional array
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
