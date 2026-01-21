function trigger = send_trigger(action_type, catch_trial, stim_type, event)
% List of events:
% Trial Start = 1
% Audio Cue = 2
% Button Press = 3
% Stim = 4
% Response Made = 5

% Esc key pressed = 8
% Button press too fast = 9
% Experiment finished = 10

global pp1
global exp_set

if event == 10
    trigger = 203;
elseif event == 9
    trigger = 202;
elseif event == 8
    trigger = 201;
elseif event == 7
    trigger = 200;
elseif catch_trial == 1
    if stim_type == 3
        trigger = exp_set.low_catch_trig(action_type, event);
    else
        trigger = exp_set.high_catch_trig(action_type, event);
    end
else
    if stim_type == 1
        trigger = exp_set.low_trig(action_type, event);
    else 
        trigger = exp_set.high_trig(action_type, event);
    end
end
pp_data(pp1, trigger)
waittime = (1/1000)*10;
WaitSecs(waittime);
pp_data(pp1, 0)