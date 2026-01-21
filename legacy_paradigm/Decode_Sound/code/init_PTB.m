% Load all settings for Psychtoolbox

global PTB_set

%% Useful Octave settings
save_default_options('-7')
more off % Turn paging off (print all output at once)
format short g % Stop scientific notation in output (doesn't work 100%)

%% General PTB settings
PsychDefaultSetup(2); % Call default settings for PTB
AssertOpenGL; % check for OpenGL compatibility, abort otherwise:

%% Set up the screen
% Select presentation screen.
PTB_set.screens = Screen('Screens');
PTB_set.screenNumber = max(PTB_set.screens);

% Open an on screen window and colour it.
PTB_set.screen_col = 0.4;
%PTB_set.screen_col = 0.5;
PTB_set.text_col = 0;
PTB_set.pres_size = [100 100 1800 600]; %Set small presentation window size for debugging.
%PTB_set.pres_size = []; 

[PTB_set.w, PTB_set.wRect] = PsychImaging('OpenWindow', PTB_set.screenNumber, PTB_set.screen_col, PTB_set.pres_size);

Screen('TextSize', PTB_set.w, 40)
Screen('Preference', 'DefaultFontSize', 40);
%HideCursor;

% Get the size of the on screen window in pixels.
[PTB_set.screenXpixels, PTB_set.screenYpixels] = Screen('WindowSize', PTB_set.w);

% Get the centre coordinate of the window in pixels
[PTB_set.xCenter, PTB_set.yCenter] = RectCenter(PTB_set.wRect);

% Enable alpha blending for anti-aliasing
Screen('BlendFunction', PTB_set.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set text position to centre of screen
PTB_set.posText = PTB_set.yCenter;

%% Find the inter-flip interval (used for precise timing)
PTB_set.priorityLevel = MaxPriority(PTB_set.w);
Priority(PTB_set.priorityLevel);
PTB_set.hz = Screen('NominalFrameRate', PTB_set.w);
PTB_set.ifi = Screen('GetFlipInterval', PTB_set.w);
Priority(0);

%% Make sure timing and keyboard functions are ready when we need them.
% Do dummy calls to GetSecs, waitSecs, KbCheck to make sure
% they are loaded and ready when PTB_set.we need them.
KbCheck;
WaitSecs(0.1);
GetSecs;

KbName('UnifyKeyNames')
%Screen('Close', PTB_set.w);