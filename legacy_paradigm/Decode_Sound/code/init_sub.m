% This script initialises variables that are specific to each participant

global sub_set
global PTB_set
global exp_set

quit_function = 0;
while quit_function == 0
    sub_set.sub = sub;
    
%     if rem(sub_set.sub, 2) == 1 % If participant number is odd
%         sub_set.counterbalance = 0;
%     else
%         sub_set.counterbalance = 1;
%     end
    
    sub_set.button_delay = zeros(exp_set.num_blocks, exp_set.num_trials);
    sub_set.pas_button_delay = zeros(exp_set.num_blocks, exp_set.num_trials);
    sub_set.pas_pres_delay = zeros(exp_set.num_blocks, exp_set.num_trials);
    sub_set.stim_delay = zeros(exp_set.num_blocks, exp_set.num_trials);
    sub_set.cue_delay = zeros(exp_set.num_blocks, exp_set.num_trials);   
    
    % The following code creates block*trial shaped matrices of shuffled.
    for block_idx = 1:length(exp_set.block_order)
        % Create shuffled Cues
        delay_vals = exp_set.cue;
        % Create a vector containing delay_vals repeated however many times
        % you want for that block
        temp_delay = repmat(delay_vals, exp_set.num_trials/length(delay_vals)); % essential, repeat the repmat
        temp_delay = temp_delay(1,:);
        sub_set.cue_delay(block_idx, :) = shuffle(temp_delay);
        
        % Create shuffled stim types
        stim_vals = exp_set.stim_type;
        temp_or = repmat(stim_vals, exp_set.num_trials/length(stim_vals));
        temp_or = temp_or(1,:);
        sub_set.stim_type(block_idx, :) = shuffle(temp_or);
        
        % Insert two catch trials into the sequence. They need to replace one of each delay.
        mat1 = find(sub_set.stim_type(block_idx, :) == 1); % Find indices of low (type 1) trials
        msize = numel(mat1); % Get the number of elements
        rand_idx = randperm(msize); % Randomly order them
        idx1 = mat1(rand_idx(1:exp_set.num_catch_trials/2)); % Take the first index from rand_idx and use this to select an index from trials that have type 1
        sub_set.stim_type(block_idx, idx1) = 3;
        
        mat2 = find(sub_set.stim_type(block_idx, :) == 2); % Find indices of high (type 2) trials
        msize = numel(mat2); % Get the number of elements
        rand_idx = randperm(msize); % Randomly order them
        idx2 = mat2(rand_idx(1:exp_set.num_catch_trials/2)); % Take the first index from rand_idx and use this to select an index from trials that have type 2
        sub_set.stim_type(block_idx, idx2) = 4;
        
    end   
    
    %sub_set.button_delay = shuffle(temp_delay);

    sub_set.current_block = 1;
    sub_set.current_trial = 1;
    sub_set.current_block_type = [];

    [initials, age, gender, quit_function] = sub_details;

    if quit_function == 1
        clear all
        clc
        disp('Participant Details were not entered correcly. Try again')
    end
    
    %sub_set.counterbalance = counterbalance;
    sub_set.initials = initials;
    sub_set.age = age;
    sub_set.gender = gender;
    sub_set.first_created = clock;
    
    sub_set.counterbalance = 0; % x = yes, v = no
end  

   % sub_set.timestamp = datetime;
save(sprintf('subject%d.mat', sub_set.sub), 'sub_set')