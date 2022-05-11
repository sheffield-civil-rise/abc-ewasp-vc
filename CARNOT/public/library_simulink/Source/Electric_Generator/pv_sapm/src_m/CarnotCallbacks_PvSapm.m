function [ok, param] = CarnotCallbacks_PvSapm(varargin)

if nargin >= 2 && ischar(varargin{1})
    command = varargin{1};
else
    error(['CarnotCallbacks_PvDesotoConf: First argument must be ', ...
        'a valid function name. Second argument must be the blockhandle.'])
end
blockpath = fullfile('Source','Electric_Generator', 'Pv_Sapm','parameter_set');
% switch for command line calls
switch command      % switch for command line calls
    case 'UserEdit'
        % switch to edit mode for file and path
        [ok, param] = CarnotCallbacks_PvlBlocks('UserEdit', varargin{2});
    case 'GetFilename'
        % get the filename and pathname, set these variables in the mask
        [ok, param] = CarnotCallbacks_PvlBlocks('GetFilename', varargin{2:end}, blockpath);
    case 'SaveFilename'
        % save parameter set with new filename and pathname
        [ok, param] = CarnotCallbacks_PvlBlocks('SaveFilename', varargin{2:end}, blockpath);
    case 'SetParameters'
        % load parameterfile and set parameters automatically
        [ok, param] = CarnotCallbacks_PvlBlocks('SetParameters', varargin{2:end}, blockpath);         
    case 'SetTemperatureModel'    
        % set temperature model with popup in user edit mode
        [ok, param] = CarnotCallbacks_PvlBlocks('SetTemperatureModel', varargin{2});         
        param = 1;
        ok = true;
    otherwise     
        % something went wrong
        ok = false;
        param = -1;
end
varargout{1} = ok;
varargout{2} = param;
end

