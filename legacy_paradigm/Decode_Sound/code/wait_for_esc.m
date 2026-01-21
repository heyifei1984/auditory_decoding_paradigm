function wait_for_esc (start_time, length)

global status
global PTB_set

length_secs = length/1000;

frames = round(length_secs/PTB_set.ifi);

while GetSecs - start_time <  (frames-1)*PTB_set.ifi - PTB_set.ifi/2
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        keyCode = find(keyCode, 1);
        keyCode
        if keyCode == status.escapeKey
            status.running = 0;
            clean_up;
            disp('Escape key pressed. Cleaning up...')
        end    
    end
end