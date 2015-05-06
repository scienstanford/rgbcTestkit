function rootPath=rgbcRootPath()
% Return the path to the root RGBC directory
%
% This function must reside in the directory at the base of the rgbc
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(rgbcRootPath,'data')

rootPath=which('rgbcRootPath');

[rootPath,fName,ext]=fileparts(rootPath);

return