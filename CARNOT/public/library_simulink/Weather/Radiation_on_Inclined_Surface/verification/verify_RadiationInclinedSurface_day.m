%% verify_RadiationInclinedSurface_day - verification of the RadiationInclinedSurface block in Carnot
%% Function Call
%  [v, s] = verify_RadiationInclinedSurface_day(varargin)
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
%  by comparing the results to the initial simulation, the incidence angle
%  of equations from [Duffie 2006] and the longitudinal and transversal
%  incidence angle from [ISO 9806:2017]. The solar position is calculated
%  by the carlib functions. 
%  The verification is done for the 23nd of march. The angles are compared 
%  for every full hour of the day.
%                                                                          
%  Literature:
%   Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
%   ISO 9806:2017 : Solar thermal collectors – Test methods
%  see also verify_RadiationInclinedSurface, verification_carnot, solar_angles

function [v, s] = verify_RadiationInclinedSurface_day(varargin)
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
    error('verify_RadiationInclinedSurface_day:%s',' too many input arguments')
end

%% specific model or function parameters
Deg2Rad = pi/180;
Rad2Deg = 180/pi;
% ----- set error tolerances ----------------------------------------------
max_error = 1.5;        % max error between simulation and reference is 1.5 °
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'RadiationOnInclinedSurface';
modelfile = 'verify_RadiationInclinedSurface_mdl';

% function parameters
u0 = [0 45 90];         % reference input values for latitude
lst = 0;                % reference meridian
local = 0;              % local meridian
azimu = 0;              % collector azimuth
rotat = 0;              % collector rotation
nsec = date2sec([3 23 0 0 0]);  % calculate for 23nd of march
standardtime = (0:24)';         % calculate 1 day
t0 =  standardtime*3600+nsec; 

%% start simulation
y2 = zeros(length(t0),3,3);
y0 = y2;
load_system(modelfile)
for n = 1:length(u0)
    lat = u0(n);
    slope = lat;            % collector inclination is latitude
    % maskStr = get_param([gcs, '/Constant'],'DialogParameters');
    set_param([modelfile, '/Add_Solar_Position'], 'lati', num2str(lat));
    set_param([modelfile, '/Add_Solar_Position'], 'longi', '0');
    set_param([modelfile, '/Add_Solar_Position'], 'timezone', '0');
    set_param([modelfile, '/Fixed_Surface'], 'colangle', num2str(slope));
    set_param([modelfile, '/Fixed_Surface'], 'colazi', num2str(azimu));
    set_param([modelfile, '/Fixed_Surface'], 'colrot', num2str(rotat));
    set_param(modelfile, 'Starttime', num2str(t0(1)), 'StopTime', num2str(t0(end)))

    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout');    % get the whole output vector (one value per simulation timestep)
    tt = simOut.get('tout');    % get the whole time vector from simu
    yy = timeseries(xx,tt);
    yt = resample(yy,t0);
    y2(:,:,n) = yt.data;
    
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
    
    % original carnot equations
    % zenrad = zenrad(:);             % force in column vector
    % tetaC = test_incidence_angles(azirad, zenrad, gamarad, brad, rotrad);
    % internal check
    %     cr = tan(tetaC(:,1)).^2 - tan(tetaC(:,2)).^2 - tan(tetaC(:,3)).^2;
    %     disp(cr)   % cr must be ~0
    % test this reference
    % inangle = tetaC(:,1);       % incidence angle limited to 90°
    % tetalong = tetaC(:,2);      % longitudinal incidence angle
    % tetatrans = tetaC(:,3);     % transversal incidence angle

    % reference results
    y0(:,1,n) = Rad2Deg*inangle;            % incidence angle
    y0(:,2,n) = min(90, Rad2Deg*tetalong);  % longitudinal incidence angle
    y0(:,3,n) = min(90, Rad2Deg*tetatrans); % transversal incidence angle
    idx = y0(:,1,n) >= 90;                  % index to incidence angle > 90°
    y0(idx,1,n) = 90;                       % incidence angle set to 90°
    y0(idx,2,n) = 90;                       % longitudinal incidence angle set to 90°
    y0(idx,3,n) = 90;                       % transversal incidence angle set to 90°
end
close_system(modelfile, 0)   % close system, but do not save it

% correct the reference values, ISO equations seem to be wrong for other
% inclination angles of the collector than 0 (flat on the ground)
y0(:,2,2) = y0(:,2,1);    % reference tetalong for latitude 45° is reference at equator
y0(:,2,3) = y0(:,2,1);    % reference tetalong for latitude 90° is reference at equator
y0(:,3,2) = y0(:,3,1);    % reference tetatrans for latitude 45° is reference at equator
y0(:,3,3) = y0(:,3,1);    % reference tetatrans for latitude 90° is reference at equator

%% set the reference values
% ----------------- set reference values initial simulation ---------------
% result from call at creation of function if required it can be determined
% from the simulation result
if (save_sim_ref)
    y1 = y2;   % determinded data
    save('simRef_RadiationInclSurf_day.mat','y1');
else
    y1 = importdata('simRef_RadiationInclSurf_day.mat');  % result from call at creation of function
end


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

for n = 1:length(u0)
    lat = u0(n);
    % error between reference and initial simu
    [e1, ye1] = calculate_verification_error(y0(:,:,n), y1(:,:,n), r, s);
    % error between reference and current simu
    [e2, ye2] = calculate_verification_error(y0(:,:,n), y2(:,:,n), r, s);
    % error between initial and current simu
    [e3, ye3] = calculate_verification_error(y1(:,:,n), y2(:,:,n), r, s);
    % Pythagoras check
    idx = y2(:,1,n) < 85;       % index to incidencen anlges below 85°
    pc = max(abs(tan(Deg2Rad*y2(idx,1,n)).^2 ...
        - tan(Deg2Rad*y2(idx,2,n)).^2 - tan(Deg2Rad*y2(idx,3,n)).^2));

    % ------------- decide if verification is ok --------------------------------
    if max(abs(ye2)) > max_error
        v = false;
        s = sprintf('verification %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
            functionname, e2, max_error);
        show = true;
    elseif e3 > max_simu_error
        v = false;
        s = sprintf('verification %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
            functionname, e3, max_simu_error);
        show = true;
    elseif pc > max_simu_error
        v = false;
        s = sprintf('verification %s of Pythagoras FAILED: error %3.3f > allowed error %3.3f', ...
            functionname, pc, max_simu_error);
        show = true;
    else
        v = true;
        s = sprintf('%s OK: error %3.3f°', functionname, e2);
    end
    
    % ------------ diplay and plot options if required ------------------------
    if (show)
        disp(s)
        disp(['Initial error = ', num2str(e1)])
        sx = 'hour';                         % x-axis label
        st = ['Simulink block verification for latitude ' num2str(lat) '°'];   % title
        
        % upper legend
        sleg1 = {'reference data','initial simulation','current simulation'};
        % lower legend
        sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
        
        %   y - matrix with y-values (reference values and result of the function call)
        y_teta  = [y0(:,1,n), y1(:,1,n), y2(:,1,n)];
        y_tetaL = [y0(:,2,n), y1(:,2,n), y2(:,2,n)];
        y_tetaT = [y0(:,3,n), y1(:,3,n), y2(:,3,n)];
        
        %   x - vector with x values for the plot
        x = standardtime;
        
        %   ye - matrix with error values for each y-value
        ye_teta  = [ye1(:,1), ye2(:,1), ye3(:,1)];
        ye_tetaL = [ye1(:,2), ye2(:,2), ye3(:,2)];
        ye_tetaT = [ye1(:,3), ye2(:,3), ye3(:,3)];
        
        sz = strrep(s,'_',' ');
        
        % ----------------------- Combining plots ---------------------------------
        figure              % open a new figure
        
        % longitudinal incidence angle plots
        subplot(2,3,1)      % divide in subplots (lower and upper one)
        plot(x,y_tetaL(:,1),'x',x,y_tetaL(:,2),'o',x,y_tetaL(:,3),'-')
        title(st)
        ylabel('longitudinal angle in °')
        legend(sleg1,'Location','best')
        text(0,-0.2,sz,'Units','normalized')  % display valiation text
        
        subplot(2,3,4)      % choose lower window
        plot(x,ye_tetaL(:,1),'x',x,ye_tetaL(:,2),'o',x,ye_tetaL(:,3),'-')
        legend(sleg2,'Location','best')
        xlabel(sx)
        ylabel('Difference in °')
        
        % transversal incidence angle plots
        subplot(2,3,2)      % divide in subplots (lower and upper one)
        plot(x,y_tetaT(:,1),'x',x,y_tetaT(:,2),'o',x,y_tetaT(:,3),'-')
        title(st)
        ylabel('transversal angle in °')
        legend(sleg1,'Location','best')
        text(0,-0.2,sz,'Units','normalized')  % display valiation text
        
        subplot(2,3,5)      % choose lower window
        plot(x,ye_tetaT(:,1),'x',x,ye_tetaT(:,2),'o',x,ye_tetaT(:,3),'-')
        
        legend(sleg2,'Location','best')
        xlabel(sx)
        ylabel('Difference in °')
        
        %  incidence angle plots
        subplot(2,3,3)      % divide in subplots (lower and upper one)
        plot(x,y_teta(:,1),'x',x,y_teta(:,2),'o',x,y_teta(:,3),'-')
        title(st)
        ylabel('incidence angle in °')
        legend(sleg1,'Location','best')
        text(0,-0.2,sz,'Units','normalized')  % display valiation text
        
        subplot(2,3,6)      % choose lower window
        plot(x,ye_teta(:,1),'x',x,ye_teta(:,2),'o',x,ye_teta(:,3),'-')
        legend(sleg2,'Location','best')
        xlabel(sx)
        ylabel('Difference in °')
    end
end % end for n
end % end of function verify_RadiationInclinedSurface_day


%% internal subfunctions
% function teta = test_incidence_angles(as, zs, ac, zc, rc)
% % function to test the sunlight incidence anles on a collector plane
% % test_incidence_angles(AZIMUT, ZENITH, COLAZIMUT, COLANGLE, COLROTATE)
% % input and output angles in radian
% 
% szs = sin(zs);      % sine ZENITH angle of sun */
% czs = cos(zs);      % cosine ZENITH angle of sun */
% sda = sin(as-ac);   % difference of azimut */
% cda = cos(as-ac); 
% szc = sin(zc);      % sine ZENITH angle of collector (inclination) */
% czc = cos(zc);      % cosine ZENITH angle of collector (inclination) */
% src = sin(rc);      % sine rotation angle of collector */
% crc = cos(rc);      % cosine rotation angle of collector */
% 
% % incidence angle between sun and normal of the collector plane
% costeta = src.*sda.*szs+crc.*(szc.*cda.*szs+czc.*czs);    % cos of incidence angle on surface */
% 
% % old functions of carnot surfrad.c
% % incidence angle in longitudinal collector plane (direction riser - vertical on window) */
% tetalong = acos(costeta./sqrt((czc.*cda.*szs-szc.*czs).^2+costeta.^2));
% % incidence angle in transversal collector plane (direction header - vertical on window) */
% tetatrans = acos(costeta./sqrt((crc.*sda.*szs-src.*(szc.*cda.*szs+czc.*czs)).^2+costeta.^2));
% 
% % set outputs
% teta(:,1) = acos(costeta);    % incidence angle in degrees
% teta(:,2) = tetalong;         % longitudinal angle in degrees
% teta(:,3) = sign(as).*tetatrans;        % transversal angle in degrees
% end

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
%  $Revision: 652 $
%  $Author: carnot-hafner $
%  $Date: 2019-12-10 21:42:59 +0100 (Di, 10 Dez 2019) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/library_simulink/Weather/Radiation_on_Inclined_Surface/verification/verify_RadiationInclinedSurface_day.m $
%  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%  author list:     hf -> Bernd Hafner
%                   jg -> Joachim Goettsche
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Ver.     Author  Changes                                     Date
%  7.1.0    hf      created on verify_RadiationInclinedSurface  01jan2020
%  7.1.1    hf      correceted solar azimut calculation         25jan2020
%                   reference solar angles from carlib, only 
%                   equation for incidence angles remain here
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
