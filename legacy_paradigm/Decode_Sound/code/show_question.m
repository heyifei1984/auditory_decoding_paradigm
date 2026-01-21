function [start_time] = show_question(prev_event, delay)
% prev_event is the offset time of the previous screen flip. Delay must be
% specified in ifi units. 1 = no delay.

global PTB_set

%delay_frames = round(delay/(PTB_set.ifi*1000));

DrawFormattedText(PTB_set.w, 'Verzögerung? Ja/Nein?', 'center', PTB_set.posText, PTB_set.text_col, 100);
wait_for_esc(prev_event, delay)
start_time = Screen('Flip', PTB_set.w, prev_event + delay*PTB_set.ifi - PTB_set.ifi/2);