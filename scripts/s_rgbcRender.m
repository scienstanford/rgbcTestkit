%% s_rgbcRender.m
%
% This script renders raw image from Omnivision RGBC testkit using L3 and
% ISET basic pipeline.
%
%
%
% (c) Stanford Vista Team, 2015 Oct

clear, clc, close all

%% Initialize ISET
s_initISET
 
%% Load camera
fpCamera = fullfile(rgbcrootpath, 'data', 'camera');
fnCamera = 'L3camera_rgbc-omv1.mat';

tmp = load(fullfile(fpCamera, fnCamera));
camera = tmp.L3camera;

%% Load omv raw images
pathRaw = fullfile(rgbcrootpath, 'data', 'omv');
files = dir(fullfile(pathRaw, '*RGBC*raw'));
rawSz = [3264, 2448];

for ii = 1 %: length(files)
    fnRaw = files(ii).name;
    fpRaw = fullfile(pathRaw, fnRaw);
    
    % read a raw image
    raw = rgbcRawRead(fpRaw, rawSz);
    
    % pixel value hist
    rgbcRawHist(raw)
    offset = 3;
    
    raw = raw - offset; % remove offset
    raw(raw <= 0) = 0;
    raw = raw / max(raw(:));
    figure, imagesc(raw), axis image
    
    [srgbL3, lrgbL3] = rgbcRender(raw, camera, fnRaw);
end



%% Load stanford raw images from scarlet
pathRaw = 'http://scarlet.stanford.edu/validation/SCIEN/L3/rgbc/memchu2macbeth';
files = lsScarlet(pathRaw, 'raw');
rawSz = [4224, 3136];

for ii = 1 %: length(files)
    fnRaw = files(ii).name;
    fpRaw = fullfile(pathRaw, fnRaw);
    
    % Read a raw image
    raw = rgbcRawRead(fpRaw, rawSz);
    raw = raw / max(raw(:));
    figure, imagesc(raw), axis image
    
%     [srgbL3, lrgbL3] = rgbcRender(fpRaw, camera);
end







