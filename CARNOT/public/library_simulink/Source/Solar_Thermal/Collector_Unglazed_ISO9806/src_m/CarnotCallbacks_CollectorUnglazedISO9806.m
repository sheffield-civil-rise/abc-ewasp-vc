%% Callback for Carnot model Collector_Unglazed_ISO9806
%% Function Call
%  ok = CarnotCallbacks_CollectorUnglazedEN12975conf(parameterfile,userParam)
%% Inputs
%  parameterfile - char variable with the name of the parameter file
%  userParam    - false when parameters are read from file
%               - true when user is allowed to edit parameters
%% Outputs
%  ok - true if loading of parameters was successfull, false otherwise
% 
%% Description
%  Search for the parameterfile in the folders parameter_set of the model
%  and load the parameter set. The function is used by the mask of the
%  Carnot Simlink block.
%  The user can specify whether the parameters are read from file or edited
%  by the user.
% 
%% References and Literature
%  Function is used by: Simulink block Collector Unglazed ISO 9806
%  Function calls: CarnotCallbacks_loadConfParameters.m
%  see also CarnotCallbacks_loadConfParameters

function varargout = CarnotCallbacks_CollectorUnglazedISO9806(varargin)
% check correct number of input arguments
if nargin >= 2 && ischar(varargin{1})
    command = varargin{1};
else
    error(['CarnotCallbacks_HeatPumpAirSourceConf: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.'])
end

%% Calculations
blockpath = fullfile('Source','Solar_Thermal','Collector_Unglazed_ISO9806','parameter_set');
% switch for command line calls
switch command      % switch for command line calls
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_CONFblocks('UserEdit', varargin{2});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_CONFblocks('GetFilename', varargin{2:end}, blockpath);
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_CONFblocks('SaveFilename', varargin{2:end}, blockpath);
    case 'SetParameters'
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_CONFblocks('SetParameters', varargin{2:end}, blockpath);
    case 'CallHPparam'
        % launch GUI to identify parameters K
        K = set_param(gcb, 'K');
        [ok, K] = HeatpumpAirSourceHPparam(K);
        set_param(gcb, 'K', K)
    otherwise
        % something went wrong
        ok = false;
        param = -1;
end
varargout{1} = ok;
varargout{2} = param;
end  % CarnotCallbacks_CollectorUnglazedISO9806

%% Copyright and Versions
% Copyright (c) 2017-2019 Viessmann Werke GmbH and the authors
%  
%  ************************************************************************
%  VERSIONS
%  version: CarnotVersion.MajorVersionOfFunction
%  Ver. Author  Changes                                         Date
%  6.1  drhf    created                                         26jun2015
%  7.1  drhf    renamed                                         10may2019
%               new: CarnotCallbacks_CollectorUnglazedISO9806
%               old: CarnotCallbacks_CollectorUnglazedEN12975conf
%               adapted to new callback structure of models
% *************************************************************************
