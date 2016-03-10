% s_rgbccfaAlignCheck.m
%
% This script checks how RGBC CFA aligns with the raw image. 
% 
% Specifically all possible cases of flip/rotation/shift of the original
% CFA repetition block are created. A pixel for each red, green and blue
% color is selected of a block across the entire raw image to produce a low
% resolution rgb image. Then visually check which image has correct color
% and therefore determine the correct flip/rotation/shift of the original
% CFA block.
% 
%
% 
% QT (c) Stanford VISTA LAB, Oct 2015

clear, clc, close all

%% Load raw images provided by Omnivision
% Results: fliplr=1, rot90=0, rowstart=5, columnstart=4

% fn = '8835RGBC-1000lux-D65-color-1x-14ms-30fps.raw';
% fp = fullfile(rgbcrootpath, 'data', 'raw', 'omv', fn);
% raw = rgbcRawRead(fp);

%% Load raw images captured at Stanford. 
% These images were captured using different settings, which were specified
% by the ".ovd" file provided by OmniVision. These images are stored on scarlet.
% Results: fliplr=1, rot90=0, rowstart=3, columnstart=8

fnRaw = '1000ms_30.raw';
dpScarlet = 'http://scarlet.stanford.edu/validation/SCIEN/L3'; % scarlet path
fpRaw = fullfile(dpScarlet, 'rgbc', 'memchu2macbeth', fnRaw);
raw = rgbcRawRead(fpRaw, [4224, 3136]);

raw = raw / max(raw(:));
imagesc(raw)
axis image

%% Load original rgbc cfa
tmp = load(fullfile(rgbcrootpath, 'data', 'cfa', 'rgbc-omv0.mat'));
filterNames = tmp.filterNames;
disp(filterNames);
filterOrder = tmp.filterOrder; 
disp(filterOrder);

%% Pick one pixel from a repetition block for each RGB channel
% Refer to docs/Gen2 readme.docx
rgbmask = false([size(filterOrder), 3]);
rgbmask(4, 6, 1) = true; filterOrder(4, 6)
rgbmask(8, 8, 2) = true; filterOrder(8, 8)
rgbmask(1, 7, 3) = true; filterOrder(1, 7)

%% Tile cfa pattern 
dpAlignCheck = fullfile(rgbcrootpath, 'data', 'aligncheck');
mkdir(dpAlignCheck);
delete(fullfile(dpAlignCheck, '*'));

for flipflag = 0 : 1 % left right flip
    for rotnum = 0 : 3 % rotate rotnum*90 degree counterclockwise
        for rrstart = 1 : size(filterOrder, 1) % row shift
            for ccstart = 1 : size(filterOrder, 2) % column shift
                rgb = zeros([size(raw) ./ size(filterOrder), 3]);
                for ch = 1 : 3
                    mask = rgbmask(:, :, ch);
                    
                    if flipflag == 1
                        mask = fliplr(mask);
                    end
                    
                    mask = rot90(mask, rotnum);
                    
                    tmp = repmat(mask, [2, 2]);
                    mask = tmp(rrstart : rrstart + size(mask, 1) - 1, ccstart : ccstart + size(mask, 1) - 1);
                    [rr0, cc0] = find(mask);
                    rgb(:, :, ch) = raw(rr0 : size(mask, 1) : end, cc0 : size(mask, 2) : end);
                end
                fnRGB = ['rgb_fliplr' num2str(flipflag) '_rotnum' num2str(rotnum) '_rrstart' ...
                        num2str(rrstart) '_ccstart' num2str(ccstart) '.png'];
                imwrite(rgb * 4, fullfile(dpAlignCheck, fnRGB));
            end
        end
    end
end
