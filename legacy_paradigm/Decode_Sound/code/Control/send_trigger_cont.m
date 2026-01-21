function send_trigger_cont(action_type, event)
% List of events:
% Trial Start = 1
% Audio Cue = 2
% Button Press = 3

% Missed Response = 7
% Esc key pressed = 8
% Button press too fast = 9
% Experiment finished = 10

global pp1
global exp_set

if event == 10 % Exp finished
    trigger = 203;
elseif event == 9 % Button press too fast
    trigger = 202;
elseif event == 8 % Esc key
    trigger = 201;
elseif event == 7 % Missed Response
    trigger = 200;
else
    trigger = exp_set.cont_trig(action_type, event);
end
pp_data(pp1, trigger)
waittime = (1/1000)*10;
WaitSecs(waittime);
pp_data(pp1, 0)