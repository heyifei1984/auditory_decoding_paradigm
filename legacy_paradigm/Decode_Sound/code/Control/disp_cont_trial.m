function trial_complete = disp_cont_trial(block_num, trial_num, action_type)
% Display a trial. action_type- 1 = active, 2 = passive

global PTB_set
global sub_set
global pp1
global exp_set
global cont_set

%% Set parameters
trial_data = struct;
trial_data.trial_num = trial_num;
trial_data.block_num = block_num;

if action_type == 1
    trial_data.trial_type = 'Active';
else  % action_type == 2
    trial_data.trial_type = 'Passive';
end

trial_data.trial_start = GetSecs;
send_trigger_cont(action_type, 1)

%% Trial

% Display fixation cross
draw_fix_cross(1)
trial_data.cross_on = flip_fix_cross(1, 0);

% Cross enlarges as cue
draw_fix_cross(2)
trial_data.cue_start = flip_fix_cross(2, trial_data.cross_on, sub_set.cue_delay(sub_set.current_block, sub_set.current_trial));
send_trigger_cont(action_type, 2)

% Button Press
if action_type == 1 % Active
    [trial_data.button_down, trial_data.button_delay, trial_complete] = active_press_cont(trial_data.cue_start);
    if trial_complete == 0
        return
    end
else % action_type == 2 % Passive
    [trial_data.button_down, trial_data.button_delay, button_up] = passive_press_cont(trial_data.cue_start,...
        cont_set.pas_button_delay(cont_set.current_block, cont_set.current_trial));
end

% fix cross for variable interval
% cross_dur_ms = cont_set.ITI(block_num, trial_num); % Set length of ITI in ms
% cross_end = WaitSecs('UntilTime', trial_data.button_down + cross_dur_frames*PTB_set.ifi - PTB_set.ifi/2);

%iti_ms = exp_set.ITI; % Set length of ITI in ms
%iti_frames = round(iti_ms/(PTB_set.ifi*1000));

ITI_secs = cont_set.ITI(block_num, trial_num)/1000;
ITI_frames = round(cont_set.ITI(block_num, trial_num)/(PTB_set.ifi*1000));

if action_type == 2 % If passive, we just flip the screen after the prespecified delay
    Screen('FillRect', PTB_set.w, PTB_set.screen_col)
    blank_start = Screen('Flip', PTB_set.w, trial_data.button_down + ITI_frames*PTB_set.ifi - PTB_set.ifi/2);
else
    button_release = 1
    [~,~,buttons] = GetMouse;
    while any(buttons) % Wait for button release
        [~,~,buttons] = GetMouse;
        if (GetSecs - trial_data.button_down) >= ITI_secs - PTB_set.ifi/2 % If the button isn't released by half a frame before we need to flip the stimulus,
            % then draw and flip the stimulus
            button_release = 0;
            Screen('FillRect', PTB_set.w, PTB_set.screen_col) % Draw blank screen
            start_time = Screen('Flip', PTB_set.w, trial_data.button_down + ITI_frames*PTB_set.ifi - PTB_set.ifi/2); % Flip the screen after the delay
            break
        end
    end
        if button_release == 1 % The button was released before the stimulus flipped.
            button_up = GetSecs;
            Screen('FillRect', PTB_set.w, PTB_set.screen_col) % Draw blank screen
            start_time = Screen('Flip', PTB_set.w, trial_data.button_down + ITI_frames*PTB_set.ifi - PTB_set.ifi/2); % Flip the screen after the delay
            
            % Screen('FillRect', PTB_set.w, PTB_set.screen_col)
            % wait_for_esc(start_time, stim_length)
            % stop_time = Screen('Flip', PTB_set.w, start_time + length_frames*PTB_set.ifi - PTB_set.ifi/2);
        end
end        

%%%%
if action_type == 1
    if button_release == 0 % Error 1 means the button wasn't released before the stimulus was displayed for its whole duration.
        %button_up = 'error1'; 
        button_time = 'error1';    
    elseif ~exist('button_up', 'var')
        % Error 2 means something went wrong (probably the button was released in the first 16ms in 0 frame delay condition or
        % within the 8ms before the stimulus was flipped.
        trial_data.button_up = 'error2';
        trial_data.button_time = 'error2';
    else
        trial_data.button_time = button_up-trial_data.button_down;
        trial_data.button_up = button_up;
    end
else
    trial_data.button_time = button_up-trial_data.button_down;
    trial_data.button_up = button_up;
end    

if action_type == 1
    % How long it took for the button press in this trial
    cont_set.button_delay(block_num, trial_num) = trial_data.button_down - trial_data.cue_start;
    if cont_set.button_delay(block_num, trial_num) > 2.5
        cont_set.button_delay(block_num + 1, trial_num) = 2.5;
    else
        cont_set.button_delay(block_num + 1, trial_num) = trial_data.button_down - trial_data.cue_start;
    end
end


% 1000ms ITI
Screen('FillRect', PTB_set.w, PTB_set.screen_col)
blank_start = Screen('Flip', PTB_set.w);
Screen('Flip', PTB_set.w, blank_start + exp_set.iti_frames*PTB_set.ifi - PTB_set.ifi/2);

if action_type == 2
    trial_complete = 1;
end

%% Save
save(sprintf('sub%d_block%d_trial%d_CONTROL.mat', sub_set.sub, block_num, trial_num), 'trial_data')