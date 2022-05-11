%% verification of the Ground_Source_Heat_Exchanger block in the Carnot Toolbox
%% Function Call
%  [v, s] = verify_Ground_Source_Heat_Exchanger(varargin)
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
%  Verification of the Ground_Source_Heat_Exchanger block in the Carnot 
%  Toolbox by comparing the results with the initial simulation and
%  literature values from Huber, Pahud (1999).
%                                                                          
%  Literature
%  Huber, A.; Pahud, D. (1999): 
%       Erweiterung des Programms EWS für Erdwärmesondenfelder,
%       Forschungsprogramm Umgebungs- und Abwärme, Wärme-Kraft-Kopplung (UAW) 
%       im Auftrag des Bundesamtes für Energie (Schweiz)
%       http://www.hetag.ch/download/HU_EWS2_SB.pdf (accessed 10/04/2021)
% 
%  see also CarnotCallbacks_EWS, verification_carnot

function [v, s] = verify_Ground_Source_Heat_Exchanger(varargin)
%% check input arguments
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
    error('verify_Ground_Source_Heat_Exchanger:%s',' too many input arguments')
end

%% set model parameters
%  error tolerances
max_error = 1;          % max error between simulation and reference
max_simu_error = 1e-5;  % max error between initial and current simu
%  set model file or function name
functionname = 'verify_Ground_Source_Heat_Exchanger_mdl';
%  reference runs from Huber, Pahud (1999)
HuberPahud = {'1', '10', '17'};

%% simulate the model
load_system(functionname)

% simulate only the run 17, parameter settings of the model have to be adapted to other cases
for n = 3:3   
    % set the literature reference values
    [t0, y0] = setReferenceData(HuberPahud(n));

    % run simulation
    simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    yy = simOut.get('yout');        % get the whole output vector
    tt = simOut.get('tout');        % get the whole time vector from simu
    tsy = timeseries(yy,tt);        % timeseries for the columns
    tx = resample(tsy,t0);          % resample with t0
    y2 = tx.data;
    close_system(functionname, 0)   % close system, but do not save it
    
    % set reference values initial simulation
    % result from call at creation of function 
    % (if required it can be determined from the simulation result)
    if (save_sim_ref)
        y1 = y2;   % simulated data
        save(['simRef_GroundSourceHeatExchanger' HuberPahud{n} '.mat'],'y2');
    else
        % result from call at creation of function
        y1 = importdata(['simRef_GroundSourceHeatExchanger' HuberPahud{n} '.mat']);
    end
    
    %% calculate the errors
    %   r    - 'relative' error or 'absolute' error
    %   s    - 'sum' - e is the sum of the individual errors of ysim
    %          'mean' - e is the mean of the individual errors of ysim
    %          'max' - e is the maximum of the individual errors of ysim
    r = 'absolute';
    % r = 'relative';
    % s = 'max';
    % s = 'sum';
    s = 'mean';
    
    % error between reference and initial simu
    [e1, ye1] = calculate_verification_error(y0, y1, r, s);
    % error between reference and current simu
    [e2, ye2] = calculate_verification_error(y0, y2, r, s);
    % error between initial and current simu
    [e3, ye3] = calculate_verification_error(y1, y2, r, s);
    
    % ------------- decide if verification is ok ------------------------------
    if e2 > max_error
        v = false;
        s = sprintf('verification %s with reference FAILED: error %3.3g > allowed error %3.3g', ...
            functionname, e2, max_error);
        show = true;
    elseif e3 > max_simu_error
        v = false;
        s = sprintf('verification %s with 1st calculation FAILED: error %3.3g > allowed error %3.3g', ...
            functionname, e3, max_simu_error);
        show = true;
    else
        v = true;
        s = sprintf('%s OK: error %3.3g', functionname, e2);
    end
    
    %% display and plot results if required 
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        st = 'Simulink block verification';     % title
        sx = '';                                % x-axis label
        % upper legend
        sleg1 = {'reference data','initial simulation','current simulation'};
        % lower legend
        sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
        %   y - matrix with y-values (reference values and result of the function call)
        y_T    = [y0(:,1), y1(:,1), y2(:,1)];
        %   x - vector with x values for the plot
        x = t0;
        %   ye - matrix with error values for each y-value
        ye_T    = [ye1(:,1), ye2(:,1), ye3(:,1)];
        sz = strrep(s,'_',' ');
        
        % Combining plots 
        figure              % open a new figure
        % Temperature plots
        subplot(2,1,1)      % divide in subplots (lower and upper one)
        if size(y_T,2) == 3
            plot(x,y_T(:,1),'x',x,y_T(:,2),'o',x,y_T(:,3),'-')
        else
            plot(x,y_T,'-')
        end
        title(st)
        ylabel('Temperature in °C')
        legend(sleg1,'Location','best')
        text(0,-0.2,sz,'Units','normalized')  % display valiation text
        
        subplot(2,1,2)      % choose lower window
        if size(ye_T,2) == 3
            plot(x,ye_T(:,1),'x',x,ye_T(:,2),'o',x,ye_T(:,3),'-')
        else
            plot(x,ye_T,'-')
        end
        legend(sleg2,'Location','best')
        xlabel(sx)
        ylabel('Difference in °C')
    end
end
end % end of function

function [t0, y0] = setReferenceData(hp)
% test run data is converted with http://www.graphreader.com/
% from (Huber, Pahud 1999)

switch char(hp)
    case '1'        % run 1
        % 1300,  -3.464
        % 13700, -4.397
        % 37957,-4.598
        % 88566,-4.726
        % 176078,-4.789
        % 263590,-4.799
        % 350575,-4.809
        % 438087,-4.813
        % 525336,-4.809
        t0 = [0 1300 38000 87600 175200 262800]*3600;
        y0 = [0 -3.4 -4.6  -4.7  -4.79  -4.8];
        
    case '10'       % run 10
        % 43844.557,-13.227
        % 87689.115,-15.93
        % 131533.672,-17.202
        % 175110.885,-17.901
        % 218955.443,-18.315
        % 262933.672,-18.601
        t0 = [0 43800 87600 131400 175200 219000 262800]*3600;
        y0 = [0 -13.2 -15.9 -17.2  -17.9  -18.3  -18.6];
        
    case '17'
        % run 17
        % the extraction power is -20 W/m for 6 month, than 0 W/m for 6 month
        % data at the beginning of the extraction power
        A = [933.807,-7.069; ...
            9604.873,-10.532; ...
            18409.34,-12.654; ...
            26947.005,-13.996; ...
            36285.076,-15.468; ...
            53360.406,-16.723; ...
            70702.538,-17.805; ...
            88311.472,-18.411; ...
            114724.873,-19.364; ...
            149409.137,-19.926; ...
            184360.203,-20.186; ...
            210773.604,-20.532; ...
            254662.538,-20.749];
        B(:,1) = ((0:29)*8760 + 24)';    % evaluate 24 h after the beginning of the extraction
        B(:,2) = FnFit(A,B(:,1));
        %B(1,2) = 0;                     % corrected value for start
        
        % data at the end of a pump run
        A = [4135.431,-10.532; ...
            13073.299,-13.216; ...
            21877.766,-14.991; ...
            30682.234,-16.247; ...
            39219.898,-17.156; ...
            48291.168,-17.935; ...
            57095.635,-18.671; ...
            65366.497,-19.147; ...
            74170.964,-19.58; ...
            82975.431,-19.84; ...
            91779.898,-20.1; ...
            100851.168,-20.273; ...
            109388.832,-20.359; ...
            118726.904,-20.619; ...
            126730.964,-20.879; ...
            135535.431,-20.879; ...
            144339.898,-21.225; ...
            152877.563,-21.355; ...
            161682.03,-21.398; ...
            171020.102,-21.745; ...
            179557.766,-21.831; ...
            187295.025,-21.831; ...
            197166.701,-21.961; ...
            205704.365,-22.004; ...
            213975.228,-22.091; ...
            223313.299,-22.134; ...
            231317.36,-22.004; ...
            240655.431,-22.177; ...
            248926.294,-22.177; ...
            258130.964,-22.437];
        C(:,1) = ((0.5:29.5)*8760)';  % evaluate at stop of extraction power
        C(:,2) = FnFit(A,C(:,1));
        
        % data at the beginning of the timestep without extraction power
        A = [5202.64,-3.952; ...
            13873.706,-6.463; ...
            22944.975,-8.455; ...
            31749.442,-9.364; ...
            40287.107,-10.532; ...
            49358.376,-11.355; ...
            57629.239,-11.874; ...
            66700.508,-12.004; ...
            75238.173,-12.697; ...
            84042.64,-13.13; ...
            92580.305,-13.216; ...
            101651.574,-13.693; ...
            127531.371,-14.039; ...
            145140.305,-14.299; ...
            154478.376,-14.472; ...
            172087.31,-14.905; ...
            189162.64,-14.948; ...
            197700.305,-14.991; ...
            223846.904,-15.251; ...
            241189.036,-15.338; ...
            250393.706,-15.294];
        D(:,1) = C(:,1) + 48';      % evaluate 48 h after stop of extraction power
        D(:,2) = FnFit(A,D(:,1));

        % data at the end of a pump stop
        A = [8937.868,-3.39; ...
            17875.736,-5.381; ...
            26680.203,-7.286; ...
            34684.264,-8.455; ...
            44022.335,-9.104; ...
            52560,-9.883; ...
            61364.467,-10.619; ...
            70168.934,-10.965; ...
            78439.797,-11.355; ...
            86977.462,-11.615; ...
            95781.929,-12.004; ...
            104853.198,-12.264; ...
            114191.269,-12.481; ...
            122462.132,-12.697; ...
            131533.401,-13.087; ...
            140071.066,-13.13; ...
            149142.335,-13.173; ...
            157413.198,-13.346; ...
            165950.863,-13.433; ...
            174488.528,-13.433; ...
            183559.797,-13.606; ...
            191830.66,-13.779; ...
            209973.198,-13.866; ...
            218777.665,-13.952; ...
            244657.462,-14.039; ...
            262666.599,-14.039];
        E(:,1) = ((1:30)*8760 - 1)';  % evaluate 1 h before the end of timestep without extraction
        E(:,2) = FnFit(A,E(:,1));
        
        A = sortrows([B; C; D; E],1);
        t0 = A(:,1)*3600;
        y0 = A(:,2);

    otherwise
        % default reference data
        t0 = [0 30*8760];
        y0 = [0 0];
end
end % of function setReferenceData

function ys = FnFit(A,xs)
x = A(:,1);
y = A(:,2);
ro_fcn = @(b,x) b(1)+b(2)*(1-exp(b(3)*x+b(4))); % Model Function
RNCF = @(b) norm(y - ro_fcn(b,x));              % Residual Norm Cost Function
B0 = [0 -10 -1e-5 0];                           % Initial Parameter Estimates
[B, ResNorm] = fminsearch(RNCF, B0);%#ok<ASGLU> % Estimate Parameters
ys = ro_fcn(B,xs);
% figure
% plot(x,y,'or',xs,ys)
% title(['Residual = ' num2str(ResNorm)])
end % of function FnFit


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
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    ts      created                                     10aug2017
%  6.1.1    hf      comments adapted to publish function        01nov2017
%                   reference y1 does not overwrite y2
%  7.1.0    hf      runs from Huber/Pahud as reference data     14may2021
%  7.1.1    hf      enlarged toleracnce max_simu_error  		19feb2022
%                   1e-7 to 1e-5
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
