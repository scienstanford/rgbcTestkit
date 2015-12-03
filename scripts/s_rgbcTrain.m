% s_rgbcTrain
%
% This scripts train L3 for Omnivision RGBC testkit. 
%
%
%
% (c) VISTA Lab, Stanford, 2015 Oct
clear, clc, close all
ieInit

%%
fpCfa = fullfile(rgbcrootpath, 'data', 'cfa');
fpL3 = fullfile(rgbcrootpath, 'data', 'l3');
fpCamera = fullfile(rgbcrootpath, 'data', 'camera');

fnCfa = 'rgbc-omv2.mat';
fnL3 = ['L3_' fnCfa];
fnCamera = ['L3camera_' fnCfa];

%% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

%% Change CFA
scenes = L3Get(L3, 'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

sensorD = L3Get(L3, 'design sensor');
cfaData = load(fullfile(fpCfa, fnCfa));
sensorD = sensorSet(sensorD, 'filterspectra', vcReadSpectra(fnCfa,wave));
sensorD = sensorSet(sensorD, 'filter names', cfaData.filterNames);
sensorD = sensorSet(sensorD, 'cfa pattern and size', cfaData.filterOrder);
L3 = L3Set(L3, 'design sensor', sensorD);

L3.training.patchSize = 11;

%% Perform training
tic
L3 = L3Train(L3);
toc
save(fullfile(fpL3, fnL3), 'L3');

%% Setup and save L3 camera
L3camera = L3CameraCreate(L3);
save(fullfile(fpCamera, fnCamera), 'L3camera');





