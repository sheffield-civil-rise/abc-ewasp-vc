%% standardized calculation of heat exchangers according to VDI equations 
%  Syntax:       
%  P = VDIHeatExchanger_GEB(abcd,R,NTU)
%  Gleichung zur Einheitlichen Berechnung von Wärmetauschern nach
%  VDI-Wärmeatlas C1 3.4
% 
%  Input:       abcd,R,NTU
%                   
%  Output:      P
%                                                                          
%  Remarks: 
% 
%  function is used by: --
%  this function calls: -
% 
%  Literature:
%  VDI Waermeatlas, 2019

function P = VDIHeatExchanger_GEB(abcd,R,NTU)

a=abcd(1,1);
b=abcd(1,2);
c=abcd(1,3);
d=abcd(1,4);

F=1./((1+a*R.^(d*b).*NTU.^b).^c);
E=(R-1).*NTU.*F;
P=(1-exp(E))./(1-R.*exp(E));
[rows,cols,~] = find(R==1); 
for i=1:size(rows)
    P(rows(i),cols(i))=NTU(rows(i),cols(i))*F(rows(i),cols(i))/(1+NTU(rows(i),cols(i))*F(rows(i),cols(i)));
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
%  7.1.0    k       created as GEB.m                            01sep2021
%  7.1.1    hf      renamed to VDIHeatExchanger_GEB             18sep2021