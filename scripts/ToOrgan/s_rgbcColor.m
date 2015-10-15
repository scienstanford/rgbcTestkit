%% s_rgbcColor
%% TODO: finish this.

%%
s_initISET

%% Initialize a MCC

scene = sceneCreate;
vcAddObject(scene);
sceneWindow;

oi = oiCreate;
oi = oiCompute(oi,scene);

%% Create an OmniVision RGBC sensor model

sensor = rgbcCreate;
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
sensor = sensorSet(sensor,'exp time',0.015);  %everything's multiples of 15ms

%% This shows the color filter array
sensorShowCFA(sensor); CFAletters = sensorDetermineCFA(sensor);
[CFAnumbers,mp] = sensorImageColorArray(CFAletters); vcNewGraphWin;
image(CFAnumbers); colormap(mp);

%%
sensor = sensorCompute(sensor,oi);
vcAddObject(sensor);
sensorWindow;

%%
ip = vcimageCreate;
ip = imageSet(ip,'name','rgbc mcc');
% Changed to "conversion method sensor" as "sensor method conversion"
% wasn't in the code properly...
ip = imageSet(ip,'conversion method sensor','mccoptimized');

ip = vcimageCompute(ip,sensor);
vcAddObject(ip); vcimageWindow;

t = imageGet(ip,'combined transform');
svd(t)



%% idk after this.


%% Here is a ridge regression estimate of the transform
% ieWindowsSet;

wave = sensorGet(sensor,'wave');
r = ieReflectanceSamples([],[],wave);

sqe  = sensorGet(sensor,'spectral qe');
ill  = illuminantCreate('d65');
illP = illuminantGet(ill,'photons');
xyzT = ieXYZFromPhotons( (diag(illP)*r)',wave)';  % XYZ values in columns
resp = sqe'*diag(illP)*r;                         % Sensor responses in cols

% Now we want xyzT = T*resp using a ridge regression approach, and others
% xyzT*resp' = T*resp*resp' %This and the next 2 lines were commented out. --ns
% xyzT*resp'*inv(resp*resp')
% T =  xyzT * resp' * inv(resp*resp')
T = xyzT / resp;
T = T/max(T(:))




%% Use just RGB.  This is more stable - less spatial noise.

% We need a general way to think this through.  Probably what QT and SL did
% in L3 is a good approach.

respRGB = resp(1:3,:);
TRGB = xyzT / respRGB;
TRGB = TRGB/max(TRGB(:));
TRGB = [TRGB, zeros(3,1)]


%% Cross-validation

% New reflectance samples
r2    = ieReflectanceSamples;
xyzT2 = ieXYZFromPhotons((diag(illP)*r2)',wave)';  % XYZ values
resp2 = sqe'*diag(illP)*r2;                         % Sensor responses
% resp2 = resp2/max(resp2(:));

% Make the prediction with T
vcNewGraphWin([],'tall');
subplot(2,1,1)
pred = T*resp2;
plot(pred(:),xyzT2(:),'o')
title('Using all four bands')

subplot(2,1,2)
predRGB = TRGB*resp2;
plot(predRGB(:),xyzT2(:),'o')
title('Using only RGB')

%% Use the (over-fitting) five band solution

ip = imageSet(ip,'transform method','current');
ip = imageSet(ip,'sensor conversion matrix',T');
ip = imageSet(ip,'name','Use 5');
ip = vcimageCompute(ip,sensor);
vcAddObject(ip);
vcimageWindow;
   
%% Swap in the fit restricted to only the RGB channels

ip = imageSet(ip,'transform method','current');
ip = imageSet(ip,'sensor conversion matrix',TRGB');
ip = imageSet(ip,'name','Use 3');
ip = vcimageCompute(ip,sensor);
vcAddObject(ip);
vcimageWindow;

%% Create an ideal form and use the rgbc channel fit

sensorIdeal = sensorCreateIdeal('match',sensor);
sensorIdeal = sensorCompute(sensorIdeal,oi);

ipIdeal = vcimageCreate;
ipIdeal = imageSet(ipIdeal,'name','ideal use 5');
ipIdeal = vcimageCompute(ipIdeal,sensorIdeal);
ipIdeal = imageSet(ipIdeal,'transform method','current');
ipIdeal = imageSet(ipIdeal,'sensor conversion matrix',T');
ipIdeal = vcimageCompute(ipIdeal,sensorIdeal);
vcAddObject(ipIdeal); vcimageWindow;

%% Create an ideal form and use the three channel fit

sensorIdeal = sensorCreateIdeal('match',sensor);
sensorIdeal = sensorCompute(sensorIdeal,oi);

ipIdeal = vcimageCreate;
ipIdeal = imageSet(ipIdeal,'name','ideal use 3');
ipIdeal = vcimageCompute(ipIdeal,sensorIdeal);
ipIdeal = imageSet(ipIdeal,'transform method','current');
ipIdeal = imageSet(ipIdeal,'sensor conversion matrix',TRGB');
ipIdeal = vcimageCompute(ipIdeal,sensorIdeal);
vcAddObject(ipIdeal); vcimageWindow;


%% Possible regularizer weights

% The ridge regression idea is this:
%
% % T*resp = xyzT 
% % T*resp*resp' = xyzT*resp'
% % T = xyzT*resp'*(resp*resp' + R)^-1
 
resp = resp/max(resp(:));      % Make the values reasonable
ii = 1;  % Choose a level
lambda = logspace(-5,1,5);
% T = xyzT * resp' * inv(resp*resp' + lambda(2)*diag([1,1,1,100,100]));
T = (xyzT * resp') / (resp*resp' + lambda(3)*diag([1,1,1,1])); 
T = T/max(T(:));


ip = imageSet(ip,'transform method','current');
ip = imageSet(ip,'sensor conversion matrix',T');
ip = imageSet(ip,'name','Ridge use rgbc');
ip = vcimageCompute(ip,sensor);
vcAddObject(ip);
vcimageWindow;

%%
t = imageGet(ipIdeal,'combined transform');
s = svd(t)
s(1)/s(end)


%%

