%% Clear Workspace

clear all;
root_dir = '/home/brainimg/Desktop/Ody/Decode_Sound'; 
% save_default_options('-7')
more off % Turn paging off (print all output at once)
format short g % Stop scientific notation in output (doesn't work 100%)
PsychDefaultSetup(2); % Call default settings for PTB
AssertOpenGL; % check for OpenGL compatibility, abort otherwise:

addpath( '/home/brainimg/Desktop/Ody/Decode_Sound/code' )
addpath( '/home/brainimg/Desktop/Ody/Decode_Sound/code/training_code' )

global sub_set
global PTB_set
global status
global inst
global exp_set
global lang

init_ports;
init_PTB; 
init_sound;
init_exp;
init_sub_training;
init_instructions;

lang = 'Deutsch';

HideCursor
status.running = 1;
status.escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck;

Screen('Close', PTB_set.w)
[PTB_set.w, PTB_set.wRect] = PsychImaging('OpenWindow', PTB_set.screenNumber, PTB_set.screen_col, PTB_set.pres_size);

disp_text(inst.welcome, 4, 0, 0, 0)
disp_text(inst.beep1, 4, 0, 0, 0)

disp_text(inst.beep2, 2, 0, 1, 1)

disp_text(inst.beep3, 2, 0, 1, 2)

disp_text(inst.beep4, 2, 0, 1, 3)

disp_text(inst.beep5, 2, 0, 1, 4)

%% Active Training
beep_type = [1, 1, 2, 3, 1, 4]; % 3 and 4 are the catch tones with noise
disp_text(inst.schnell, 4, 0, 0, 0)
disp_text(inst.active, 2, 0, 0, 0)
disp_text(inst.task, 2, 0, 0, 0)
act_training_block(6, beep_type);

%% Passive Training
beep_type = [2, 4, 1, 1, 3, 2];
WaitSecs(2)
disp_text(inst.full_passive, 2, 0, 0, 0)
full_pas_training_block(6, beep_type);
WaitSecs(2)

disp_text('Training beendet!', 2, 0, 0, 0)
sca
