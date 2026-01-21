function [start_time] = show_block_type(block_type, length)
% Display the block type instruction text
% Active = 1, Passive = 2, 3 = Cued

global PTB_set
global exp_set
global lang

frames = round(length/(PTB_set.ifi*1000));

if block_type == 1 % Active
    if strcmp(lang, 'Deutsch')
        DrawFormattedText(PTB_set.w, 'AKTIV KNOPFDRUCK. Drücke den Knopf.', 'center', PTB_set.posText,...
        exp_set.block_type_text_col, 100);
    else    
        DrawFormattedText(PTB_set.w, 'Active. Press the button.', 'center', PTB_set.posText,...
        exp_set.block_type_text_col, 100);
    end    
else
    if strcmp(lang, 'Deutsch')
        DrawFormattedText(PTB_set.w, 'PASSIV. KEIN KNOPFDRUCK', 'center', PTB_set.posText,...
        exp_set.block_type_text_col, 100);
    else
        DrawFormattedText(PTB_set.w, 'PASSIVE. NO BUTTON PRESS', 'center', PTB_set.posText,...
        exp_set.block_type_text_col, 100);
    end
end
start_time = Screen('Flip', PTB_set.w);

wait_for_esc(start_time, length)

Screen('FillRect', PTB_set.w, PTB_set.screen_col)
Screen('Flip', PTB_set.w, start_time + frames*PTB_set.ifi - PTB_set.ifi/2);