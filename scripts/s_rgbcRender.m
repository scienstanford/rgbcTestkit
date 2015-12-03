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

%% Load raw image
fpRaw = fullfile(rgbcrootpath, 'data', 'raw', 'omv');
files = dir(fullfile(fpRaw, '*RGBC*'));

for ii = 1 : length(files)
    fnThisraw = files(ii).name;
    fpThisraw = fullfile(fpRaw, fnThisraw);
    [srgbL3, lrgbL3] = rgbcRender(fpThisraw, camera);
end







