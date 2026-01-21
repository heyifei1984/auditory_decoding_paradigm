function [keyName, reaction_time, response_made, response_correct] = get_response(action_type, catch_trial, stim_type)

global PTB_set
global status
global pp1
global exp_set

%iti_ms = exp_set.ITI; % Set length of ITI in ms
%iti_frames = round(iti_ms/(PTB_set.ifi*1000));

% Restrict keys to only response keys and pause/escape keys
activeKeys = [KbName('space'), KbName('ESCAPE'), KbName('p')];
RestrictKeysForKbCheck(activeKeys);

t2wait = exp_set.response_wait; % Max time to wait for key press before next trial starts.

% Wait for button press or max exp_set.response_wait seconds, then trigger next trial.
tStart = GetSecs;
% repeat until a valid key is pressed or we time out
timedout = false;
response_made = true;
if catch_trial == 0
    response_correct = 1
else
    response_correct = 0
end

reaction_time = 'N/A';
keyName = 'N/A';
    
while ~timedout
    % check if a key is pressed
    % only keys specified in activeKeys are considered valid
    [keyIsDown, keyTime, keyCode] = KbCheck;
    if(keyIsDown)
        break
    end
    
    if( (keyTime - tStart) > t2wait)
        timedout = true;
        response_made = false;
        % ITI
        Screen('FillRect', PTB_set.w, PTB_set.screen_col)
        blank_start = Screen('Flip', PTB_set.w);
        Screen('Flip', PTB_set.w, blank_start + exp_set.iti_frames*PTB_set.ifi - PTB_set.ifi/2);
    end
end

% Store RT and key name and display intertrial interval
if(~timedout)
    if keyCode == status.escapeKey
        status.running = 0;
        clean_up;
        disp('Escape key pressed. Cleaning up...')
    else
        reaction_time = keyTime - tStart;
        keyName = KbName(keyCode);
        
        if catch_trial == 1
            response_correct = 1;
        else
            response_correct = 0;
        end
        
        send_trigger(action_type, catch_trial, stim_type, 5)
        
        % After a button press, this code calculates t2wait - RT so the time after 
%        the stimulus before the next trial is always the same
        iti_ms = exp_set.response_wait * 1000 - reaction_time * 1000; % Set length of ITI in ms
        iti_frames = round(iti_ms/(PTB_set.ifi * 1000));
        Screen('FillRect', PTB_set.w, PTB_set.screen_col)
        blank_start = Screen('Flip', PTB_set.w);
        wait_for_esc(blank_start, iti_ms)
        Screen('Flip', PTB_set.w, blank_start + iti_frames*PTB_set.ifi - PTB_set.ifi/2);
    end
end

RestrictKeysForKbCheck([]);