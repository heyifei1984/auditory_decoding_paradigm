function act_training_block(repeats, stim_type)

trial_complete = 0;
for trial_idx = 1:repeats
    while trial_complete == 0
        trial_complete = disp_trial_training(1, trial_idx, 1, stim_type(trial_idx), 0);
    end
    trial_complete = 0;
end