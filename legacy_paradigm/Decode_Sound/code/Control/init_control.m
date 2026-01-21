global cont_set
global sub_set
global exp_set
    
cont_set.button_delay = zeros(2, exp_set.cont_trials);
cont_set.pas_button_delay = zeros(2, exp_set.cont_trials);
cont_set.cue_delay = zeros(2, exp_set.cont_trials);

cont_set.block_order = [1 1];   
    
for block_idx = 1:length(cont_set.block_order)
    % Create shuffled Cues
    delay_vals = exp_set.cont_cue;
    temp_delay = repmat(delay_vals, exp_set.cont_trials/length(delay_vals));
    temp_delay = temp_delay(1,:);
    cont_set.cue_delay(block_idx, :) = shuffle(temp_delay);
    
    % Create shuffled ITIs
    delay_vals = exp_set.control_ITI;
    temp_delay = repmat(delay_vals, exp_set.cont_trials/length(delay_vals));
    temp_delay = temp_delay(1,:);
    cont_set.ITI(block_idx, :) = shuffle(temp_delay);
end   
    
cont_set.current_block = 1;
cont_set.current_trial = 1;
cont_set.current_block_type = [];
    
cont_set.first_created = clock;  

   % sub_set.timestamp = datetime;
save(sprintf('subject%d_CONTROL.mat', sub_set.sub), 'cont_set')