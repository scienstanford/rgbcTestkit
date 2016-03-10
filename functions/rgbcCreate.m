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
% 
% Example:
%   fpCfaData = fullfile(rgbcrootpath, 'data', 'cfa', 'rgbc-omv2.mat');
%   wave = 400:10:700;
%   camera = rgbcCreate(fpCfaData, wave)
%
% QT (c) Stanford VISTA, March 2016

%% Check inputs
if ieNotDefined('cfaData'), error('Provide cfa data'); end
if ieNotDefined('wave'), wave = 400:10:700; end

%% Camera
camera = cameraCreate; % default

%% Optics
camera = cameraSet(camera, 'oi wavelength', wave);

%% Sensor
wave = 400:10:500;
camera = cameraSet(camera, 'sensor wave', wave);

sensorD = pixelCenterFillPD(sensorD, 0.45);
sensorD = sensorSet(sensorD,'dsnu level',14.1e-004); % units are volts
sensorD = sensorSet(sensorD,'prnu level',0.002218);  % units are percent

hfov = sceneGet(scenes{1},'hfov');
[rows, cols] = L3SensorSize(sensorD, hfov, scenes{1}, oi);
sensorD = sensorSet(sensorD,'size',[rows cols]);

expTime  = 0.10;  % exposure time in sec
sensorD = sensorSet(sensorD, 'exp time', expTime);

sensorD = sensorSet(sensorD, 'analog gain', 1);
sensorD = sensorSet(sensorD, 'analog offset', 0);

expTime = 0.10; % second
camera = cameraSet(camera, 'sensor exp time', expTime);

% CFA
cfaData = load(fpCfaData);   
camera = cameraSet(camera, 'sensor filter spectra', vcReadSpectra(fpCfaData, wave));
camera = cameraSet(camera, 'sensor filternames', cfaData.filterNames);
camera = cameraSet(camera, 'sensor cfa pattern and size', cfaData.filterOrder);

% Pixel 
pixel = sensorGet(sensorD,'pixel');
pixel = pixelSet(pixel,'spectralQE',ones(length(wave),1));
pixel = pixelSet(pixel,'size constant fill factor',[2.2e-6 2.2e-6]); % Pixel Size in meters
pixel = pixelSet(pixel,'conversion gain', 2.0000e-004);        % Volts/e-
pixel = pixelSet(pixel,'voltage swing', 1.8);                  % Volts/e-
pixel = pixelSet(pixel,'dark voltage', 1e-005);                % units are volts/sec
pixel = pixelSet(pixel,'read noise volts', 1.34e-003);         % units are volts












% %% These are from Olympus
% % fName = fullfile('fbOlympus');
% % filterSpectra = vcReadSpectra(fName,wave);
% % % Filter color order: r,g,b,o,c
% % 
% % fName = fullfile('ir-fbOlympus');
% % irFilter = vcReadSpectra(fName,wave);
% % 
% % sensor = sensorSet(sensor,'filter spectra',filterSpectra);
% % sensor = sensorSet(sensor,'ir filter',irFilter);
% 
% %% These are HB's measurements
% % These measurements already incorporate the IR filter.
% % fName = fullfile('fbSpectralqeRefined');
% fName = fullfile(fbRootPath,'data','sensor','fbSpectralqe');
% filterSpectra = vcReadSpectra(fName,wave);
% filterSpectra = filterSpectra./max(filterSpectra(:));
% sensor = sensorSet(sensor,'filter spectra',filterSpectra);
% 
% % Other parameters of the sensor
% pixel = sensorGet(sensor,'pixel');
% pixel = pixelSet(pixel,'sizesamefillfactor',[5e-6 5e-6]);
% pixel = pixelSet(pixel,'darkvoltage',0.000484); % Value estimated using the s_fbDarkVoltage script
% pixel = pixelSet(pixel,'readnoisevolts',0.00174);    % Value estimated using the s_fbReadNoise script
% 
% % We know that the well capacity is 24000 e but I can't find the sensor
% % voltage....
% sensor = sensorSet(sensor,'pixel',pixel);
% sensor = pixelCenterFillPD(sensor,0.5); % This is just a random fill factor guess.
% sensor = sensorSet(sensor,'quantizationmethod','12 bit');
% sensor = sensorSet(sensor,'dsnulevel',9.0664e-05); % Value estimated using the s_fbSpatialNoiseDSNU script
% sensor = sensorSet(sensor,'prnulevel',0.017); % Value estimated using the s_fbSpatialNoiseDRNU script
% 
% 
% %% Analog gain and offset
% vSwing = 1;
% fName = sprintf('%s/data/sensor/gainAndOffset.mat',fbRootPath);
% if exist(fName,'file')
%     load(fName);
%     % The gain and offset are defined for the data quantized to N bits.
%     % First let's represent the gain and offset if the data is scaled to
%     % (0,voltageSwing)
%     gain = gainTable(expIndx);
%     offset = (offsetTable(expIndx)/(2^sensorGet(sensor,'nbits')))*vSwing;
%     % Now convert the gain and offset to the form that's used in ISET
%     % voltage = (voltage + offset)/gain.
%     gain = 1/gain;
%     offset = offset*gain;
% else
%     gain = 1;
%     offset = 0;
% end
% sensor = sensorSet(sensor,'analogOffset',offset);
% sensor = sensorSet(sensor,'analogGain',gain);
% 
% 
% sensor = sensorSet(sensor,'rows',720);
% sensor = sensorSet(sensor,'cols',1280);
% 
% %%  The color filters
% 
% cfa = ...
%     [ 3 2 5 2;
%     2 4 2 1;
%     5 2 3 2;
%     2 1 2 4];
% 
% %   
% %   cfa = [2  4  2  3;
% %       5  2  1  2;
% %       2  3  2  4;
% %       1  2  5  2];  % translated using desired color order
% 
% sensor = sensorSet(sensor,'pattern and size',cfa);
% sensor = sensorSet(sensor,'filter names',{'r','g','b','o','c'});
% sensor = sensorSet(sensor,'exp time',expTime);



end

