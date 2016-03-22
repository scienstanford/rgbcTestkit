% s_rgbcTrain.m
%
% This scripts train L3 for Omnivision RGBC testkit. 
%
%
% See also s_rgbcRender.m
%
% 
% QT (c) VISTA Lab, Stanford, 2016 March

%% Initialize
ieInit;

%%
dpCfa = fullfile(rgbcrootpath, 'data', 'cfa');
cfas = {'rgbc-omv2.mat', 'rgbc-omv1.mat'};
patchSize = [11 11];

for ii = 1 : length(cfas)
    %% Create camera
    fpCfa = fullfile(dpCfa, cfas{ii}); % cfa path
    camera = rgbcCreate(fpCfa); % create camera
    disp(['*****' camera.name '*****']);
    
    %% L3 data
    l3d = l3DataISET;
    l3d.camera = camera;
    cfapattern = cameraGet(camera, 'sensor cfa pattern'); 
    
    % Set illuminant properties
    % illuminant levels are the brightness of the scene (cd/m2). If the camera
    % is in auto-exposure mode, the exposure time is determined by the first
    % entry in the illuminantLev list
    l3d.illuminantLev = [0.1 1 5 10 20 30 40 50 60 70 80 90];
    l3d.inIlluminantSPD = {'D65'};
    l3d.outIlluminantSPD = {'D65'};
    
    %% L3 training
    l3t = l3TrainRidge();
    l3t.l3c.patchSize = patchSize;

    vSwing = cameraGet(l3d.camera, 'pixel voltage swing');
    linearThresholds = logspace(log10(0.01), log10(vSwing * 0.95), 40); % 0.01 to 0.95*vSwing
    
    contrast = {[]};
    
    vSat = 0.95 * vSwing;
    satThresholds = {vSat, vSat, vSat, vSat};
    pixelTypeName = arrayfun(@(x) sprintf('Pixel %d', x), cfapattern, 'UniformOutput', false);    

    l3t.l3c.cutPoints = cat(2, linearThresholds, contrast, satThresholds);
    l3t.l3c.statFunc = {@imagePatchMeanAndContrast, @imagePatchMax};
    l3t.l3c.statFuncParam = {{}, {}};
    l3t.l3c.statNames = [{'mean'}, {'contrast'}, pixelTypeName(:)'];
    
    tic
    l3t.train(l3d);
    toc
    
    %% Save L3
    l3t.l3c.clearData() % clear training data
    fpSave = fullfile(rgbcrootpath, 'data', 'l3', ['L3_' l3d.camera.name '.mat']);
    save(fpSave, 'l3d', 'l3t', '-v7.3');    
end


















