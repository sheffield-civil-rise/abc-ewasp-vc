% CarnotCallbacks_WindowWithShading is a callback for the Window_with_Shading model
% Inputs:       -
% Outputs:      ok : true if callback was successfull
% Syntax:       CarnotCallbacks_WindowWithShading
%                                                                          
% Function Calls:
% 
% Literature:   -

function ok = CarnotCallbacks_WindowWithShading()

ok = true;
h = get(gcbh);
switch h.shad_type
    case 'No shading' % nr. 1 no shading
        set_param(gcb,'MaskVisibilities',{'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
            'on';'off';'off';'off';'off';'off';'off';'off'});
    case 'Exterior Screen' % nr. 2 external screen
        set_param(gcb,'MaskVisibilities',{'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'off';'off';'off';'off';'off';'off'});
    case 'Interior Screen' % nr. 3 Interior Screen
        set_param(gcb,'MaskVisibilities',{'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'off';'off';'off';'off';'off';'off'});
    case 'Venetian Blind' % nr. 4 venetian blind
        set_param(gcb,'MaskVisibilities',{'on';'on';'on';'on';'on';'on'; ...
            'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
            'on';'off';'on';'on';'on';'on';'on';'on'});
    otherwise
        ok = false;
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
% $Revision: 1 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_GetFiles.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% author list:     hf -> Bernd Hafner
%                  rd -> Ralf Dott
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created on base of the mask callback        28nov2017
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
