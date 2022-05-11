%% parameter identification skript for the VDI Heat Exchanger model 
%  Syntax:       
%  VDI_HeatExchanger_findabcd
% 
%  Input:       (none) - Matlab-skrip, no function
%                   
%  Output:      X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT
%                                                                          
%  Remarks: 
% 
%  function is used by: --
%  this function calls: -
% 
%  Literature: --

if exist('lsqcurvefit')  %#ok<EXIST> % use the optimization toolbox function
    OPTIONS = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective');
    [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqcurvefit(@(abcd,R)VDIHeatExchanger_GEB(abcd,R,NTU),[0.433 1.63 0.267 0.5],R,P,[],[],OPTIONS);
else                     % toolbox is not installed, use fminsearch
    X = fminsearch(@(abcd,R)VDIHeatExchanger_GEB(abcd,R,NTU),[0.433 1.63 0.267 0.5],R,P,[],[]);
end
    


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
%  D O C U M E N T A T I O N
%  author list:     k  -> Kerstin Oetringer
%                   hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Ver.     Author  Changes                                     Date
%  7.1.0    k       created findabsd.m                          01sep2021
%  7.1.1    hf      renamed to VDIHeatExchanger_findabcd        18sep2021
%                   added fminsearch option 
