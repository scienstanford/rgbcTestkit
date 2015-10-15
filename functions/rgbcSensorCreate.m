function rgbcSensor = rgbcSensorCreate(fName)
% Create rgbc sensor
%
% TODO
% 
% 
% QT (c) Stanford VISTA Lab 2015




% %% NATHAN CHANGED (except for lastline)
% addpath('C:\OVTATPantherAM\CapturedImage');
% addpath('D:\Users\Nathan\Documents\MATLAB\iset');
% isetPath('D:\Users\Nathan\Documents\MATLAB\iset');
% 
% % fName = 'cap_9.raw'; -- used for testing only.
% 
% if ~exist(fName,'file'), fName = vcSelectDataFile; end
% 
% %%  Read the mosaic
% 
% sensorsize = [4224, 3136];
% %%
% 
% % Read raw data
% fid = fopen(fName, 'r');
% imMosaic = fread(fid, sensorsize, 'uint8');
% fclose(fid); clear fid;
% fprintf('Max raw value %.0f\n',max(imMosaic(:)));
% 
% imMosaic = double(imMosaic)';   % Transpose to proper orientation.
% % vcNewGraphWin, imagesc(imMosaic), axis image, colormap(gray)
% 
% % Make a sensor and stick the data into it.  We scale the data so that the
% % largest entry of the image is at the voltage swing of the pixel
% rgbcSensor = rgbcCreate;
% pixel    = sensorGet(rgbcSensor,'pixel');
% vSwing   = pixelGet(pixel,'voltage swing');
% nBits    = sensorGet(rgbcSensor,'nbits');
% imMosaic = imMosaic * (vSwing/(2^nBits-1));
% 
% % imMosaic = rot90(imMosaic,0);
% rgbcSensor = sensorSet(rgbcSensor,'volts',imMosaic);
% 
% p = sensorGet(rgbcSensor,'pattern');
% % p = rot90(p,-2); %I rotated it up above -- NS
% rgbcSensor = sensorSet(rgbcSensor,'pattern',p);

return
