% s_rgbccfaCreat.m
%
% This script creates RGBC CFA using the QE and the spatial layout provided
% by Omnivision. The documentes are included in the "documents" directory. 
% 
% Note there might be flip, rotation and shift for the CFA repetition block
% to align with raw image. This is because the RGBC has high resolution and
% was set to crop the raw image after the capture. High resolution requires
% high bandwidth reading raw images from the testkit, which is especially
% an issue when using the RGBC testkit to capture videos. 
%
% Run script s_rgbccfaAlignCheck.m determine how the CFA block should be
% modified.
%
% See also s_rgbcCfaAlignCheck.m
% 
% QT (c) Stanford VISTA LAB, 2015
clear, clc, close all

%%
fn = '1.4um RGBC QE.xlsx';
fp = fullfile(rgbcrootpath, 'documents', fn);

[num, txt, raw] = xlsread(fp);
wavelength = num(:, 1);
r = num(:, 2);
g = num(:, 3);
b = num(:, 4);
w = num(:, 5);

figure
hold on
plot(wavelength, r, 'r');
plot(wavelength, g, 'g');
plot(wavelength, b, 'b');
plot(wavelength, w, 'k');
grid on
xlabel('wavelength (nm)');
ylabel('sensitivities');
saveas(gcf, fullfile(rgbcrootpath, 'data', 'cfa', 'QE.png'));

name = 'rgbc-omv0';
comment = 'Original Omnivision RGBC CFA using the provided spectral sensitivities';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [3, 4, 1, 4, 1, 4, 3, 4;
               4, 2, 4, 3, 4, 3, 4, 2;
               1, 4, 2, 4, 2, 4, 1, 4;
               4, 3, 4, 1, 4, 1, 4, 3;
               1, 4, 2, 4, 2, 4, 1, 4;
               4, 3, 4, 1, 4, 1, 4, 3;
               3, 4, 1, 4, 1, 4, 3, 4;
               4, 2, 4, 3, 4, 3, 4, 2];
save(fullfile(rgbcrootpath, 'data', 'cfa', name), 'comment', 'data', 'filterNames', 'filterOrder', 'wavelength');

name = 'rgbc-omv1';
comment = 'Flipped and shifted Omnivision RGBC CFA for raw images povided by Omnivation';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = fliplr(filterOrder); % flip
tmp = repmat(filterOrder, [2, 2]); % replicate twice in row and col
filterOrder = tmp(5 : 12, 4 : 11); % shift
save(fullfile(rgbcrootpath, 'data', 'cfa', name), 'comment', 'data', 'filterNames', 'filterOrder', 'wavelength');

name = 'rgbc-omv2';
comment = 'Flipped and shifted Omnivision RGBC CFA for raw images captured at Stanford';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = fliplr(filterOrder); % flip
tmp = repmat(filterOrder, [2, 2]); % replicate twice in row and col
filterOrder = tmp(3 : 10, 8 : 15); % shift
save(fullfile(rgbcrootpath, 'data', 'cfa', name), 'comment', 'data', 'filterNames', 'filterOrder', 'wavelength');


