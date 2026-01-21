%% Clear Workspace
%% Clear Workspace

clear all;
root_dir = '/home/brainimg/Desktop/Ody/Decode_Sound ';

addpath( '/home/brainimg/Desktop/Ody/Decode_Sound/code' )
%experiment_folder = uigetdir(pwd, 'Please choose EXPERIMENT folder');
subject_folder = uigetdir(pwd, 'Navigate to SUBJECT folder');
sub = str2double( subject_folder( end-3 : end) );

init_ports;

global sub_set
global exp_set
global PTB_set

global lang
lang = questdlg("Select Language", "Language", "Deutsch", "English", "Deutsch");

cd(subject_folder)
if exist(sprintf('subject%d.mat', sub), 'file')
    load(sprintf('subject%d.mat', sub));
    init_PTB;
    init_sound;
    init_exp;
    
    % The gabor patches don't display properly without this, but that's no longer relevant. Best to keep it here as a reminder anyway.
    Screen('Close', PTB_set.w)
    warndlg("Check EEG Recording is Running Before Continuing", "Warning");
    [PTB_set.w, PTB_set.wRect] = PsychImaging('OpenWindow', PTB_set.screenNumber, PTB_set.screen_col, PTB_set.pres_size);
%        show_block_type(sub_set.current_block_type, 2000)  
%        WaitSecs(0.5);
   % end
else
    %noise_test;
    init_PTB;
    init_exp;
    init_sound;
    Screen('Close', PTB_set.w) 
    init_sub;    
    warndlg("Check EEG Recording is Running Before Continuing", "Warning");
    [PTB_set.w, PTB_set.wRect] = PsychImaging('OpenWindow', PTB_set.screenNumber, PTB_set.screen_col, PTB_set.pres_size);
end

global status

%WaitSecs(2);
Screen('TextSize', PTB_set.w, 40);

%try
%% PTB main loop
HideCursor
%WaitSecs(1)
status.running = 1;
status.escapeKey = KbName('ESCAPE')

if strcmp(lang, 'Deutsch')
    disp_text('Drücke die Leertaste, wenn du das Geräusch hörst!', 1, 0, 0, 0)
    disp_text('Es geht gleich los', 2, 0, 0, 0) 
else
    disp_text('Press the space bar when you hear the noise!', 1, 0, 0, 0)
    disp_text('Experiment will start soon', 2, 0, 0, 0) 
end    

draw_stim
Screen('Close')

while status.running
    for block_idx = sub_set.current_block:exp_set.num_blocks
        sub_set.current_block_type = exp_set.block_order(block_idx);
        run_block(block_idx, sub_set.current_block_type);
        
        if block_idx == exp_set.num_blocks
            finish;
        else
            sub_set.current_block = block_idx + 1;
            save(sprintf('subject%d.mat', sub_set.sub), 'sub_set')
        end
        
        % Uncomment the commented out code if you want to put a break only
        % after certain blocks are completed.
        
        %             if block_idx == 3 
        take_a_break
        %             end
    end
end

%catch
%clean_up;
%disp ('Cleaned up, boss')
%return
%end
