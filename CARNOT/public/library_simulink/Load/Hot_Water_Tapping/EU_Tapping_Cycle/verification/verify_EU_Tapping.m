%% verification of the EU_Tapping_Cycle block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_EU_Tapping(varargin)
%% Inputs
%  show - optional flag for display 
%         false : show results only if verification fails
%         true  : show results allways
%  save_sim_ref - optional flag to save new simulation reference
%         false : do not save a new reference simulation scenario
%         true  : save a new reference simulation scenario
%% Outputs
%  v - true if verification passed, false otherwise
%  s - text string with verification result
%% Description
%  verification of the EU_Tapping_Cycle block in the Carnot Toolbox
%                                                                          
%  Literature:   European Comission Mandate 324
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_EU_Tapping(varargin)
%% Calculations
% check input arguments
if nargin == 0
    show = false;
    save_sim_ref = false;
elseif nargin == 1
    show = logical(varargin{1});
    save_sim_ref = false;
elseif nargin == 2
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
else
    error('verify_EU_Tapping:%s',' too many input arguments')
end

%% set your specific model or function parameters here
% set error tolerances
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'EU tapping';
modelfile = 'verify_EU_Tapping_mdl';
load_system(modelfile)
Tcold = 10;             % cold water temperature

for n = 1:10        % loop over all tapping cycles
    %% definition of EU tapping cycles
    % times in h, energies in kWh, massflow in kg/min
    switch(n)
        case 1  % profile 3XS   0.345 kWh
            ptxt = '3XS';
            max_error =  0.015;    % max error between simulation and reference
            times =    [7.000   7.083   7.250   7.433   7.500   9.000   9.500   11.50   11.75   12.00   12.50   12.75   14.50   15.00   15.50   16.00   18.50   19.00   19.50   21.25   21.50   21.58   21.75 ];
            energies = [0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015 ];
            dT_set =   [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30  ];
            mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2   ];
    
        case 2  % profile XXS   2.1 kWh
            ptxt = 'XXS';
            max_error =  0.015;    % max error between simulation and reference
            times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.00   12.50   12.75   18.00   18.25   18.50   19.00   19.50   20.00   20.75   21.00   21.25   21.58   21.75 ];
            energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105 ];
            dT_set =   [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30    ];
            mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2     ];
    
        case 3  % profile XS    2.1 kWh
            ptxt = 'XS';
            max_error =  0.02;    % max error between simulation and reference
            times =    [7.500   12.75   21.50   ];
            energies = [0.525   0.525   1.05    ];
            dT_set =   [30      30      30      ];
            mdot =     [3       3       3       ];
        
        case 4  % profile S     2.1 kWh
            ptxt = 'S';
            max_error =  0.035;    % max error between simulation and reference
            times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.75   18.00   18.25   20.50   21.50   ];
            energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.315   0.105   0.105   0.420   0.525   ];
            dT_set =   [30      30      30      30      30      30      45      30      30      45      30      ];
            mdot =     [3       3       3       3       3       3       4       3       3       4       5       ];
        
        case 5 % Profile M      5.845 kWh
            ptxt = 'M';
            max_error =  0.035;    % max error between simulation and reference
            times =    [7.000 7.083 7.500 8.016 8.250 8.5   8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.25 21.5];
            energies = [0.105 1.4   0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 1.4 ];
            dT_set =   [30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30  ];
            mdot   =   [3     6     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     3     6   ];
            
        case 6 % profile L      11.655 kWh
            ptxt = 'L';
            max_error =  0.035;    % max error between simulation and reference
            times =    [7.000 7.083 7.500 7.750 8.083 8.416 8.500 8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.00 21.5 ];
            energies = [0.105 1.4   0.105 0.105 3.605 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 3.605 0.105];
            dT_set   = [30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30   ];
            mdot     = [3     6     3     3     10    3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3    ];
            
        case 7  % profile XL      19.07 kWh
            ptxt = 'XL';
            max_error =  0.04;    % max error between simulation and reference
            times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
            energies = [0.105 1.82  0.105 4.42  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 4.420 0.105 4.42 ];
            dT_set   = [30    30    30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    30    30    30    45    30    30    30   ];
            mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     3     3     3     4     10    3     10   ];
            
        case 8  % profile XXL      24.53 kWh
            ptxt = 'XXL';
            max_error =  0.07;    % max error between simulation and reference
            times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
            energies = [0.105 1.82  0.105 6.24  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 6.240 0.105 6.24 ];
            dT_set   = [30    30    30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    30    30    30    45    30    30    30   ];
            mdot     = [3     6     3     16    3     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     3     3     3     4     16    3     16   ];
            
        case 9  % profile 3XL      46.76 kWh
            ptxt = '3XL';
            max_error =  0.3;    % max error between simulation and reference
            times =    [7.00  8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
            energies = [11.2  5.04  1.68  0.840 1.68  2.520 2.520 3.36  5.88  12.04];
            dT_set   = [30    30    30    30    30    45    30    30    45    30   ];
            mdot     = [48    24    24    24    24    32    24    24    32    48   ];
            
        case 10 % profile 4XL      93.52 kWh
            ptxt = '4XL';
            max_error =  0.6;    % max error between simulation and reference
            times =    [7.000 8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
            energies = [22.40 10.08 3.36  1.680 3.360 5.04  5.04  6.72  11.76 24.08];
            dT_set   = [30    30    30    30    30    45    30    30    45    30   ];
            mdot     = [96    48    48    48    48    64    48    48    64    96   ];
            
        otherwise
            disp('Wrong definition of tapping profile')
    end
    t0 = [0, times*3600+10, 24*3600]';
  
    %% simulate the model or call the function
    set_param([modelfile, '/EU_Tapping_Cycle'],'eu_tap',ptxt);
    % maskStr = get_param([modelfile, '/EU_Tapping_Cycle'],'eu_tap');
    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    rr = simOut.get('yout');
    tt = simOut.get('tout');
    yy = timeseries(rr,tt);
    yy = resample(yy,t0);
    y2 = yy.data;

    %% set the reference values
    Qref = [0, 0, cumsum(energies)]';
    t1 = [0, times*3600, 24*3600]';
    yy = timeseries(Qref, t1);
    yy = resample(yy, t0);
    Tref = [0, dT_set, 0]' + Tcold;
    mref = [0, mdot, 0]';
    y0 = [yy.data, mref, Tref];
    % set reference values initial simulation 
    if (save_sim_ref)
        y1 = y2;   % determinded data
        save(['simRef_EUtapping_' num2str(n) '.mat'],'y1');
    else
        y1 = importdata(['simRef_EUtapping_' num2str(n) '.mat']);  % result from call at creation of function
    end
    
    % ----------------- set the literature reference values -------------------
    %      {'3XS', 'XXS', 'XS', 'S', 'M',   'L',    'XL',  'XXL', '3XL', '4XL'};
    y0s =  [0.345, 2.1,   2.1,  2.1, 5.845, 11.655, 19.07, 24.53, 46.76, 93.52];
    
    %% -------- calculate the errors -------------------------------------------
    c1 = 'absolute';
    c2 = 'max';
    % error between reference and initial simu
    [e1, ye1] = calculate_verification_error(y0, y1, c1, c2);
    % error between reference and current simu
    [e2, ye2] = calculate_verification_error(y0, y2, c1, c2);
    % error between initial and current simu
    [e3, ye3] = calculate_verification_error(y1, y2, c2, c2);
    
    % ------------- decide if verification is ok --------------------------------
    if abs(y0s(n)-y0(end,1)) > max_simu_error
        v = false;
        s = sprintf('verification %s %s of REFERENCE FAILED: error %3.5f > allowed error %3.5f', ...
            functionname, ptxt, abs(y0s(n)-y0(:,1)), max_error);
        show = true;
    elseif e2 > max_error
        v = false;
        s = sprintf('verification %s %s with reference FAILED: error %3.5f > allowed error %3.5f', ...
            functionname, ptxt, e2, max_error);
        show = true;
    elseif e3 > max_simu_error
        v = false;
        s = sprintf('verification %s %s with 1st calculation FAILED: error %3.5f > allowed error %3.5f', ...
            functionname, ptxt, e3, max_simu_error);
        show = true;
    else
        v = true;
        s = sprintf('%s OK: error %3.5f', functionname, e2);
    end
    
    % diplay and plot options if required
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        sx = 'time in h';               % x-axis label
        st = [ptxt, ': Q(1),Mdot(2), T(3)'];     % title
        sy1 = 'Data';                   % y-axis label in the upper plot
        sy2 = 'error';         % y-axis label in the lower plot
        % upper legend
        sleg1 = {'reference data','initial simulation','current simulation'};
        % lower legend
        sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
        %   x - vector with x values for the plot
        x = t0/3600;
        %   y - matrix with y-values (reference values and result of the function call)
        y = [y0, y1, y2];
        %   ye - matrix with error values for each y-value
        ye = [ye1, ye2, ye3];
        display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
    end
end
close_system(modelfile, 0)   % close system, but do not save it


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
%  $Revision$
%  $Author$
%  $Date$
%  $HeadURL$
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     10feb2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    hf      filename validate_ replaced by verify_      09jan2015
%  6.2.2    hf      close system without saving it              16may2016
%  6.3.0    hf      comments adapted to publish function        01nov2017
%                   added save_sim_ref as 2nd input argument
%  7.1.0    hf      corrected flowrates for XL, XXL, 3XL, 4XL   02feb2020
%  7.1.1    hf      replaced set_param command                  09feb2020
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *