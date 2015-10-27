%% s_SPIE2014FB_Figure4_Render
%
% This script is to render images on a real five-band camera using L3 and
% ISET basic pipeline for Figure 4 of SPIE 2014 paper.
%
%
%
% (c) Stanford Vista Team, Jan 2015

clear, clc, close all

%% Initialize ISET
s_initISET

%% Load camera
tmp = load('L3camera_RGBC.mat');
camera = tmp.L3camera;
L3 = cameraGet(camera, 'l3');

%% Render RGBC raw images
% Load raw image
fid = fopen('8835-10lux-D65-color-15,5x-66ms-15fps.raw','r');
col = 2448;  
row = 3264;
I = fread(fid, row*col); 
fclose(fid);

RAW = reshape(I, row, col);
% RAW = RAW';
RAW = rot90(RAW, -1);
RAW = RAW / max(RAW(:)) * 1.8;
imagesc(RAW)

%% Set sensor image
fbSensor = cameraGet(camera, 'sensor');
fbSensor = sensorSet(fbSensor,'volts',RAW);
camera = cameraSet(camera, 'sensor', fbSensor);

%% Calculate linear RGB results of L3 and Basic pipelines
camera = cameraSet(camera, 'vci name', 'L3');
[camera,lrgbL3] = cameraCompute(camera, 'sensor'); % sensor image is already loaded into the camera

camera = cameraSet(camera, 'vci name', 'default');
[camera, lrgbBasic] = cameraCompute(camera, 'sensor');

% Crop border
lrgbL3 = L3imcrop(L3, lrgbL3); 
lrgbBasic = L3imcrop(L3, lrgbBasic); 

%% Scale and convert to sRGB
satPercent = 99;

prctileSatL3 = prctile(lrgbL3(:), satPercent);
lrgbL3Scaled = lrgbL3 / prctileSatL3;

prctileSatBasic = prctile(lrgbBasic(:), satPercent);
lrgbBasicScaled = lrgbBasic / prctileSatBasic;

%     % Or set the mean luminance
%     meanLuminance = 1;
%     lrgbL3scaled = lrgbL3 / max(lrgbL3(:)) * meanLuminance;
%     lrgbBasicscaled = lrgbBasic / max(lrgbBasic(:)) * meanLuminance;

srgbL3 = lrgb2srgb(ieClip(lrgbL3Scaled,0,1));
srgbBasic = lrgb2srgb(ieClip(lrgbBasicScaled,0,1));

%% Show results
figure, imshow(srgbL3), title('L3');
figure, imshow(srgbBasic), title('ISET Basic');

imwrite(srgbL3, 'rgbc3.png');
% %% Save results
% saveL3 = fullfile(L3rootpath, 'spie2014fb', 'Figure4', [thisFileName '_sat' num2str(satPercent) '_L3.png']);
% imwrite(srgbL3, saveL3);
% saveBasic = fullfile(L3rootpath, 'spie2014fb', 'Figure4', [thisFileName '_sat' num2str(satPercent) '_Basic.png']);
% imwrite(srgbBasic, saveBasic);





