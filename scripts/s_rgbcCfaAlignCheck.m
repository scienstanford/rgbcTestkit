% s_rgbccfaAlignCheck.m
%
% This script checks how RGBC CFA aligns with the raw image.
% 
%
% 
% (c) Stanford VISTA LAB, 2015

clear, clc, close all

%% Load a raw image
% % Raw images provided by Omnivision
% Use fliplr=1, rot90=0, rowstart=5, columnstart=4
% fn = '8835RGBC-1000lux-D65-color-1x-14ms-30fps.raw';
% fp = fullfile(rgbcrootpath, 'data', 'raw', 'omv', fn);
% raw = rgbcRawRead(fp);

% Raw images captured using rgbc testkit at Stanford using another ".ovd"
% file and specifications. These images are stored on scarlet.
% Use fliplr=1, rot90=0, rowstart=3, columnstart=8

fn = '1000ms_30.raw';
sltp = 'http://scarlet.stanford.edu/validation/SCIEN/L3'; % scarlet path
fp = fullfile(sltp, 'rgbc', 'memchu2macbeth', fn);
raw = rgbcRawRead(fp, [4224, 3136]);

raw = raw / max(raw(:));
imagesc(raw)
axis image

%% Load rgbc cfa
tmp = load(fullfile(rgbcrootpath, 'data', 'cfa', 'rgbc-omv0.mat'));
filterNames = tmp.filterNames;
disp(filterNames);
filterOrder = tmp.filterOrder; 
disp(filterOrder);

% Pick one pixel from one repetition CFA block from raw images for each RGB
% channel
rgbmask = false([size(filterOrder), 3]);
rgbmask(4, 6, 1) = true; filterOrder(4, 6)
rgbmask(8, 8, 2) = true; filterOrder(8, 8)
rgbmask(1, 7, 3) = true; filterOrder(1, 7)

%% Tile cfa pattern 
checkp = fullfile(rgbcrootpath, 'data', 'render', 'aligncheck');
mkdir(checkp);
delete(fullfile(checkp, '*'));

for flipflag = 1%0 : 1
    for rotnum = 0%0 : 3
        for rrstart = 3%1 : size(filterOrder, 1)
            for ccstart = 8%1 : size(filterOrder, 2)
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
                imwrite(rgb * 4, fullfile(checkp, fnRGB));
            end
        end
    end
end
