clear, clc, close all

%%
cfaFile = 'RGBC.mat';

%% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

%% Change CFA
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

sensorD = L3Get(L3,'design sensor');
cfaData = load(cfaFile);
sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile,wave));
sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
sensorD = sensorSet(sensorD,'cfa pattern and size',cfaData.filterOrder);
L3 = L3Set(L3,'design sensor', sensorD);

L3.training.patchSize = 13;

%% Perform training
L3 = L3Train(L3);

%% Setup and save L3 camera
L3camera = L3CameraCreate(L3);
save('L3camera_RGBC', 'L3camera');