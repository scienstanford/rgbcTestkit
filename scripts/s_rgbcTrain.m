% s_rgbcTrain.m
%
% This scripts train L3 for Omnivision RGBC testkit. 
%
%
%
% QT (c) VISTA Lab, Stanford, 2016 March

%% Initialize
ieInit;

%%
dpCfa = fullfile(rgbcrootpath, 'data', 'cfa');
cfas = {'rgbc-omv1.mat', 'rgbc-omv2.mat'};

for ii = 1 : length(cfas)
    %% Create camera
    fpCfa = fullfile(dpCfa, cfas{ii}); % cfa path
    camera = rgbcCreate(fpCfa); % create camera
    disp(['*****' camera.name '*****']);
    
    %% L3 data
    l3d = l3DataISET;
    l3d.camera = camera;
    
    % Set illuminant properties
    % illuminant levels are the brightness of the scene (cd/m2). If the camera
    % is in auto-exposure mode, the exposure time is determined by the first
    % entry in the illuminantLev list
    l3d.illuminantLev = [1 5 10 20 30 40 50 60 70 80 90];
    l3d.inIlluminantSPD = {'D65'};
    l3d.outIlluminantSPD = {'D65'};
    
    %% L3 training
    tic
    l3t = l3TrainRidge();
    patchSize = [11 11];
    l3t.l3c.patchSize = patchSize;
    l3t.l3c.cutPoints = {logspace(-2, -.6, 40), 1/32};
    l3t.train(l3d);
    toc
    
    %% Save L3
    fpSave = fullfile(rgbcrootpath, 'data', 'l3', ['L3_' l3d.camera.name '.mat']);
    save(fpSave, 'l3d', 'l3t', '-v7.3');
    
end

%%


















