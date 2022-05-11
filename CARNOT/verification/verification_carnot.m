%% verification_carnot: verification of Carnot blockset 
%  Syntax:       
%    v = verification_carnot(show, save_sim_ref, cont_on_error, block_idx, check_examples)
%  Calls all verify_*.m functions. It uses dir to search for all 
%  verification functions (verify_*.m) and than calls the functions. 
%  Result is true (1) when verification passed, false (0) otherwise.
%  All verification results will be printed to the command window and to
%  the verification_carnot_results.txt file.
% 
%  Input:       show - optional 1st input: flag for display 
%                   false : show results only if verification fails
%                   true  : show results allways
%               save_sim_ref - optional 2nd input: flag to save new simulation reference
%                   false : do not save a new reference simulation scenario
%                   true  : save a new reference simulation scenario
%               cont_on_error - optional 3rd input: flag to continue if error occurs
%                   false : stop verification if error occurs
%                   true  : continue verification if error occurs 
%                           (result v is false)
%               block_idx - optional 4th input: indices of models to verify
%                   missing or empty: verify all models
%                   data format     : array of double 
%                   script takes care of limiting block_idx to MIN/MAX values for carnot library
%               check_examples - optional 5th input: 
%                   false : do nothing with the examples
%                   true  : simulate the example_*.slx files in the
%                           tutorial/examples folder
%                   
%  Output:       v - true if verification is ok, false otherwise
%                                                                          
%  Remarks: 
%  a) Close all libraries and models before starting verification_carnot 
%  b) 2nd, 3rd, 4th and 5th input are only correctly taken in account if the inputs
%   arguments before are entered. Examples for correct function calls:
%   verification_carnot
%   verification_carnot(true)                       verification_carnot(1)
%   verification_carnot(false,true)                 verification_carnot(0,1)
%   verification_carnot(false,false,true)           verification_carnot(0,0,1)
%   verification_carnot(false,false,true)           verification_carnot(0,0,1,[])
%   verification_carnot(false,false,false,true)     verification_carnot(0,0,0,[],1)
% 
%  function is used by: --
%  this function calls: verify_*.m
% 
%  Literature: --

function vtot = verification_carnot(varargin)
%% main calculations
disp('--- starting verification of CARNOT library and functions ---')
if nargin == 0
    show = false;
    save_sim_ref = false;
    cont_on_error = false;
    block_idx = []; 
    check_examples = false;
elseif nargin == 1
    show = logical(varargin{1});
    save_sim_ref = false;
    cont_on_error = false;
    block_idx = [];
    check_examples = false;
elseif nargin == 2
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
    cont_on_error = false;
    block_idx = [];
    check_examples = false;
elseif nargin == 3
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
    cont_on_error = logical(varargin{3});
    block_idx = [];
    check_examples = false;
elseif nargin == 4
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
    cont_on_error = logical(varargin{3});
    block_idx = (varargin{4});    
    check_examples = false;
elseif nargin == 5
    show = logical(varargin{1});
    save_sim_ref = logical(varargin{2});
    cont_on_error = logical(varargin{3});
    block_idx = (varargin{4});    
    check_examples = true;
else
    error('verification_carnot:%s',' too many input arguments')
end
old_wd = pwd;                   % keep current working directory
car_wd = path_carnot('root');   % get carnot root directory

% get all files which start with validate_ with the recursive search dir
cd(car_wd);
d2=dir('**/verification/verify_*.m');%% only files in verificatin folders
cd(old_wd);

%get status of simulink files of the public part
    if exist('readcell','file')% from R2019a
        temp = readcell(fullfile(path_carnot('libsl'),'status.txt'));
    else % compatibility with R2018b
        temp = readtable(fullfile(path_carnot('libsl'),'status.txt'),'ReadVariableNames',false);
        temp = table2cell(temp);
    end
    for sidx = 1:length(temp)
        status.(temp{sidx,1}) = strcmp(temp{sidx,2},'done');
    end
    % remove blocks not in correct directory or not set "done" in status.txt
    for n = length(d2):-1:1
        curBlk = char(regexp(d2(n).folder,'\w*(?=\\verification$)','match'));
        if contains(d2(n).folder,['public' filesep 'library_simulink']) ...
                && ~(isfield(status,curBlk) && status.(curBlk))          
            disp("Delete Nr "+n+":"+d2(n).name)
            d2(n)=[];
        end
    end

ntot = length(d2);% number of functions to validate
block_idx = block_idx( (block_idx>=1)&(block_idx<=ntot) );
if isempty(block_idx)
    block_idx = 1:ntot;   
end

vtot = true;                    % result of all verifications (be optimistic)
evalin('base','clear THB')      % clear THB bus object from base workspace
evalin('base','clear EB')      % clear EB bus object from base workspace
fid = fopen('verification_carnot_results.txt','w');
for n = block_idx%firstBlock:lastBlock
        [fd, fn] = fileparts(fullfile(d2(n).folder, d2(n).name));
        cd(fd)
        assignin('base','mdl_idx',n);
        % set validation result v and text s1 by evaluation the fn string
        eval(['[v, s1] = ',fn, '(',num2str(show), ',' ,num2str(save_sim_ref) ');'])
        disp(['    evaluating ' fullfile(fd,fn)])
        fprintf('%i of %i: %s \n\n', n, ntot, s1);
        fprintf(fid, '%i of %i: %s \n\n', n, ntot, s1);
        if v == false   %#ok<NODEF> -- variables v and s1 are set by the eval function
            vtot = false;
            if ~cont_on_error
                break               % force end of loop
            end
        end
end
fclose(fid);

% if verification was not stopped on error or verification is ok
if cont_on_error || vtot
    cd(old_wd)              % go back to old working directory
end
% print result in the command window
if vtot == true
    disp('**** Verification of CARNOT library and functions passed ****')
else
    warning('!!! VERIFICATION OF CARNOT LIBRARY AND FUNCTIONS FAILED !!!')
end

if check_examples
    v = check_carnot_examples(cont_on_error);
    if v == true
        disp('**** simulation of CARNOT examples passed ****')
    else
        warning('!!! SIMUMLATION OF CARNOT EXAMPLES FAILED !!!')
    end
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
%  author list:     hf -> Bernd Hafner
%                   jg -> Joachim Goettsche
%                   pk -> Patrick Kefer
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Ver.     Author  Changes                                     Date
%  6.1.0    hf      created                                     02apr2014
%  6.1.1    hf      including printout to screen                25jul2014
%  6.1.2    hf      path_carnot_6 replaced by path_carnot       16dec2014
%  6.1.3    hf      validate_ replaced by verify_               09jan2015
%                   function name changed to verification_
%  6.1.4    hf      modified help text                          28jul2915
%  6.1.5    hf      disp replaces with fprintf                  22apr2017
%  6.1.6    jg      dir2 durch dir-Befehl ersetzt               08aug2017
%  6.1.7    pk      added input option for show and 
%                   save_sim_ref -> passed to verify scripts    13jun2018
%  7.1.0    hf      added optional parameter cont_on_error      13jan2019
%  7.1.1    hf      replaced disp by warning if simu fails      01mar2020
%  7.1.2    pk?     added parameter block_idx                   ??jun2020
%  7.1.3    hf      added parameter check_examples              04aug2020
%  7.1.4    pk      correction in help section                  11jun2021
%  7.2.0    pk      added check of status.txt                   ??jan2022
%  7.2.1    hf      check of status.txt only for                18feb2022
%                   library_simulink public in the folder
% **********************************************************************
