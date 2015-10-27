% s_rgbccfaAlignCheck.m
%
% This script checks how RGBC CFA aligns with the raw image.
% 
%
% 
% QT (c) Stanford VISTA LAB, 2015

clear, clc, close all

%% Load a raw image
fn = '8835RGBC-1000lux-D65-color-1x-14ms-30fps.raw';
fp = fullfile(rootpath, 'data', 'raw', 'omv', fn);
raw = rgbcrawRead(fp);

raw = raw / max(raw(:));
imagesc(raw)
axis image

%% Load rgbc cfa
tmp = load(fullfile(rootpath, 'data', 'cfa', 'rgbc-omv.mat'));
filterNames = tmp.filterNames;
disp(filterNames);
filterOrder = tmp.filterOrder; 
disp(filterOrder);

rgbmask = false([size(filterOrder), 3]);
rgbmask(4, 6, 1) = true;
rgbmask(5, 3, 2) = true;
rgbmask(4, 8, 3) = true;

%% Tile cfa pattern 
checkp = fullfile(rootpath, 'data', 'render', 'aligncheck');
mkdir(checkp);

for flipflag = 0 : 1
    for rotnum = 0 : 3
        for rrstart = 1 : size(filterOrder, 1)
            for ccstart = 1 : size(filterOrder, 2)
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
