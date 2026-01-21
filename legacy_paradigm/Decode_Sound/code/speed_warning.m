function [start_time, stop_time] = speed_warning(text)

global PTB_set
global exp_set
DrawFormattedText(PTB_set.w, text, 'center', PTB_set.posText-150, exp_set.speed_warn_text_col, 100);
% DrawFormattedText(PTB_set.w, text, 'center', [], [1 0 0]);

% [nx, ny, textbounds, wordbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])

start_time = Screen('Flip', PTB_set.w);
Screen('FillRect', PTB_set.w, PTB_set.screen_col)
wait_for_esc(start_time, 1000)
stop_time = Screen('Flip', PTB_set.w, start_time + 60*PTB_set.ifi-PTB_set.ifi/2);
WaitSecs(1)