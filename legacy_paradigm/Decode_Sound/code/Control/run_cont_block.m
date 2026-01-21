function run_cont_block(block_num, block_type)
% Show trials in a loop.
% block_type - 1 = active, 2 = passive button
global sub_set
global cont_set
global exp_set

%% Block loops
trial_complete = 0;
for trial_idx = cont_set.current_trial:exp_set.cont_trials
    if cont_set.current_trial == 1 % If at the start of a block, create random numbers for catch trials.
        show_block_type(block_type, 2000);
        WaitSecs(1)
    end
    while trial_complete == 0
        trial_idx
        trial_complete = disp_cont_trial(block_num, trial_idx, block_type, 0);
    end
    trial_complete = 0;
    
    if trial_idx == exp_set.cont_trials
        cont_set.current_trial = 1;
        
        if block_type == 1
            cont_set.pas_button_delay(block_num + 1, :) = shuffle(cont_set.button_delay(block_num + 1, :));
        end    
        
    else
        cont_set.current_trial = trial_idx + 1;
    end    
    save(sprintf('subject%d_CONTROL.mat', sub_set.sub), 'cont_set')
end

