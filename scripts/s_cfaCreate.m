clear, clc, close all

%%
fn = '1.4um RGBC QE.xlsx';
fp = fullfile(rootpath, 'documents', fn);

[num, txt, raw] = xlsread(fp);
wavelength = num(:, 1);
r = num(:, 2);
g = num(:, 3);
b = num(:, 4);
w = num(:, 5);

figure, plot(wavelength, [r, g, b, w])

name = 'rgbc-omv';
comment = 'Omnivision RGBC CFA using the provided spectral sensitivities';
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
save(fullfile(rootpath, 'data', 'cfa', name),'comment','data','filterNames','filterOrder','wavelength');