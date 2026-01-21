function trial_complete = disp_trial(block_num, trial_num, action_type)
% All the trial subfunctions are run from here. If trial_complete gets set
% to 0, run_block.m will repeat the trial.
% action_type- 1 = active, 2 = passive

global PTB_set
global sub_set
global pp1
global exp_set

%% Set up some variables that need saving for later.
trial_data = struct;
trial_data.trial_num = trial_num;
trial_data.block_num = block_num;
trial_data.stim_type = sub_set.stim_type(block_num, trial_num);

if action_type == 1
    trial_data.trial_type = 'Active';
else
    trial_data.trial_type = 'Passive';
end

if trial_data.stim_type == 3
    trial_data.catch_trial = 1;
else
    trial_data.catch_trial = 0;
end 

if trial_data.stim_type == 1
    trial_data.freq = 'low';
elseif trial_data.stim_type == 2
    trial_data.freq = 'high';
else
    trial_data.freq = 'catch';
end
trial_data.trial_start = GetSecs; % Timestamp for the start of the trial
% Send a trigger (depending on active/passive and stim delay)
send_trigger(action_type, trial_data.catch_trial, trial_data.stim_type, 1)
%% Trial

% Display fixation cross
draw_fix_cross(1)
trial_data.cross_on = flip_fix_cross(1, 0);

% Cross enlarges as cue
draw_fix_cross(2)
trial_data.cue_start = flip_fix_cross(2, trial_data.cross_on, sub_set.cue_delay(sub_set.current_block, sub_set.current_trial));
send_trigger(action_type, trial_data.catch_trial, trial_data.stim_type, 2)

% Button Press
if action_type == 1 % action_type == 1 % Active Button Press
    [trial_data.button_down, trial_data.button_time, trial_complete] = active_press(trial_data.cue_start,...
    exp_set.stim_delay, trial_data.catch_trial, trial_data.stim_type);
    if trial_complete == 0
        return
    end
else % action_type == 3 % Fully Passive Presentation
    [trial_data.button_down] = fully_passive(trial_data.cue_start,...
        sub_set.pas_pres_delay(sub_set.current_block, sub_set.current_trial),...
        exp_set.stim_delay, trial_data.catch_trial, trial_data.stim_type);
end

% Play the stimulus
[trial_data.stim1_on, trial_data.stim1_off, trial_data.stim_duration, trial_data.real_stim_delay]...
 = play_stim(trial_data.button_down, exp_set.stim_delay, action_type,...
 trial_data.stim_type, trial_data.catch_trial, trial_data.stim_type);

% Wait for a response
%[keyName, reaction_time, response_missed] = get_response(action_type, catch_trial)
[trial_data.response_key, trial_data.RT, trial_data.response_made, trial_data.response_correct]...
 = get_response(action_type, trial_data.catch_trial, trial_data.stim_type);

if action_type == 1
    % How long it took for the button press in this trial
    sub_set.button_delay(block_num, trial_num) = trial_data.button_down - trial_data.cue_start;
    if sub_set.button_delay(block_num, trial_num) > 2.5
        sub_set.button_delay(block_num + 1, trial_num) = 2.5;
    else
        sub_set.button_delay(block_num + 1, trial_num) = trial_data.button_down - trial_data.cue_start;
    end
end

%% Save
save(sprintf('sub%d_block%d_trial%d.mat', sub_set.sub, block_num, trial_num), 'trial_data')
