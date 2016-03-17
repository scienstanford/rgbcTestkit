function camera = rgbcCreate(fpCfaData, wave)
% Create an ISET camera model of the RGBC testkit.
%
% camera = rgbcCreate(wave, cfa);
%
% Inputs:
%   fpCfaData: 
%       File path to the desired CFA structure that contains QE and spatial
%       layout information. 
%       Cfa data are generated using s_rgbcCfaCreate.m script and are 
%       stored in data/cfa.
%   wave: 
%       desired wavelength.  
%
% Outputs:
%   camera: 
%       ISET camera model.
% 
% Example:
%   fpCfaData = fullfile(rgbcrootpath, 'data', 'cfa', 'rgbc-omv2.mat');
%   wave = 400:10:700;
%   camera = rgbcCreate(fpCfaData, wave);
%   sensor = cameraGet(camera,'sensor');
%   sensorShowCFA(sensor)
%   sensorPlot(sensor,'spectral qe')
%
% QT (c) Stanford VISTA, March 2016

%% Check inputs
if ieNotDefined('fpCfaData'), error('Provide cfa data'); end
if ieNotDefined('wave'), wave = 400:10:700; end

%% Camera
camera = cameraCreate; % default

%% Optics
camera = cameraSet(camera, 'oi wavelength', wave);

%% Pixel properties
% wave = 400:10:500;
camera = cameraSet(camera, 'sensor wave', wave);

% From the sheet
pixelSize = 1.4e-6;   % Meters
camera = cameraSet(camera,'pixel size same fill factor',pixelSize);

% Not sure where this comes from
fillFactor = 0.45;
pdSize = pixelSize*sqrt(fillFactor);
camera = cameraSet(camera, 'pixel pd width and height',[pdSize,pdSize]);
% cameraGet(camera,'pixel fill factor')

% From the Omnivision sheet
cGain = 118e-006;   % V/e-
camera = cameraSet(camera,'pixel conversion gain',cGain);  % V/e-

% From the sheet
vSwing = 5404*cGain;
camera = cameraSet(camera,'pixel voltage swing', vSwing);      % Volts

% Sheet gives electrons per second
darkVoltage = 57*cGain;    % V/sec
camera = cameraSet(camera,'pixel dark voltage', darkVoltage);             % units are volts/sec

% Depends on the gain
g = cameraGet(camera,'sensor analog gain');
% Read noise container
rn = containers.Map({1,16},{4.3*cGain,2.2*cGain});

camera = cameraSet(camera,'sensor read noise volts',rn(g));      % units are volts
% cameraGet(camera,'sensor read noise volts')

%% Sensor CFA

% Spectral quantum efficiency
filterSpectra = vcReadSpectra(fpCfaData, wave);
camera = cameraSet(camera, 'sensor filter spectra', filterSpectra);

% CFA structure
load(fpCfaData, 'filterNames');   
camera = cameraSet(camera, 'sensor filternames', filterNames);

load(fpCfaData, 'filterOrder');   
camera = cameraSet(camera, 'sensor cfa pattern and size', filterOrder);

load(fpCfaData, 'name');   
camera = cameraSet(camera, 'name', name);

% Pixel substract quantum efficiency is set to 1 because all of the
% spectral quantum efficiency is grouped into the filter
% camera = cameraSet(camera,'pixel spectral QE',ones(length(wave),1));
% cameraGet(camera,'pixel spectral QE')

%% Sensor electrical noise

% Units are standard deviation of the mean dark signal, which should be
% zero.

% From the sheet the (DINU) is like the std dev of the dark voltage
% About 11.9% (max dc - min dc)/ average dc
dsnuLevel = darkVoltage*0.119;   % Std dev of the dark voltage
camera = cameraSet(camera,'sensor dsnu level',dsnuLevel); % units are volts.

% This is the std. dev. of the slope
% units are percent of the slope.  So 1 means 1 percent variation in the
% slope of volts vs. irradiance
camera = cameraSet(camera,'sensor prnu level',0.8); 

% exposure time in sec
expTime  = 0.10;  
camera = cameraSet(camera, 'sensor exp time', expTime);

% Leave the gain and offset at the default of 1 and 0
% We could set it later and do experiments changing the analog gain
%
% cameraGet(camera,'sensor analog gain')
% cameraGet(camera,'sensor analog offset')

end


