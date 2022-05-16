function v = verification_carnot(varargin)
% v = verification_carnot(show, save_sim_ref) 
% Calls all verify_*.m functions. It uses dir2 to search for all 
% verification functions (verify_*.m) and than calls the functions. 
% Result is true (1) when verification passed, false (0) otherwise.
% Input:        show - optional flag for display 
%                   false : show results only if verification fails
%                   true  : show results allways
%               save_sim_ref - optional flag to save new simulation reference
%                   false : do not save a new reference simulation scenario
%                   true  : save a new reference simulation scenario
% Output:       v - True if verification is ok, False otherwise
% Syntax:       v = verification_carnot
%                                                                          
% Function Calls:
% function is used by: --
% this function calls: verify_*.m
% 
% Literature: --

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
% $Revision: 165 $
% $Author: carnot-hafner $
% $Date: 2017-04-22 12:59:26 +0200 (Sa, 22 Apr 2017) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/verification/verification_carnot.m $
% **********************************************************************
% D O C U M E N T A T I O N
% author list:     hf -> Bernd Hafner
%                  jg -> Joachim Goettsche
%                  pk -> Patrick Kefer
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     02apr2014
% 6.1.1     hf      including printout to screen                25jul2014
% 6.1.2     hf      path_carnot_6 replaced by path_carnot       16dec2014
% 6.1.3     hf      validate_ replaced by verify_               09jan2015
%                   function name changed to verification_
% 6.1.4     hf      modified help text                          28jul2915
% 6.1.5     hf      disp replaces with fprintf                  22apr2017
% 6.1.6     jg      dir2 durch dir-Befehl ersetzt               08aug2017
% 6.1.7     pk      added input option for show and 
%                   save_sim_ref -> passed to verify scripts   13jun2018
% **********************************************************************

disp('--- starting verification of CARNOT library and functions ---')
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
    error('verify_Simple_House_SFH100:%s',' too many input arguments')
end
old_wd = pwd;                   % keep current working directory
car_wd = path_carnot('root'); % get carnot root directory

% get all files which start with validate_ with the recursive search dir2
% d2 = dir2(car_wd,'-r','template_verify_*.m'); % only for test
% d2 = dir2(car_wd,'-r','verify_*.m');
cd(car_wd);
d2=dir('**/verify_*.m');
cd(old_wd);

ntot = length(d2);              % number of functions to validate
vtot = true;                    % result of all verifications
v = true;                       % be optimistic, assume that it is ok
fid = fopen('verification_carnot_results.txt','w');
for n = 1:ntot
    [fd, fn] = fileparts(fullfile(d2(n).folder, d2(n).name));
    cd(fd)
    eval(['[v, s1] = ',fn, '(',num2str(show), ',' ,num2str(save_sim_ref) ');'])
    disp(['    evaluating ' fullfile(fd,fn)])
    fprintf('%i of %i: %s \n\n', n, ntot, s1);
    fprintf(fid, '%i of %i: %s \n\n', n, ntot, s1);    
    if v == false
        vtot = false;
        break                   % force end of loop
    end
end
fclose(fid);
if vtot == true
    disp('**** Verification of CARNOT library and functions passed ****')
    cd(old_wd)                      % go back to old working directory
else
    disp('!!! VERIFICATION OF CARNOT LIBRARY AND FUNCTIONS FAILED !!!')
end