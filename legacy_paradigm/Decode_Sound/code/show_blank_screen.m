function [start_time] = show_blank_screen(prev_event, length)
% prev_event is the offset time of the previous screen flip. Delay and length must be
% specified in ms.

global PTB_set
global pp1

Screen('FillRect', PTB_set.w, PTB_set.screen_col)    
start_time = Screen('Flip', PTB_set.w, prev_event + length*PTB_set.ifi - PTB_set.ifi/2);

