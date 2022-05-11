%% verify_RadiationInclinedSurface - verification of the RadiationInclinedSurface block in Carnot
%% Function Call
%  [v, s] = verify_RadiationInclinedSurface(varargin)
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
%  Verification of the RadiationInclinedSurface block in the Carnot Toolbox
%  by comparing the results to the initial simulation, the solar position
%  calculated with equations from [Duffie 2006] and the longitudinal and 
%  transversal incidence angle from [ISO 9806:2017]. The calculation is
%  donce for one year. The angles are compared for each day at 3 p.m.
%  Remark: ISO equations seem to be correct only for surface inclination
%  of 0°. So comparison is done for a this angle. 
%                                                                          
%  Literature:
%   Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
%   ISO 9806:2017 : Solar thermal collectors – Test methods
%  see also verification_carnot, verify_RadiationInclinedSurface_day, solar_angles

function [v, s] = verify_RadiationInclinedSurface(varargin)
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
    error('verify_RadiationInclinedSurface:%s',' too many input arguments')
end

%% specific model or function parameters
% ----- set error tolerances ----------------------------------------------
max_error = 1e-5;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'RadiationOnInclinedSurface';
modelfile = 'verify_RadiationInclinedSurface_mdl';
Deg2Rad = pi/180;
Rad2Deg = 180/pi;

% function parameters
lat = 45;               % reference input values for latitude
lst = 0;                % reference meridian
local = 0;              % local meridian
slope = 0;              % collector slope
azimu = 0;              % collector azimuth
rotat = 0;              % collector rotation
nday = (1:30:365)';     % calculate one day for each month
u0 = nday;
standardtime = 15;      % calculate for 3 p.m.
t0 = (nday*24 + standardtime)*3600;

%% start simulation
y2 = zeros(length(nday),3);
load_system(modelfile)
for n = 1:length(nday)
    % maskStr = get_param([gcs, '/Constant'],'DialogParameters');
    set_param([modelfile, '/Add_Solar_Position'], 'lati', num2str(lat));
    set_param([modelfile, '/Add_Solar_Position'], 'longi', '0');
    set_param([modelfile, '/Add_Solar_Position'], 'timezone', '0');
    set_param([modelfile, '/Fixed_Surface'], 'colangle', num2str(slope));
    set_param([modelfile, '/Fixed_Surface'], 'colazi', num2str(azimu));
    set_param([modelfile, '/Fixed_Surface'], 'colrot', num2str(rotat));
    set_param(modelfile, 'Starttime', num2str(nday(n)*24*3600), 'StopTime', num2str((nday(n)+1)*24*3600))

    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
%     t = simOut.get('tout'); % get the whole time vector from simu
%     yy = timeseries(xx,t);
%     yt = resample(yy,t0);
%     xx = yt.data;
    y2(n,:) = xx(standardtime+1,:);
end
close_system(modelfile, 0)   % close system, but do not save it

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_RadiationInclSurf.mat','y1');
else
    y1 = importdata('simRef_RadiationInclSurf.mat');  % result from call at creation of function
end

% ----------------- set the literature reference values -------------------
brad = slope*Deg2Rad;
% rotrad = rotat*Deg2Rad;
gamarad = azimu*Deg2Rad;
latirad = lat*Deg2Rad;
% decination and azimuth from carlib
[del,~,~,azi,wdegree] = solar_angles(t0,lat,lst,local);
wrad = wdegree*Deg2Rad;
delrad = del*Deg2Rad;
azirad = Deg2Rad*azi;
inanglecos = sin(delrad).*sin(latirad).*cos(brad) - ...
    sin(delrad).*cos(latirad).*sin(brad).*cos(gamarad) + ...
    cos(delrad).*cos(latirad).*cos(brad).*cos(wrad) + ...
    cos(delrad).*sin(latirad).*sin(brad).*cos(gamarad).*cos(wrad) + ...
    cos(delrad).*sin(brad).*sin(gamarad).*sin(wrad);
inangle = acos(inanglecos);
inanglesin = sin(inangle);
% equations of ISO 9806 for longitudunal and transversal angle
tetalong = atan(inanglesin.*cos(azirad)./inanglecos);   % longitudinal incidence angle
tetatrans = atan(inanglesin.*sin(azirad)./inanglecos);   % transversal incidence angle

% reference results
y0(:,1) = Rad2Deg*inangle;                         % incidence angle
y0(:,2) =  min(90, Rad2Deg*tetalong);   % longitudinal incidence angle from ISO 9806
y0(:,3) = min(90, Rad2Deg*tetatrans);   % transversal incidence angle from ISO 9806

% internal check
% cr = (inangletan).^2 - ((inangletan.*cos(azirad)).^2 + (inangletan.*sin(azirad)).^2);
% disp(cr)   % cr must be ~0


%% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
% r = 'relative'; 
s = 'max';
% s = 'sum';
% s = 'mean';

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3f°', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Day';                         % x-axis label
    st = 'Simulink block verification';   % title

    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    
    %   y - matrix with y-values (reference values and result of the function call)
    y_teta  = [y0(:,1), y1(:,1), y2(:,1)];
    y_tetaL = [y0(:,2), y1(:,2), y2(:,2)];
    y_tetaT = [y0(:,3), y1(:,3), y2(:,3)];
    
    %   x - vector with x values for the plot
    x = u0;
    
    %   ye - matrix with error values for each y-value
    ye_teta  = [ye1(:,1), ye2(:,1), ye3(:,1)];
    ye_tetaL = [ye1(:,2), ye2(:,2), ye3(:,2)];
    ye_tetaT = [ye1(:,3), ye2(:,3), ye3(:,3)];
    
    sz = strrep(s,'_',' ');
    
    % ----------------------- Combining plots ---------------------------------
    figure              % open a new figure
    
    % longitudinal incidence angle plots
    subplot(2,3,1)      % divide in subplots (lower and upper one)
    if size(y_tetaL,2) == 3
        plot(x,y_tetaL(:,1),'x',x,y_tetaL(:,2),'o',x,y_tetaL(:,3),'-')
    else
        plot(x,y_tetaL,'-')
    end
    title(st)
    ylabel('longitudinal angle in °')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,4)      % choose lower window
    if size(ye_tetaL,2) == 3
        plot(x,ye_tetaL(:,1),'x',x,ye_tetaL(:,2),'o',x,ye_tetaL(:,3),'-')
    else
        plot(x,ye_tetaL,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in °')
    
    % transversal incidence angle plots
    subplot(2,3,2)      % divide in subplots (lower and upper one)
    if size(y_tetaT,2) == 3
        plot(x,y_tetaT(:,1),'x',x,y_tetaT(:,2),'o',x,y_tetaT(:,3),'-')
    else
        plot(x,y_tetaT,'-')
    end
    title(st)
    ylabel('transversal angle in °')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,5)      % choose lower window
    if size(ye_tetaT,2) == 3
        plot(x,ye_tetaT(:,1),'x',x,ye_tetaT(:,2),'o',x,ye_tetaT(:,3),'-')
    else
        plot(x,ye_tetaT,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in °')
    
    %  incidence angle plots
    subplot(2,3,3)      % divide in subplots (lower and upper one)
    if size(y_teta,2) == 3
        plot(x,y_teta(:,1),'x',x,y_teta(:,2),'o',x,y_teta(:,3),'-')
    else
        plot(x,y_teta,'-')
    end
    title(st)
    ylabel('incidence angle in °')
    legend(sleg1,'Location','best')
    text(0,-0.2,sz,'Units','normalized')  % display valiation text
    
    subplot(2,3,6)      % choose lower window
    if size(ye_teta,2) == 3
        plot(x,ye_teta(:,1),'x',x,ye_teta(:,2),'o',x,ye_teta(:,3),'-')
    else
        plot(x,ye_teta,'-')
    end
    legend(sleg2,'Location','best')
    xlabel(sx)
    ylabel('Difference in °')
end


%% Copyright and Versions
%  This file is part of the CARNOT Blockset.
%  Copyright (c) 1998-2020, Solar-Institute Juelich of the FH Aachen.
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
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   ts -> Thomas Schroeder
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Version  Author  Changes                                     Date
%  6.1.0    hf      created                                     25jul2014
%  6.2.0    hf      return argument is [v, s]                   03oct2014
%  6.2.1    hf      filename validate_ replaced by verify_      09jan2015
%  6.2.2    hf      close system without saving it              16may2016
%  6.3.0    hf      comments adapted to publish function        02nov2017
%                   added save_sim_ref as 2nd input argument
%  7.1.0    hf      added incidence angle calculation of ISO    24mar2019
%  7.1.1    hf      new collector position, corrected comments  05jan2020
%  7.1.2    hf      correceted solar azimut calculation         25jan2020
%                   slope = 0, ISO seems wrong for slope > 0
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
