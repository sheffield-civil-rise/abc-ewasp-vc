%% ManageCarnotToolbox can be used to compile, create and verify the Carnot Toolbox
%% Function Call
%  ManageCarnotToolbox(Mode);
%% Inputs
%  Mode:
%   'version': compile sources, create Carnot.slx and help files from library files
%   'verify' : run verification of .slx and m-files, test example files
%   'all'    : all of the above
%% Outputs
%  none
%% Description
%  Calls VersionManagement scripts and verification scripts  of the toolbox in correct order.
%  All functions called are available in "carnot_root\verification" and "carnot_root\version_manager"
%  Version Management:
%    compilation of all cmex-files
%    creation of carnot.slx and carint.slx
%    creation of help files
%    copy all development files from library folders to target folders
%  Verification:
%    runs verification for *slx and *.m-files
%    runs checks for all examples
%
%  This function calls: MakeMEX.m
%                       CreateCarnotMDL
%                       CreateCarintMDL
%                       CopyRemainingFiles()
%                       CreateMFileHelp()
%                       verification_carnot()
%                       check_carnot_examples()

function ManageCarnotToolbox(Mode)
run(fullfile(path_carnot('root'),'init_carnot'));
if nargin==1 && any(strcmp(Mode,{'version','verify','all'}))
    dirVersManager = fullfile(path_carnot('root'),'version_manager');
    dirVerify = fullfile(path_carnot('root'),'verification');
    curDir = pwd;
    if strcmp(Mode,'version')||strcmp(Mode,'all')    % compile and create carnot
        cd(dirVersManager);
        MakeMEX();
        CreateCarnotMDL('pub');
        CreateCarintMDL();
        CopyRemainingFiles();
        CreateMFileHelp()
    end
    if strcmp(Mode,'all')
        cd(dirVerify);
        verification_carnot();
        check_carnot_examples();
    end
    if  strcmp(Mode,'verify')
        if exist(fullfile(path_carnot('root'),'carnot'),'file')==4% run verification scripts for Carnot Toolbox
            cd(dirVerify);
            verification_carnot();
            check_carnot_examples();
        else
            warning('carnot.slx (or .mdl) could not be found. U init_carnot.m first or create carnot.slx before.')
        end
    end
    cd(curDir);
else
    warning('Invalid or missing input parameter Mode');
    help('ManageCarnotToolbox.m');
end

