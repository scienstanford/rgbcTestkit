function img = rgbcRawRead( filename, sensorsize)
% Read raw images from RGBC sensor
%
% READRAW Reads the raw image data 
%
%
% QT (c) Stanford VISTA Lab 2015

if ~strcmpi(filename(end-3:end),'.raw')
    error('Filename should end in .raw')
end

if ~exist('sensorsize','var')
    sensorsize = [3264, 2448];
end 

fid = fopen(filename, 'r');
img = fread(fid, sensorsize);
fclose(fid); clear fid;

img = img';

disp(['*** Max pixel value is ' num2str(max(img(:))) ' ***']);
end

