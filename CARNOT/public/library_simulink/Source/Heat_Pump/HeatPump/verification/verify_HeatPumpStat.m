%% verification of the HeatPump block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_HeatPumpStat(varargin)
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
%  verification of the HeatPump block in the Carnot Toolbox by comparing
%  the simlation result with an initial simulation and the data sheet
%  values of the Vitocal 300-G BW106 to 117
%                                                                          
%  Literature:   --
%  see also template_verify_mFunction, template_verify_SimulinkBlock, verification_carnot

function [v, s] = verify_HeatPumpStat(varargin)
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
    error('verify_HeatPumpStat:%s',' too many input arguments')
end
% set error tolerances
% max_error is separated in [thermal_cold_side thermal_warm_side electric]
max_simu_error = [1 1 1]*1e-5;  % max error between initial and current simu
v = true;
functionname = 'verify_HeatPumpStat_mdl'; % model file
% filenames with the parameter sets to check
filename = {'Vitocal300G_BW106.mat','Vitocal300G_BW108.mat', ...
    'Vitocal300G_BW110.mat','Vitocal300G_BW113.mat','Vitocal300G_BW117.mat', ...
    'Vitocal300G_bw301A21.mat','Vitocal300G_bw301A29.mat', ...
    'Vitocal300G_bw301A45.mat','Vitocal300G_bw301B06.mat', ...
    'Vitocal300G_bw301B08.mat','Vitocal300G_bw301B10.mat', ...
    'Vitocal300G_bw301B13.mat','Vitocal300G_bw301B17.mat', ...
    'Vitocal300G_bw302DS090.mat','Vitocal300G_bw302DS110.mat', ...
    'Vitocal300G_bw302DS140.mat','Vitocal300G_bw302DS180.mat', ...
    'Vitocal300G_bw302DS230.mat'};
% simulate the model or call the function
load_system(functionname)
y2 = zeros(4,3);
y0 = y2;
for k = 1:length(filename)
    max_error = [0.05 0.05 0.07];   % max error between simulation and reference
    set_param([functionname, '/HeatPump'],'FileName',mat2str(filename{k}));
    % set the reference values (data sheet values of Vitocal)
    switch filename{k}
        case 'Vitocal300G_BW106.mat'          % BW106: 
            Qdoth = [5940 5460; 8670 7910];  
            Qdotc = [4710 3410; 7500 5990];
            Pel = [1320 2210; 1270 2070]; 
            Thout = [35 55]; 
            Tcin = [0 15];
        case 'Vitocal300G_BW108.mat'          % BW108: 
            Qdoth = [7850 7100; 11500 10300]; 
            Qdotc = [6300 4600; 9950 7850];
            Pel = [1720 2690; 1670 2600]; 
            Thout = [35 55]; 
            Tcin = [0 15];
        case 'Vitocal300G_BW110.mat'          % BW110: 
            Qdoth = [10000 9100; 14800 13300];
            Qdotc = [8050 6050; 12950 10350];
            Pel = [2100 3300; 2000 3200]; 
            Thout = [35 55]; 
            Tcin = [0 15];
        case 'Vitocal300G_BW113.mat'          % BW113: 
            Qdoth = [13150 12250; 19150 17450];
            Qdotc = [10500 8000; 16600 13300];
            Pel = [2800 4550; 2700 4400]; 
            Thout = [35 55]; 
            Tcin = [0 15];
        case 'Vitocal300G_BW117.mat'          % BW 117: 
            Qdoth = [14300 13000; 24100 22300];
            Qdotc = [11000 8400; 20400 17000];
            Pel = [3800 5100; 4200 6000];
            Thout = [35 55]; 
            Tcin = [-5 15];
        case 'Vitocal300G_bw301A21.mat'
            Thout = [35 55];
            Tcin = [2 15];
            % Ts_out    35    55 °C
            Qdoth = [22580 20410; ...   % Tp_in = 2°C
                     32150 28320];      % Tp_in = 15°C
            Qdotc = [18340 14070; ...   % Tp_in = 2°C
                     27950 21970];      % Tp_in = 15°C
            Pel   = [ 4530  6820; ...   % Tp_in = 2°C
                      4570  6830];      % Tp_in = 15°C
        case 'Vitocal300G_bw301A29.mat'
            % power matrix from data sheet
            Thout = [35 55];
            Tcin = [2 15];
            % Ts_out    35    55  °C
            Qdoth = [30460  27700; ...   % Tp_in = 2°C  
                     44180  38060];      % Tp_in = 15°C
            Qdotc = [24920  18670; ...   % Tp_in = 2°C  
                     38310  29340];      % Tp_in = 15°C
            Pel   = [ 6010   9700; ...   % Tp_in = 2°C  
                      6310   9380];      % Tp_in = 15°C
            max_error = [0.06 0.04 0.04];   % max error between simulation and reference
        case 'Vitocal300G_bw301A45.mat'
            Thout = [35 55];
            Tcin = [2 15];
            % Ts_out    35    55  °C
            Qdoth = [46200  40230 ; ...   % Tp_in = 2°C
                     66050  55000 ];      % Tp_in = 15°C
            Qdotc = [37140  26920 ; ...   % Tp_in = 2°C
                     56590  41760 ];      % Tp_in = 15°C
            Pel   = [ 9560  14330 ; ...   % Tp_in = 2°C
                     10170  14230 ];      % Tp_in = 15°C
        case 'Vitocal300G_bw301B06.mat'
            %  Thout 35 °C  55 °C
            Qdoth = [4950,  4470; ...   % Tcin = -5°C
                7510,  6890];           % Tcin = 10°C
            Qdotc = [3800,  2690; ...   % Tcin = -5°C
                6350,  5120];           % Tcin = 10°C
            Pel =   [1240,  1920; ...   % Tcin = -5°C
                1240,  1900];           % Tcin = 10°C
            Thout = [35 55];
            Tcin = [-5 10];
            max_error = [0.12 0.10 0.05];   % max error between simulation and reference
        case 'Vitocal300G_bw301B08.mat'
            %  Thout 35 °C  55 °C
            Qdoth = [6680,  6210; ...   % Tcin = -5°C
                    10180,  9250];      % Tcin = 10°C
            Qdotc = [5180,  3740; ...   % Tcin = -5°C
                     8740,  6910];      % Tcin = 10°C
            Pel =   [1550,  2660; ...   % Tcin = -5°C
                     1550,  2520];      % Tcin = 10°C
            Thout = [35 55];
            Tcin = [-5 10];
            max_error = [0.12 0.08 0.04];   % max error between simulation and reference
        case 'Vitocal300G_bw301B10.mat'
            %  Thout 35 °C  55 °C
            Qdoth = [9020,  8280; ...   % Tcin = -5°C
                13510, 12280];          % Tcin = 10°C
            Qdotc = [7010,  5180; ...   % Tcin = -5°C
                11600,  9290];          % Tcin = 10°C
            Pel =   [2060,  3330; ...   % Tcin = -5°C
                2050,  3220];           % Tcin = 10°C
            Thout = [35 55];
            Tcin = [-5 10];
            max_error = [0.12 0.08 0.04];   % max error between simulation and reference
        case 'Vitocal300G_bw301B13.mat'
            %  Thout 35 °C  55 °C
            Qdoth = [11230, 10460; ...  % Tcin = -5°C
                     16890, 15460];     % Tcin = 10°C
            Qdotc = [8820,  6620; ...   % Tcin = -5°C
                    14460, 11680];      % Tcin = 10°C
            Pel =   [2590,  4140; ...   % Tcin = -5°C
                    2610,  4060];       % Tcin = 10°C
            Thout = [35 55];
            Tcin = [-5 10];
            max_error = [0.15 0.10 0.04];   % max error between simulation and reference
        case 'Vitocal300G_bw301B17.mat'
            %  Thout 35 °C  55 °C
            Qdoth = [15190, 14100; ...  % Tcin = -5°C
                    22590, 20690];      % Tcin = 10°C
            Qdotc = [11870,  8890; ...  % Tcin = -5°C
                    19170, 15400];      % Tcin = 10°C
            Pel =   [3280,  5600; ...   % Tcin = -5°C
                    3680,  5690];       % Tcin = 10°C
            Thout = [35 55];
            Tcin = [-5 10];
            max_error = [0.15 0.10 0.04];   % max error between simulation and reference
        case 'Vitocal300G_bw302DS090.mat'
            Thout = [35 55];
            Tcin = [5 15];
            % Ts_out   35     55 °C
            Qdoth = [95700   87200; ... % Tp_in = 5°C
                    125900  108800];    % Tp_in = 15°C
            Qdotc = [78000   62100; ... % Tp_in = 5°C
                    107800   82700];    % Tp_in = 15°C
            Pel   = [18810   26730; ... % Tp_in = 5°C
                     19270   27630];    % Tp_in = 15°C
        case 'Vitocal300G_bw302DS110.mat'
            Thout = [35 55];
            Tcin = [5 15];
            % Ts_out   35     55 °C
            Qdoth = [124100  112400; ...    % Tp_in = 5°C
                     164700  141800];       % Tp_in = 15°C
            Qdotc = [101300   79600; ...    % Tp_in = 5°C
                    141100   107800];       % Tp_in = 15°C
            Pel   = [24420    34820; ...    % Tp_in = 5°C
                     25120    36020];       % Tp_in = 15°C
        case 'Vitocal300G_bw302DS140.mat'
            Thout = [35 55];
            Tcin = [5 15];
            % Ts_out   35     55 °C
            Qdoth = [153500  138200; ...    % Tp_in = 5°C
                     202700  174000];       % Tp_in = 15°C
            Qdotc = [124400   96800; ...    % Tp_in = 5°C
                     173200  131200];       % Tp_in = 15°C
            Pel   = [31300    43810; ...    % Tp_in = 5°C
                     32000    45210];       % Tp_in = 15°C
        case 'Vitocal300G_bw302DS180.mat'
            Thout = [35 55];
            Tcin = [5 15];
            % Ts_out   35     55 °C
            Qdoth = [206100  187200; ...    % Tp_in = 5°C
                     267100  239000];       % Tp_in = 15°C
            Qdotc = [168500  132500; ...    % Tp_in = 5°C
                     228700  184100];       % Tp_in = 15°C
            Pel   = [ 40030   58050; ...    % Tp_in = 5°C
                      40830   58250];       % Tp_in = 15°C
        case 'Vitocal300G_bw302DS230.mat'
            Thout = [35 55];
            Tcin = [5 15];
            % Ts_out   35     55 °C
            Qdoth = [258200  239100; ...    % Tp_in = 5°C
                     341200  311100];       % Tp_in = 15°C
            Qdotc = [211700  172100; ...    % Tp_in = 5°C
                     291700  242700];       % Tp_in = 15°C
            Pel   = [49500    71320; ...    % Tp_in = 5°C
                     52500    73120];       % Tp_in = 15°C
    end
    for m = 1:length(Thout)
        set_param([functionname, '/THBsink'],'t',num2str(Thout(m)-5));
        for n = 1:length(Tcin)
            mdotc = Qdotc(n,m)/3900/3;   % massflow cold side
            set_param([functionname, '/THBsource'],'t',num2str(Tcin(n)));
            set_param([functionname, '/THBsource'],'mdot',num2str(mdotc));
            mdoth = Qdoth(n,m)/4182/5;   % massflow hot side
            set_param([functionname, '/THBsink'],'mdot',num2str(mdoth));
            % run simulation
            simOut = sim(functionname, 'SrcWorkspace','current', ...
                'SaveOutput','on','OutputSaveName','yout');
            yy = simOut.get('yout');  % get the whole output vector
            % result is the last value of the simulation
            y2(2*(m-1)+n,:) = yy(end,3:end);
            % reference
            y0(2*(m-1)+n,:) = [Qdotc(n,m),Qdoth(n,m),Pel(n,m)];
        end
    end
    % set reference values initial simulation
    % result from call at creation of function if required it can be determined
    % from the simulation result
    reffile = ['simRef_HpStat' filename{k}];
    if (save_sim_ref)
        y1 = y2;                  % determinded data
        save(reffile,'y2');
    else
        y1 = importdata(reffile); % result from call at creation of function
    end
    % -------- calculate the errors ---------------------------------------
    % error between reference and initial simu
    ye1 = abs(y0-y1)./y0;
    e1 = max(ye1);
    % error between reference and current simu
    ye2 = abs(y0-y2)./y0;
    e2 = max(ye2);
    % error between initial and current simu
    ye3 = abs(y1-y2)./y1;
    e3 = max(ye3);
    % ------------- decide if verification is ok --------------------------
    if any(e2 > max_error)
        v = false;
        s = sprintf(['verification %s with reference FAILED: error ' ...
            '%3.3g %3.3g %3.3g > allowed error %3.3g  %3.3g  %3.3g'], ...
            functionname, e2, max_error);
        show = true;
    elseif any(e3 > max_simu_error)
        v = false;
        s = sprintf(['verification %s with 1st calculation FAILED: error' ...
            '%3.3g %3.3g %3.3g > allowed error %3.3g %3.3g %3.3g'], ...
            functionname, e3, max_simu_error);
        show = true;
    else
        s = sprintf('%s OK: error %3.3g', functionname, e2);
    end
    % ------------ display and plot results if required -------------------
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        sx = 'simulation run';                             % x-axis label
        sleg = {'Qdot cold','Qdot hot','P elec'};
        st = ['reference vs. current sim ' strrep(filename{k},'_','')]; % title
        figure
        subplot(3,1,1)      % divide in subplots (lower and upper one)
        bar(y0)
        title(st)
        ylabel('Reference Power in W')
        subplot(3,1,2)      % divide in subplots (lower and upper one)
        bar(y2)
        ylabel('Current Sim Power in W')
        legend(sleg,'Location','best')
        sz = strrep(s,'_',' ');
        text(0,-0.2,sz,'Units','normalized')  % display valiation text
        subplot(3,1,3)      % choose lower window
        bar(ye2)
        xlabel(sx)
        ylabel('relative error')
    end
end
close_system(functionname, 0)   % close system, but do not save it

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
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  7.1.0    hf      created                                     08mar2022
%  7.1.1    hf      seperate error tolerances thermal, electric 10mar2022
%  7.2.0    hf      added Vitocal parameter files               10mar2022
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
