%% check_carnot_examples: verification of the exmaples of Carnot
%  Syntax:       v = check_carnot_examples(cont_on_error)
%  Opens and simulates all example_*.slx models in the tutorial/example folder. 
%  Result is true (1) when simulation is running, false (0) otherwise.
%  Input:   cont_on_error - optional 3rd input: flag to continue if error occurs
%               false : stop verification if error occurs
%               true  : continue verification if error occurs 
%                           (result v is false)
%  Output:  v - true if simulation runs, false otherwise
%  function is used by: --
%  this function calls: example_*.slx
%  see also verifcation_carnot.m
% 
%  Literature: --

function vtot = check_carnot_examples(varargin)
%% Check input arguments
if nargin == 0
    cont_on_error = false;
elseif nargin == 1
    cont_on_error = logical(varargin{1});
else
    error('verification_carnot:%s',' too many input arguments')
end
%% main calculations
disp('--- starting simulation of CARNOT examples ---')
old_wd = pwd;                       % keep current working directory
car_wd = path_carnot('examples');   % get carnot examples directory

% open result file for writing
fid = fopen('check_carnot_examples_results.txt','w');

% get all files which start with validate_ with the recursive search dir
cd(car_wd);
d2 = dir('**/example_*.slx');
ntot = length(d2);                  % number of examples to simulate
vtot = true;                        % result of all verifications (be optimistic)

% loop over all examples
for n = 1:ntot
    fn = d2(n).name;
    fprintf('>>> Trying to simulate %i of %i: %s \n', n, ntot, fn);
    
    try
        simOut = sim(fn, 'SrcWorkspace','base', ...
            'SaveOutput','on','OutputSaveName','yout');
        % simulating the examples in current function workspace leads to
        % Matlab crash with example_CollectorUnglazedVariables.slx 
        % ... but it works in  base workspace ... :o)
        % simOut = sim(fn, 'SrcWorkspace','current', ...
        %     'SaveOutput','on','OutputSaveName','yout');
        if strcmp(simOut.SimulationMetadata.ExecutionInfo.StopEvent, 'ReachedStopTime')
            s1 = ' -> Successfull !';
        else
            s1 = [' -> !!! FAILED !!!', simOut.SimulationMetadata.ExecutionInfo.StopEvent];
            vtot = false;
        end
        
    catch
        s1 = ' -> !!! FAILED TOTALLY !!!';
        vtot = false;
    end
    
    fprintf('>>> Simulation %i of %i: %s %s \n\n', n, ntot, fn, s1);
    fprintf(fid, '%i of %i: %s %s \n\n', n, ntot, fn, s1);
    if ~vtot
        if ~cont_on_error
            break               % force end of loop
        end
    end
end
fclose(fid);
cd(old_wd)                      % go back to old working directory


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
%  $Revision: 165 $
%  $Author: carnot-hafner $
%  $Date: 2017-04-22 12:59:26 +0200 (Sa, 22 Apr 2017) $
%  $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/verification/check_carnot_examples.m $
%  **********************************************************************
%  D O C U M E N T A T I O N
%  author list:     hf -> Bernd Hafner
%  version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%  Ver.     Author  Changes                                     Date
%  7.1.0    hf      created                                     04aug2020
% **********************************************************************
