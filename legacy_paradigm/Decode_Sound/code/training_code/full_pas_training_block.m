function full_pas_training_block(repeats, stim_type)

%show_block_type(2, 2000)
pas_button_delay = [1.9, 0.85, 1, 1.5, 0.9, 1.7];

trial_complete = 0;
for trial_idx = 1:repeats
    while trial_complete == 0
        trial_complete = disp_trial_training(1, trial_idx, 2, stim_type(trial_idx), pas_button_delay(trial_idx));
    end
    trial_complete = 0;
end