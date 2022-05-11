%% Callback for Carnot block EU_Tapping_Cycle
%% Function Call
%  [t, q, dT, m] = CarnotCallbacks_EU_Tapping_Cycle(eu_tap, dTbias)
%% Inputs   
%  eu_tap : number of the tapping cycle (1 = 3XS, ... 10 = 4XL)
%  dTbias : bias temperature on setpoint temperature Tp in the tapping cycle
% 
%% Outputs
%  t    - profile of the setpoint temperature in °C
%  q    - profile of the energy to be tapped in J
%  dT   - 
%  m
% 
%% Description
%  Define the tapping profiles according to the european tapping cycle
%  definition.
% 
%% Literature
%  EN 13203
%  EN 16147
%  https://ec.europa.eu/energy/sites/ener/files/documents/guidelinesspacewaterheaters_final.pdf
% 
%% References
%  Function is used by: Carnot block EU_Tapping_Cycle

function [t, q, dT, m] = CarnotCallbacks_EU_Tapping_Cycle(eu_tap, dTbias)
% times in h, energies in kWh, massflow in kg/min
% will be transformed to s, J at kg/s the end
switch(eu_tap)
    case 1  % profile 3XS   0.345 kWh
        times_h = [7.000   7.083   7.250   7.433   7.500   9.000   9.500   11.50   11.75   12.00   12.50   12.75   14.50   15.00   15.50   16.00   18.50   19.00   19.50   21.25   21.50   21.58   21.75 ];
        Q_kWh   = [0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015 ];
        dTset_0 = [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30  ];
        mdot    = [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2   ];

    case 2  % profile XXS   2.1 kWh
        times_h = [7.000   7.500   8.500   9.500   11.50   11.75   12.00   12.50   12.75   18.00   18.25   18.50   19.00   19.50   20.00   20.75   21.00   21.25   21.58   21.75 ];
        Q_kWh   = [0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105 ];
        dTset_0 = [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30    ];
        mdot    = [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2     ];

    case 3  % profile XS    2.1 kWh
        times_h = [7.500   12.75   21.50   ];
        Q_kWh   = [0.525   0.525   1.05    ];
        dTset_0 = [30      30      30      ];
        mdot    = [3       3       3       ];
    
    case 4  % profile S     2.1 kWh
        times_h = [7.000   7.500   8.500   9.500   11.50   11.75   12.75   18.00   18.25   20.50   21.50   ];
        Q_kWh   = [0.105   0.105   0.105   0.105   0.105   0.105   0.315   0.105   0.105   0.420   0.525   ];
        dTset_0 = [30      30      30      30      30      30      45      30      30      45      30      ];
        mdot    = [3       3       3       3       3       3       4       3       3       4       5       ];
    
    case 5 % Profile M      5.845 kWh
        times_h = [7.000 7.083 7.500 8.016 8.250 8.5   8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.25 21.5];
        Q_kWh   = [0.105 1.4   0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 1.4 ];
        dTset_0 = [30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30  ];
        mdot   = [3     6     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     3     6   ];
        
    case 6 % profile L      11.655 kWh
        times_h = [7.000 7.083 7.500 7.750 8.083 8.416 8.500 8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.00 21.5 ];
        Q_kWh   = [0.105 1.4   0.105 0.105 3.605 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 3.605 0.105];
        dTset_0   = [30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30   ];
        mdot     = [3     6     3     3     10    3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3    ];
        
    case 7  % profile XL      19.07 kWh
        times_h = [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
        Q_kWh   = [0.105 1.82  0.105 4.42  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 4.420 0.105 4.42 ];
        dTset_0   = [30    30    30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    30    30    30    45    30    30    30   ];
        mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     3     3     3     4     10    3     10   ];
        
    case 8  % profile XXL      24.53 kWh
        times_h = [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
        Q_kWh   = [0.105 1.82  0.105 6.24  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 6.240 0.105 6.24 ];
        dTset_0   = [30    30    30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    30    30    30    45    30    30    30   ];
        mdot     = [3     6     3     16    3     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     3     3     3     4     16    3     16   ];
        
    case 9  % profile 3XL      46.76 kWh
        times_h = [7.00  8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
        Q_kWh   = [11.2  5.04  1.68  0.840 1.68  2.520 2.520 3.36  5.88  12.04];
        dTset_0   = [30    30    30    30    30    45    30    30    45    30   ];
        mdot     = [48    24    24    24    24    32    24    24    32    48   ];
        
    case 10 % profile 4XL      93.52 kWh
        times_h = [7.000 8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
        Q_kWh   = [22.40 10.08 3.36  1.680 3.360 5.04  5.04  6.72  11.76 24.08];
        dTset_0   = [30    30    30    30    30    45    30    30    45    30   ];
        mdot     = [96    48    48    48    48    64    48    48    64    96   ];
        
    otherwise
        disp('Wrong definition of tapping profile')
end
t  = times_h*3600;
q  = Q_kWh*36e5;
idxHigh = dTset_0 > 30;
idxLow =  ~idxHigh;
if length(dTbias)>1
    dT = dTset_0;
    dT(idxHigh) = dT(idxHigh) + dTbias(2);
    dT(idxLow) = dT(idxLow) + dTbias(1);
else
    dT = dTset_0 + dTbias(1);
end
m  = mdot/60;
end     % end of function 

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
%  VERSIONS
%  author list:     hf -> Bernd Hafner
%					pk -> Patrick Kefer			
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     00feb2020
%  7.1.1	pk		seperate bias temperature for 
%  					low(30°C) and high(45°C) deltaT				00jul2021
% *************************************************************************
% $Revision: 315 $
% $Author: carnot-hafner $
% $Date: 2017-10-19 21:46:26 +0200 (Do, 19 Okt 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_CondensingBoilerConf.m $
% *************************************************************************
