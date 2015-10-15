% s_rgbcCfaCheck.m
%
% This script checks how RGBC CFA aligns with the raw image.
% 
%
% 
% QT (c) Stanford VISTA LAB 2015

clear, clc, close all

%% Load raw image
fn = '8835-1000lux-D65-color-1x-28ms-30fps.raw';
fp = fullfile(rootpath, 'data', 'raw', 'omv', fn);
raw = rgbcRawRead(fp);

raw = raw / max(raw(:));
imagesc(raw)
axis image


