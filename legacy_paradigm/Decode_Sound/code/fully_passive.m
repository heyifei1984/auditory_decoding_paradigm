function [button_down] = fully_passive(prev_event, button_delay, stim_delay, catch_trial, stim_type)

global PTB_set
global pp
global pp1

wait_for_esc(prev_event, button_delay)
button_down = WaitSecs('UntilTime', prev_event + button_delay - PTB_set.ifi/2);

send_trigger(2, catch_trial, stim_type, 3)