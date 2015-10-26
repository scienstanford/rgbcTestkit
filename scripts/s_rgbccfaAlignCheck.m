% s_rgbccfaAlignCheck.m
%
% This script checks how RGBC CFA aligns with the raw image.
% 
%
% 
% (c) Stanford VISTA LAB, 2015

clear, clc, close all

%% Load a raw image
fn = '8835-1000lux-D65-color-1x-28ms-30fps.raw';
fp = fullfile(rootpath, 'data', 'raw', 'omv', fn);
raw = rgbcrawRead(fp);

raw = raw / max(raw(:));
imagesc(raw)
axis image

%%
filterOrder = [2, 0, 2, 0, 1, 0, 1, 0;
               0, 1, 0, 3, 0, 3, 0, 1;
               1, 0, 1, 0, 3, 0, 3, 0;
               0, 3, 0, 2, 0, 2, 0, 3;
               1, 0, 1, 0, 3, 0, 3, 0;
               0, 3, 0, 2, 0, 2, 0, 3;
               2, 0, 2, 0, 1, 0, 1, 0;
               0, 1, 0, 3, 0, 3, 0, 1];
sz = size(filterOrder);
rgb = zeros(size(raw) ./ sz);
rgb(:, :, 1) = raw(2 : sz(1) : end, 2 : sz(2) : end);
rgb(:, :, 2) = raw(1 : sz(1) : end, 1 : sz(2) : end);
rgb(:, :, 3) = raw(4 : sz(1) : end, 2 : sz(2) : end);

figure, imshow(rgb);

