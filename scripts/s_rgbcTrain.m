% s_rgbcTrain
%
% This scripts train L3 for Omnivision RGBC testkit. 
%
%
%
% (c) VISTA Lab, Stanford, 2016 March

%% Initialize
ieInit;
patchSize = [11 11];
padSize = (patchSize-1)/2;

%% Creat camera
fpCfa = fullfile(rgbcrootpath, 'data', 'cfa', 'rgbc-omv2.mat');
camera = rgbcCreate(fpCfa);

%% L3 Data object
l3d = l3DataISET;
l3d.camera = camera;

% Set illuminant properties
% illuminant levels are the brightness of the scene (cd/m2). If the camera
% is in auto-exposure mode, the exposure time is determined by the first
% entry in the illuminantLev list
l3d.illuminantLev = [70 10 20 30 40 50 60 90];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

% Training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSize;
l3t.l3c.cutPoints = {logspace(-2, -.6, 40), 1/32};
l3t.train(l3d);




