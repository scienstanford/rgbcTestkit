%% s_rgbcIlluminantEstimation
%
% Illuminant estimation with the rgbc
close all; clear all; clc;
s_initISET

illuminantTemperatureMired = linspace(100,300,6);
illuminantTemperature = 1./illuminantTemperatureMired*1000000;

nVectorsPerTemp = 50;
nTemps = length(illuminantTemperature);

%% Create a matrix of illuminants and check the dimensionality of the space
illSpectra = [];
for i=1:nTemps
    illSpectra = [illSpectra, blackbody(400:10:700,illuminantTemperature(i),'photons')];
end

figure;
plot(sort(eig(cov(illSpectra')),'descend'));
title('Illuminant');
ylabel('Cov. mat. eigenvalue');

%% Define how scenes will be created

% The files containing the reflectances are in ISET format, readable by 
sFiles = cell(1,4);
sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','Food_Vhrel.mat');
sFiles{3} = fullfile(isetRootPath,'data','surfaces','reflectances','DupontPaintChip_Vhrel.mat');
sFiles{4} = fullfile(isetRootPath,'data','surfaces','reflectances','HyspexSkinReflectance.mat');

% The number of samples from each of the data sets, respectively
sSamples = [12,12,24,24];    

% How many row/col spatial samples in each patch (they are square)
pSize = 24;    % Patch size
wave =[];      % Whatever is in the file
grayFlag = 0;  % No gray strip
sampling = 'no replacement';

%% Create a five band camera (sensor and optics)

[sensor, optics] = rgbcCreate;
sensor = sensorSet(sensor,'exp time',0.02);
sensor = sensorSet(sensor,'noise flag',0);

oi = oiCreate;
oi = oiSet(oi,'optics',optics);

% Initialize container variables
svdData = cell(nTemps,nVectorsPerTemp);
svdScore = cell(nTemps,nVectorsPerTemp);
for t=1:nTemps
    fprintf('Generating temperature %i K\n',illuminantTemperature(t));
for n=1:nVectorsPerTemp

    [scene,~,reflectances] = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling);    
    bb = blackbody(sceneGet(scene,'wave'),illuminantTemperature(t));
    scene = sceneAdjustIlluminant(scene,bb);
    vcAddObject(scene); 
    
        % Multiply the reflectances with every illuminant check the space
        % dimensionality
%         tst = [];
%         for i=1:nTemps
%             tst = [tst, diag(illSpectra(:,i))*reflectances];
%         end
%         figure;
%         plot(sort(eig(cov(tst')),'descend'));
%         title('Illuminant $\times$ reflectance','interpreter','latex');
%         ylabel('Cov. mat. eigenvalue');
    

    oi = oiCompute(oi,scene);
    vcAddObject(oi);
    
    sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
    sensor = sensorCompute(sensor,oi);
    vcAddObject(sensor); 

    v = sensorGet(sensor,'volts');
    sensorSize = size(v);
    pattern = sensorGet(sensor,'pattern');
    spSize = size(pattern);

    % We want a routine that goes through each super-pixel and produces the
    % average value of the 5 bands.
    rows = 1:spSize(1):sensorSize(1);
    cols = 1:spSize(2):sensorSize(2);
    nChannels = max(pattern(:));
    resp = zeros(nChannels,length(rows)*length(cols));
    idx = 1;
    for rr = rows
        for cc = cols
            vSP  = v(rr:(rr+spSize(1)-1),cc:(cc+spSize(2)-1));
            for ii=1:nChannels
                lst = find(pattern(:) == ii);
                resp(ii,idx) = mean(vSP(lst))';
            end
            idx = idx + 1;
        end
    end

    % Extract the principal vectors V, and the corresponding variances
    % 'score'
    [V, ~, score] = pca(resp');
    svdData{t,n} = V;
    svdScore{t,n} = score;
    
end

% Cleanup ISET data (is there a better way to do this?)

vcSESSION.SCENE = {[]};
vcSESSION.OPTICALIMAGE = {[]};
vcSESSION.ISA = {[]};

end

save('VectorData.mat','svdData','svdScore');

%% Analyze the principal components extracted from images
for k=1:4
    
    % First assemble the k-th PC from all the scenes and illuminants
    PCs = [];
    labels = [];
    temperatures = [];
    for t=1:nTemps
    for i=1:nVectorsPerTemp
        PCs = [PCs, svdData{t,i}(:,k)];
        labels = [labels, t];
        temperatures = [temperatures, illuminantTemperature(t)];
    end
    end
    
    % Now we need to make sure that PCs are oriented the same way. If v is
    % one of the principal components so will be -v. Let's take as an
    % arbitrary reference the unit vector e_1 = (1,0,0,0,0). We want all
    % the v's to form an acute angle with e_1, i.e. v'*e >= 0, if this
    % condition is not satisfied we change the sign.
    
    PCs(:,PCs(1,:) <= 0) = -PCs(:,PCs(1,:) <= 0);

    % Now run the PCA on the collection of k-th PCA vector
    % Display the projections on the first 2 coordinates.
    [dirs, pcaProj] = pca(PCs','Centered',false);
    figure;
    style = {'rx','go','b^','cd','ms','yx','kp'};
    hold on; grid on; box on;
    for t=1:nTemps
        plot(pcaProj(labels==t,1),pcaProj(labels==t,2),style{t});
    end
    xlabel('Component 1');
    ylabel('Component 2');
    xlim([-1, 1]);
    ylim([-1,1]);
    title(sprintf('2D projection of the %i th scene PC',k));
    
%     %% SVM classification
%     
%     % Let's see how well would an linear SVM do at classification
%     % Search for the best cost parameter
%     bestcv = 0;
%     for log2c = -5:20,
%         cmd = ['-q -v 5 -t 0 -c ', num2str(2^log2c)];
%         cv = svmtrain(labels',PCs', cmd);
%         if (cv >= bestcv),
%           bestcv = cv; bestc = 2^log2c;
%         end
%     end
%     
%     cmd = ['-q -t 0 -c ', num2str(bestc)];
%     SVMmodel = svmtrain(labels',PCs',cmd);
%     [pred,acc,~] = svmpredict(labels',PCs',SVMmodel);
%     
%     svmConfMat = zeros(nTemps);
%     for i=1:nTemps
%     for j=1:nTemps
%        svmConfMat(i,j) = sum(pred((labels == i)) == j); 
%     end
%     end
%     
%     figure;
%     imagesc(svmConfMat);
%     title(sprintf('SVM confusion matrix, pred %f',acc(1)));
%     
%     fprintf('SVM, c=%i component %i, accuracy %f\n',bestc,k,acc(1));
    
    %% Linear regression
    
    % Determining the temperature of light seems to be more of a regression
    % than classification. Let's try a very simple least squares model to
    % see how well we can do.
    
    A = [PCs', ones(size(PCs',1),1)];
    coeffs = pinv(A)*(temperatures');
    pred = A*coeffs;
    fprintf('Linear regression RMS error %f\n',rms(pred - temperatures'));
    
    figure;
    hold on; grid on; box on;
    plot(pred,temperatures,'o');
    plot(3000:100:9000,3000:100:9000,'r');
    xlabel('Least squares regression prediction');
    ylabel('Actual temperature');
    title(sprintf('Linear regression on %i component, rms %f',k,rms(pred - temperatures')));
    
    %% Quadratic discriminant analysis
    
    % A Bayesian approach (QDA). We assume that each illuminant is
    % equiprobable and that the conditional distribution of the PCA vector
    % entries are Gaussian
    means = zeros(nTemps,4);
    covs = zeros(nTemps,4,4); % changed these 3 4s to 4s (were 5s)
    
    res = zeros(nTemps*nVectorsPerTemp,nTemps);
    for t=1:nTemps
       tmp = PCs(:,labels==t);
       means(t,:) = mean(tmp');
       covs(t,:,:) = cov(tmp');
       
       res(:,t) = mvnpdf(PCs',means(t,:),squeeze(covs(t,:,:)));
    end
    
    [~, indx] = max(res,[],2);
    pred = illuminantTemperature(indx);
    acc = sum(pred == temperatures);
    fprintf('Bayesian model accuracy %5.2f%%\n',100*acc/length(pred));
    
    
    figure;
    hold on; grid on; box on;
    plot(pred,temperatures,'o');
    plot(3000:100:9000,3000:100:9000,'r');
    xlabel('Bayesian model');
    ylabel('Actual temperature');
    title(sprintf('Linear regression on %i component, rms %f',k,rms(pred - temperatures)));
    
    
end


