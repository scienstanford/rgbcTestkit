function rp = rgbcrootpath()
% Return the path to the root directory
%
% This function must reside in the directory at the base of the rgbc
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(rootpath, 'data')
%
% QT (c) Stanford VISTA Lab

[rp, fn, ext] = fileparts(which('rgbcrootpath'));

return