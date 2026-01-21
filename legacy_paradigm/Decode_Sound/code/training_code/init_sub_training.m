global sub_set
global exp_set
sub_set.sub = 1;
ifi = 1000/60;

sub_set.button_delay = zeros(1, 12);
sub_set.cue_delay = zeros(1, 12);
%sub_set.catch_trials = zeros(1, 3);

block_idx = 1;
% Create shuffled button delays
delay_vals = exp_set.training_button;
temp_delay = repmat(delay_vals, 1);
temp_delay = temp_delay(1,:);
sub_set.button_delay(block_idx, :) = shuffle(temp_delay);

% Create shuffled Orientations
%orient_vals = exp_set.training_degree;
%temp_or = repmat(orient_vals, exp_set.num_trials/length(orient_vals));
%temp_or = temp_or(1,:);
%sub_set.degree(block_idx, :) = shuffle(temp_or);

% Create shuffled Cues
delay_vals = exp_set.training_cue;
temp_delay = repmat(delay_vals, 2);
temp_delay = temp_delay(1,:);
sub_set.cue_delay(block_idx, :) = shuffle(temp_delay);

sub_set.current_block = 1;
sub_set.current_trial = 1;
sub_set.current_block_type = [];