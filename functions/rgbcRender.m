function [srgbL3, lrgbL3, srgbBasic, lrgbBasic] = rgbcRender(raw, camera, fnRender, pathRender, basicflag)
% Render raw images from RGBC testkit using a camera that stores learned L3
% filters.
%
%
%
% (c) Stanford VISTA Lab, Nov 2015

if ~exist('pathRender', 'var')
    pathRender = fullfile(rgbcrootpath, 'data', 'render');
    mkdir(pathRender);
end 

if ~exist('fnRender', 'var')
    fnRender = 'render';
end 

if ~exist('basicflag', 'var')
    basicflag = false;
end 

%% Set sensor image
rgbcSensor = cameraGet(camera, 'sensor');
rgbcSensor = sensorSet(rgbcSensor, 'volts', raw * sensorGet(rgbcSensor,'pixel voltage swing'));
camera = cameraSet(camera, 'sensor', rgbcSensor);

%% L3 pipeline
% calculate linear RGB results
camera = cameraSet(camera, 'vci name', 'L3');
[camera, lrgbL3] = cameraCompute(camera, 'sensor'); % sensor image is already loaded into the camera

% Crop border
L3 = cameraGet(camera, 'l3');
lrgbL3 = L3imcrop(L3, lrgbL3); 

% % scale linear RGB 
% satPercent = 100;
% prctileSatL3 = prctile(lrgbL3(:), satPercent);
% lrgbL3Scaled = lrgbL3 / prctileSatL3;

% Or set the mean luminance
meanLuminance = 24;
lrgbL3Scaled = lrgbL3 / max(lrgbL3(:)) * meanLuminance;

% Convert to sRGB
srgbL3 = lrgb2srgb(ieClip(lrgbL3Scaled, 0, 1));

% show results
figure, imshow(srgbL3), title('L3');

% save results
fnLrgbL3 = ['sRGBL3_' fnRender '.mat'];
save(fullfile(pathRender, fnLrgbL3), 'lrgbL3');

fnSrgbL3 = ['sRGBL3_' fnRender '.png'];
imwrite(srgbL3, fullfile(pathRender, fnSrgbL3));

%% ISET basic pipeline
if basicflag
    % calculate linear RGB results 
    camera = cameraSet(camera, 'vci name', 'default');
    [camera, lrgbBasic] = cameraCompute(camera, 'sensor');

    % Crop border
    L3 = cameraGet(camera, 'l3');
    lrgbBasic = L3imcrop(L3, lrgbBasic); 

    % % scale linear RGB 
    % satPercent = 100;
    % prctileSatBasic = prctile(lrgbBasic(:), satPercent);
    % lrgbBasicScaled = lrgbBasic / prctileSatBasic;

    % Or set the mean luminance
    meanLuminance = 10;
    lrgbBasicScaled = lrgbBasic / max(lrgbBasic(:)) * meanLuminance;

    % convert to sRGB
    srgbBasic = lrgb2srgb(ieClip(lrgbBasicScaled, 0, 1));

    % show results
    figure, imshow(srgbBasic), title('ISET Basic');

    % Save results
    fnSrgbBasic = ['sRGBBasic_' fnRender '.png'];
    imwrite(srgbBasic, fullfile(pathRender, fnSrgbBasic));
end

end