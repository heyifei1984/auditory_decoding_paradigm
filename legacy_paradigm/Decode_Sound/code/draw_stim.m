function phase = draw_stim
global PTB_set

%gaborDimPix = PTB_set.wRect(4) / 4;  % size of Gabor is 100px (original = 12)
gaborDimPix = 500;
sigma = gaborDimPix / 7;             % Sigma of Gaussian
%orientation = orient;
contrast = 0.7;
aspectRatio = 1.0;
phase = rand(1)*360; % Randomise the phase
numCycles = 10;  % spatial Frequency (Cycles Per Pixel): One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
freq_vis = numCycles / gaborDimPix;
backgroundOffset = [PTB_set.screen_col PTB_set.screen_col PTB_set.screen_col 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;

PTB_set.gabortex = CreateProceduralGabor(PTB_set.w, gaborDimPix, gaborDimPix, [], backgroundOffset, disableNorm, preContrastMultiplier);

PTB_set.propertiesMat = [phase, freq_vis, sigma, contrast, aspectRatio, 0, 0, 0];  % randomise the phase of the Gabors and make a properties matrix.

texrect = Screen('Rect', PTB_set.gabortex); % preallocate array with destination rectangles; for the very first drawn stimulus frame
inrect = repmat(texrect', 1, 1);
PTB_set.dstRect1 = CenterRectOnPoint(texrect, PTB_set.xCenter, PTB_set.yCenter); % locations of left and right gabors

%Screen('DrawTextures', PTB_set.w, PTB_set.gabortex, [], PTB_set.dstRect1, orientation, [], [], [], [], kPsychDontDoRotation, propertiesMat');
