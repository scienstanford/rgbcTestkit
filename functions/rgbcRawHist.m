function [pdf, vals] = rgbcRawHist(raw)
% assume raw ranges [0, 255]
vals = 0 : 255;
pdf = hist(raw(:), vals);
figure, bar(vals, pdf), xlim([0, 255])
end