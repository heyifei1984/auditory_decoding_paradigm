%% Clear Workspace

clear all;
root_dir = '/home/brainimg/Desktop/Ody/Decode_Sound';

addpath( '/home/brainimg/Desktop/Ody/Decode_Sound/code' )
addpath( '/home/brainimg/Desktop/Ody/Decode_Sound/code/Control' )
subject_folder = uigetdir(pwd, 'Navigate to SUBJECT folder');
sub = str2double( subject_folder( end-3 : end) );

init_ports;

global lang
lang = questdlg("Select Language", "Language", "Deutsch", "English", "Deutsch");

cd(subject_folder)
if exist(sprintf('subject%d_CONTROL.mat', sub), 'file')
    load(sprintf('subject%d.mat', sub)); global sub_set
    load(sprintf('subject%d_CONTROL.mat', sub)); global cont_set
    init_PTB; global PTB_set
    init_sound;
    init_exp;
else
    load(sprintf('subject%d.mat', sub)); global sub_set
    init_PTB; global PTB_set
    init_exp;
    init_control;
    init_sound;
    if strcmp(lang, 'Deutsch')
        disp_text('Willkommen zum Kontrollblock', 2, 0, 0, 0)
        disp_text('Zur Erinnerung: Diesmal werden Sie das Kreuz sehen und den Ton hören, aber nach dem Knopfdruck werden keine Kreise erscheinen. Warten Sie einfach bis zum nächsten Durchgang.', 2, 0, 0, 0)
    else
        disp_text('Welcome to the Control Block', 2, 0, 0, 0)
        disp_text('Reminder: You will see the cross and hear the tone, but after the button press there are no lines. Simply wait until the next trial.', 2, 0, 0, 0)    
    end     
end

global status

WaitSecs(2);

%try
    %% PTB main loop
    HideCursor
    WaitSecs(1)
    status.running = 1;
    status.escapeKey = KbName('ESCAPE');
    while status.running
        for block_idx = cont_set.current_block:length(cont_set.block_order)
            cont_set.current_block_type = cont_set.block_order(block_idx);
            run_cont_block(block_idx, cont_set.current_block_type);
            
            if block_idx == length(cont_set.block_order) % Block 2 (Last block)
                finish;
            else    
                cont_set.current_block = block_idx + 1;
                save(sprintf('subject%d_CONTROL.mat', sub_set.sub), 'cont_set')
            end  
           % if block_idx == 2
              take_a_break
           % end 
        end
    end   
   
%catch
  %clean_up;
  %disp ('Cleaned up, boss')
  return
%end