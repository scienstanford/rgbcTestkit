clear, clc, close all

[NUM,TXT,RAW]=xlsread('1.4um RGBC QE.xlsx');

%%
wavelength = NUM(:, 1);
r = NUM(:, 2);
g = NUM(:, 3);
b = NUM(:, 4);
w = NUM(:, 5);

figure, plot(wavelength, [r, g, b, w])


name = 'RGBC';
comment = 'For test.';
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
save(name,'comment','data','filterNames','filterOrder','wavelength')