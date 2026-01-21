function trial_complete = disp_trial_training(block_num, trial_num, action_type, stim_type, pas_button_delay)
% All the trial subfunctions are run from here. If trial_complete gets set
% to 0, run_block.m will repeat the trial.
% action_type- 1 = active, 2 = passive

global PTB_set
global sub_set
global pp1
global exp_set

if action_type == 1
    trial_type = 'Active';
else %action_type == 2
    trial_type = 'Passive';
end

if stim_type == 3
    catch_trial = 1;
else
    catch_trial = 0;
end 

if stim_type == 1
    freq = 'low';
elseif stim_type == 2
    freq = 'high';
else
    freq = 'catch';
end

trial_start = GetSecs; % Timestamp for the start of the trial
% Send a trigger (depending on active/passive and stim delay)
%send_trigger(action_type, stim_delay, 1)
%% Trial

% Display fixation cross
draw_fix_cross(1)
cross_on = flip_fix_cross(1, 0);

% Cross enlarges as cue
draw_fix_cross(2)
cue_start = flip_fix_cross(2, cross_on, sub_set.cue_delay(sub_set.current_block, sub_set.current_trial));

% Button Press
if action_type == 1 % action_type == 1 % Active Button Press
    [button_down, button_time, trial_complete] = active_press(cue_start,...
    exp_set.stim_delay, catch_trial, freq);
    if trial_complete == 0
        return
    end
else % action_type == 3 % Fully Passive Presentation
    [button_down] = fully_passive(cue_start,...
       pas_button_delay, exp_set.stim_delay, catch_trial, freq);
end

% Play the stimulus
[stim1_on, stim1_off, stim_duration, real_stim_delay]...
 = play_stim(button_down, exp_set.stim_delay, action_type,...
 stim_type, catch_trial, freq);

% Wait for a response
%[keyName, reaction_time, response_missed] = get_response(action_type, catch_trial)
[response_key, RT, response_made, response_correct]...
 = get_response(action_type, catch_trial, stim_type);
