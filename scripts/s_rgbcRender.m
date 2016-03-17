% s_rgbcRender.m
%
% This scripts renders raw images from OmniVision RGBC testkit. 
%
%
% See also s_rgbcTrain.m
%
%
% QT (c) VISTA Lab, Stanford, 2016 March

%% Initialize
ieInit;

%% L3
fpL3 = fullfile(rgbcrootpath, 'data', 'l3', 'L3_rgbc-omv1.mat');
load(fpL3);
camera = l3d.get('camera');
cfa = cameraGet(camera, 'sensor cfa pattern');

%% Scenes on Scarlet
dpScarlet = 'http://scarlet.stanford.edu/validation/SCIEN/L3/rgbc';

% for omv example images
scenes = {'omv'};
szRaw = [3264, 2448];

% % for stanford images
% szRaw = [4224, 3136];
% scenes = {'Equad_path', 'HMJ_office_1', 'HMJ_office_2', 'cro_court', 'memchu1', 'memchu1up', ...
%            'memchu1up2', 'memchu2macbeth', 'memchu3', 'memchudoor', 'quad_arcade', 'quad_arch', ...
%            'quad_light', 'sap_tower', 'tree_round'};
       

%% Render
dpRender = fullfile(rgbcrootpath, 'data', 'render');

for ii = 1 : length(scenes)
    disp(['*****' scenes{ii} '*****']);

    dpRaw = fullfile(dpScarlet, scenes{ii});
    raws = lsScarlet(dpRaw, 'raw');

    for jj = 1 : length(raws)
        disp(['**' raws(jj).name '**']);

        fpRaw = fullfile(dpRaw, raws(jj).name);
        raw = rgbcRawRead(fpRaw, szRaw); % read raw 
        raw = ieScale(raw, 0, 1/2); % scale raw

        % render
        l3r = l3Render;
        l3_xyz = l3r.render(raw, cfa, l3t);
        [~, l3_lrgb] = xyz2srgb(l3_xyz);
        l3_lrgb = ieClip(l3_lrgb / quantile(l3_lrgb(:), 0.99),0,1);
        l3_srgb = lrgb2srgb(l3_lrgb);

        % save
%         vcNewGraphWin; imshow(l3_srgb);
        [path, name, ext] = fileparts(fpRaw);
        fpRender = fullfile(dpRender, [scenes{ii} '_' name '.png']);
        imwrite(l3_srgb, fpRender);
    end
end

