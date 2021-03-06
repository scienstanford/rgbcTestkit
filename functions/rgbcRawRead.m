function img = rgbcRawRead(filepath, sensorsize)
% Read raw images from RGBC sensor assuming we know the raw image size.
%
% For an input URL, download the raw image first onto local directory and
% read the raw image. 
%
% Sensor size is set in the ".ovd" file of the Windows software of the
% RGBC testkit. This software is general for all Omnivision sensors.
% Therefore, for each specific sensor, the acquisition parameters can be
% set in the ".ovd" file. Omnivision people can edit this file. 
%
% RGBC sensor has high resolution. The ".ovd" file was set to crop the raw
% images to [3264, 2448] after the acquisition. The raw image size requires
% high bandwidth and is an issue for RGBC videos.
% 
% (c) Stanford VISTA Lab, 2015

if ~strcmpi(filepath(end - 3 : end),'.raw')
    error('Filename should end in .raw format')
end

if strcmpi(filepath(1 : 4), 'http') % load file from scarlet first
    filepath = urlwrite(filepath, fullfile(rgbcrootpath, 'loadscarlettmpfile.raw')); % download file from URL
end

if ~exist('sensorsize','var')
    sensorsize = [3264, 2448]; % default sensor size
end 

fid = fopen(filepath, 'r');
img = fread(fid, sensorsize);
fclose(fid); clear fid;

img = img';

disp(['*** Max pixel value is ' num2str(max(img(:))) ' ***']);

if exist(fullfile(rgbcrootpath, 'loadscarlettmpfile.raw'), 'file') % delete the downloaded raw
    delete(fullfile(rgbcrootpath, 'loadscarlettmpfile.raw'));
end

end

