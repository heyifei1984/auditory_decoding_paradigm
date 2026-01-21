% This script contains variables that are consistent across the entire experiment.

global exp_set

exp_set.stim_type = [1, 2]; % Orientation of stimulus

% exp_set.stim_length = 30; % No longer necessary when using audio. This gets set in init_sound instead.

exp_set.stim_delay = 0.1; % Delay between button press and stimulus in frames

exp_set.num_trials = 60; % Trials per block
exp_set.cont_trials = 50; % Trials per control block

exp_set.pas_butt_t = 12; % Number of frames the button stays down for in passive condition. This should not be changed to...
% 6 frames or fewer, as this will break the code in show_stim.m unless it is modified to release the button before flipping the stimulus.

exp_set.block_order = [1 2 1 2 1 2 1 2 1 2]; % Block order can only really be changed by changing other elements of code. However,...
% extra groups of blocks can be added here.

exp_set.num_blocks = length(exp_set.block_order); % Number of total blocks.

exp_set.num_catch_trials = 4; % Set number of catch trials per block. Must be an even number (equal number for each orientation).

% Text colours
exp_set.block_type_text_col = [1 1 1]; % Black
exp_set.speed_warn_text_col = [0 0 1]; % Blue
exp_set.break_col = [0 1 0]; % Green

%
exp_set.cont_cue = 1.1:1.5;
exp_set.cue = 1.2:0.1:1.7; % Cue delay
exp_set.response_wait = 1; % Max time to display the question on screen
exp_set.iti_frames = 75;

exp_set.control_ITI = 1250:50:1450; % Control ITI

exp_set.training_button = 0.7:0.1:1.8; % Training button delays
exp_set.training_cue = 0.7:0.1:1.2; % Training cue delay
exp_set.training_degree = [45, -45]; % Training stimulus delay

%% Triggers
exp_set.low_trig = [11:15; 51:55];
exp_set.high_trig = [21:25; 61:65];
exp_set.low_catch_trig = [71:75; 91:95]; 
exp_set.high_catch_trig = [101:105; 111:115]; 

exp_set.cont_trig = 121:123;
