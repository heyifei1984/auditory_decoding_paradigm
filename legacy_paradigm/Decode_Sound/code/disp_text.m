function disp_text(text, cont_delay, cross, beep, stim_type)
% Text for the string of text you want to display
% cont_delay for the delay between text and button press
% cross for whether to include fix cross (0 = no, 1 = yes)

global PTB_set
global lang

if cross == 1
    Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter-20, PTB_set.yCenter, PTB_set.xCenter+20, PTB_set.yCenter, 4);
    Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter, PTB_set.yCenter-20, PTB_set.xCenter, PTB_set.yCenter+20, 4);
end
Screen('TextSize', PTB_set.w, 30);
DrawFormattedText(PTB_set.w, text ,'center', PTB_set.posText-150, [1 1 1], 100, [], [], [1.7]);
screen_flip = Screen('Flip', PTB_set.w);

%function [start_time, end_time, real_stim_dur, real_stim_delay]...
% = play_stim(prev_event, stim_delay, action_type, stim_type, catch_trial, freq)

beep_delay = 0.8;

if beep == 1
  if stim_type == 1 
    play_stim(screen_flip, beep_delay, 1, stim_type, 0, 'low');
  elseif stim_type == 2
    play_stim(screen_flip, beep_delay, 1, stim_type, 0, 'high');
  else
    play_stim(screen_flip, beep_delay, 1, stim_type, 1, 'mid');
   end
   
   WaitSecs(cont_delay - beep_delay);
else
   WaitSecs(cont_delay);
end

if cross == 1
    Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter-20, PTB_set.yCenter, PTB_set.xCenter+20, PTB_set.yCenter, 4);
    Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter, PTB_set.yCenter-20, PTB_set.xCenter, PTB_set.yCenter+20, 4);
end    
DrawFormattedText(PTB_set.w, text,'center', PTB_set.posText-150, [1 1 1], 100, [], [], [1.7]);
if strcmp(lang, 'Deutsch')
    DrawFormattedText(PTB_set.w,'Drücke eine beliebige Taste auf der Tastatur, wenn du bereit bist, fortzufahren.','center', PTB_set.posText+150, [0 1 0], 50, [], [], [1.5]);
else
    DrawFormattedText(PTB_set.w,'Press any key when you are ready to continue','center', PTB_set.posText+150, [0 1 0], 50, [], [], [1.5]);
end
Screen('Flip', PTB_set.w);
    
btn_continue = 0;
while btn_continue == 0
    [btn_continue] = KbCheck;
end
Screen('TextSize', PTB_set.w, 40);
