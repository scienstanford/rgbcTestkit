%% s_rgbcRawStats.m
%
% This script checks raw images for offset
%
%
%
% (c) Stanford Vista Team, 2015 Nov

clear, clc, close all

%% Initialize ISET
s_initISET

%%
fpRaw = fullfile(rgbcrootpath, 'data', 'raw', 'omv');
files = dir(fullfile(fpRaw, '*RGBC*'));

for ii = 1 : length(files)
    fnThisraw = files(ii).name;
    fpThisraw = fullfile(fpRaw, fnThisraw);
    raw = rgbcRawRead(fpThisraw);
    vals = 0 : 255;
    pdf = hist(raw(:), vals);
    figure, bar(vals, pdf)
    xlim([0, 255])
end

