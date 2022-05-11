%% calculate_verification_error of the verification of a function or model
%  [e ye] = calculate_verification_error(yref, ysim, r, s)
%  Description
%  Calculates the error as a difference of the columns in yref and ysim.
%  For more than one column or page of yref and ysim the error is the
%  maximum of the error of each column.
%  Inputs:  
%  yref -  reference ('correct') values for the result of the function
%  ysim -  simulated or calculated results of the function
%  r    -  'relative' error or 'absolute' error
%  s    -  'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim
%          'relmax' - e is the error relative to the maximum in reference
%               (relmax is only available for 'relative' error calculation)
%  Outputs:
%  e   - scalar error (absolute or relative error over the total dataset)
%  ye  - individual error (absolute or relative) of each value in y
% 
%  The function is used by: verify_<BlockNameOrFunctionName>
%  This function calls: --
% 
%  Literature: --

function [e, ye] = calculate_verification_error(yref, ysim, r, s)
if size(ysim) ~= size(yref)
    error('calculate_verification_error: parameters yref and ysim must have same size')
end

%% calculate the error
% the base of the error calculation is the difference of sim and ref
ye = ysim-yref;

if (strcmp(r,'relative'))           % if relative error is wanted
    d = yref;                       % denominator are the columns in yref
    switch s
        case 'sum'                  % error is sum of individual errors
            % result is sum of the absolute values
            e = max(sum(abs(ye))./sum(yref),[],'all');
        case 'mean'                 % 'mean' error calculation
            % error is mean of absolute individual values
            e = max(mean(abs(ye))./mean(yref),[],'all');
        case 'max'                  % 'max' error calculation
            % error is maximum of absolute individual values
            e = max(abs(ye./yref),[],'all');
        case 'last'                 % 'last' error calculation
            % error is from the last values
            e = max(abs(ye(end,:,:)./yref(end,:,:)),[],'all');
        case 'relmax'               % 'relmax' error calculation
            d = max(abs(yref));     % new denominator: maximum of absolute of all values
            % error is maximum of absolute values relative to maximum in reference
            e = max(abs(ye./d),[],'all');
        otherwise                   % default error calculation
            % error is maximum of absolute individual values
            e = max(abs(ye./yref),[],'all');
    end
    ye = ye./d;                     % relative error is difference of sim and ref / ref
else                                % else: absolute error
    switch s
        case 'sum'                  % error is sum of individual errors
            % result is sum of the absolute values
            e = max(sum(abs(ye)),[],'all');      
        case 'mean'                 % 'mean' error calculation
            % error is mean of absolute individual values
            e = max(mean(abs(ye)),[],'all');     
        case 'max'                  % 'max' error calculation
            % error is maximum of absolute individual values
            e = max(abs(ye),[],'all');     
        case 'last'                 % 'last' error calculation
            % error is from the last values
            e = max(abs(ye(end)),[],'all');   
        otherwise                   % default error calculation
            % error is maximum of absolute individual values
            e = max(abs(ye),[],'all'); 
    end
end


%% Copyright and Versions
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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                       Date
% 6.1.0     hf      created                                       17nov2013
% 6.1.1     hf      'max' error calculation integrated            04oct2014
% 6.2.0     hf      'last' integrated, changed it to switch       15dec2014
% 6.2.1     hf      name verification_ replaced by verification   09jan2015
% 6.2.2     hf      separate arguments of function call by comma  28jul2015
% 6.3.0     hf      revised calculation of relative errors        28sep2017
% 7.1.0     hf      added relative case 'relmax'                  03feb2020
% 7.1.1     hf      always set d = yref for relative error        01mar2020
% 7.1.2     hf      relmax takes the abs of max for denominator   27mar2021
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
