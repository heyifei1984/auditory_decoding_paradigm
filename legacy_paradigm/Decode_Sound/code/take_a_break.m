function take_a_break

global PTB_set
global status
global exp_set
global lang

if strcmp(lang, 'Deutsch')
    DrawFormattedText(PTB_set.w, 'Drücke "esc", um eine Pause zu machen, oder "C", um fortzufahren.', 'center', PTB_set.posText,...
    exp_set.break_col, 100);
else
    DrawFormattedText(PTB_set.w, 'Press "esc" to take a break for "C" to continue.', 'center', PTB_set.posText,...
    exp_set.break_col, 100);
end    
    
    
Screen('Flip', PTB_set.w);

keyIsDown = 0;

while ~ keyIsDown
    [keyIsDown, ~, keyCode] = KbCheck;
    keyCode = find(keyCode, 1);
    if keyCode == status.escapeKey
        status.running = 0;
        clean_up;
        disp('Escape key pressed. Cleaning up...')
    elseif keyCode == 'C'
        count_down
        return
    end    
end