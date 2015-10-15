clear, clc, close all

fid = fopen('8835-10lux-D65-color-15,5x-66ms-15fps.raw','r');
col = 2448;  
row = 3264;
I = fread(fid, row*col); 
fclose(fid);test

RAW = reshape(I, row, col);
RAW = RAW';
imagesc(RAW / max(RAW(:)))
axis image
