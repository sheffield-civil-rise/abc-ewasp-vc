function makeInfo = rtwmakecfg()
	makeInfo = lct_rtwmakecfg();
	makeInfo.sourcePath{1} = fullfile(path_carnot('root'), '\public\src');
	makeInfo.includePath{1} = fullfile(path_carnot('root'), '\public\src');
	makeInfo.sourcePath{2} = fullfile(path_carnot('root'), '\public\src\libraries');
	makeInfo.includePath{2} = fullfile(path_carnot('root'), '\public\src\libraries');
	makeInfo.library(1).Name='carlib';
	makeInfo.library(1).Location=fullfile(path_carnot('root'), '\public\src\libraries');
	makeInfo.library(1).Modules{1}='carlib';
	makeInfo.library(2).Name='debugfunctions';
	makeInfo.library(2).Location=fullfile(path_carnot('root'), '\public\src\libraries');
	makeInfo.library(2).Modules{1}='debugfunctions';
	makeInfo.precompile=0;
end
