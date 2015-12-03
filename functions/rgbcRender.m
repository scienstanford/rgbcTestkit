function [srgbL3, lrgbL3, srgbBasic, lrgbBasic] = rgbcRender(fpRaw, camera, fpRender)
% Render raw images from RGBC testkit using a camera that stores learned L3
% filters.
%
%
%
% (c) Stanford VISTA Lab, Nov 2015

if ~exist('fpRender', 'var')
    fpRender = fullfile(rgbcrootpath, 'data', 'render', 'l3');
    mkdir(fpRender);
end 

%% Read a raw image
raw = rgbcRawRead(fpRaw);
raw = raw / max(raw(:));
imagesc(raw)
axis image

%% Set sensor image
rgbcSensor = cameraGet(camera, 'sensor');
rgbcSensor = sensorSet(rgbcSensor, 'volts', raw * sensorGet(rgbcSensor,'pixel voltage swing'));
camera = cameraSet(camera, 'sensor', rgbcSensor);

%% Calculate linear RGB results of L3 and Basic pipelines
camera = cameraSet(camera, 'vci name', 'L3');
[camera, lrgbL3] = cameraCompute(camera, 'sensor'); % sensor image is already loaded into the camera

camera = cameraSet(camera, 'vci name', 'default');
[camera, lrgbBasic] = cameraCompute(camera, 'sensor');

% Crop border
L3 = cameraGet(camera, 'l3');
lrgbL3 = L3imcrop(L3, lrgbL3); 
lrgbBasic = L3imcrop(L3, lrgbBasic); 

%% Scale linear RGB 
% satPercent = 100;
% 
% prctileSatL3 = prctile(lrgbL3(:), satPercent);
% lrgbL3Scaled = lrgbL3 / prctileSatL3;
% 
% prctileSatBasic = prctile(lrgbBasic(:), satPercent);
% lrgbBasicScaled = lrgbBasic / prctileSatBasic;

% Or set the mean luminance
meanLuminance = 1;
lrgbL3Scaled = lrgbL3 / max(lrgbL3(:)) * meanLuminance;
lrgbBasicScaled = lrgbBasic / max(lrgbBasic(:)) * meanLuminance;

%% Convert to sRGB
srgbL3 = lrgb2srgb(ieClip(lrgbL3Scaled, 0, 1));
srgbBasic = lrgb2srgb(ieClip(lrgbBasicScaled, 0, 1));

%% Show results
figure, imshow(srgbL3), title('L3');
figure, imshow(srgbBasic), title('ISET Basic');

%% Save results
[path, fnRaw, ext] = fileparts(fpRaw);

fnSrgbL3 = ['sRGBL3_' fnRaw '.png'];
fnSrgbBasic = ['sRGBBasic_' fnRaw '.png'];

imwrite(srgbL3, fullfile(fpRender, fnSrgbL3));
imwrite(srgbBasic, fullfile(fpRender, fnSrgbBasic));

end