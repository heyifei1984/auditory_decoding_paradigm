function end_time = play_beep(prev_event, action_type, stim_delay, catch_trial, stim_orientation)

global PTB_set
global pp1

PsychPortAudio('Start', PTB_set.pahandle2, 1, prev_event + PTB_set.ifi/2, 1); % 'Start', pahandle, repetitions, time, Waitfordevicestart.

send_trigger(action_type, catch_trial, stim_orientation, 2)

[~, ~, ~, end_time] = PsychPortAudio('Stop', PTB_set.pahandle2, 1, 1); % Stop Audio