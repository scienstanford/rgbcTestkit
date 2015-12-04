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
pathRaw = 'http://scarlet.stanford.edu/validation/SCIEN/L3/rgbc/memchu2macbeth';
files = lsScarlet(pathRaw, 'raw');
rawSz = [4224, 3136];

for ii = 1 %: length(files)
    fnRaw = files(ii).name;
    fpRaw = fullfile(pathRaw, fnRaw);
    
    % Read a raw image
    raw = rgbcRawRead(fpRaw, rawSz);
    figure, imagesc(raw), axis image
     
    vals = 0 : 255;
    pdf = hist(raw(:), vals);
    figure, bar(vals, pdf)
    xlim([0, 255])
end

