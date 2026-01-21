function run_block(block_num, block_type)
% Show trials in a loop.
% block_type - 1 = active, 2 = passive button, 3 = Fully Passive
global sub_set
global exp_set

%% Block loops
trial_complete = 0;
for trial_idx = sub_set.current_trial:exp_set.num_trials
    if sub_set.current_trial == 1 % If at the start of a block, show the block type.
        show_block_type(block_type, 4000)
        WaitSecs(1)
    end
    while trial_complete == 0
        block_num
        trial_idx
        trial_complete = disp_trial(block_num, trial_idx, block_type);
    end
    trial_complete = 0;
    
    if trial_idx == exp_set.num_trials
        if sub_set.current_block ~= exp_set.num_blocks
            sub_set.current_trial = 1;
        end
        
        if block_type == 1
            sub_set.pas_pres_delay(block_num + 1, :) = shuffle(sub_set.button_delay(block_num + 1, :));
        end
        
    else
        sub_set.current_trial = trial_idx + 1;
    end
    save(sprintf('subject%d.mat', sub_set.sub), 'sub_set')
end

