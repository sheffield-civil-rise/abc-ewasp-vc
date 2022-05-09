%% Callback for Carnot model HeatPump_CONF
%% Function Call
%  ok = CarnotCallbacks_ModelDoc()
%% Inputs
%  none
%% Outputs
%  ok - true if writing of parameters was successfull, false otherwise
% 
%% Description
%  Search for the parameterfile in the folders parameter_set of the model
%  and load the parameter set. The function is used by the mask of the
%  Carnot Simlink block.
% 
%% References and Literature
%  Function is used by: Simulink block Condensing_Boiler_CONF
%  Function calls: CarnotCallbacks_loadConfParameters.m
%  see also CarnotCallbacks_loadConfParameters, CarnotCallbacks_getConfNamelist

function ok = CarnotCallbacks_ModelDoc()
%% Calculations
ok = true;
if ~BlockIsInCarnotLibrary
    modelname = bdroot;
    filename = [modelname '_params.txt'];
    fid = fopen(filename, 'w');
    ttt = SearchWriteParams(modelname,fid);
    fclose(fid);

    if ttt == 0
        ok = false;
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
%  author list:     hf -> Bernd Hafner
%                   jg -> Joachimg Goettsche
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    jg      created                                     around2016
%  6.1.1    hf      converted to callback                       23oct2017
% *************************************************************************
% $Revision: 1 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_CondensingBoilerConf.m $
% *************************************************************************
