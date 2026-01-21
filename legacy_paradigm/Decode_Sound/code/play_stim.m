function [start_time, end_time, real_stim_dur, real_stim_delay]...
 = play_stim(prev_event, stim_delay, action_type, stim_type, catch_trial, freq)
% prev_event is the offset time of the previous screen flip. Delay must be specified in frames. Length must be
% specified in ms.

global PTB_set
global pp
global pp1
global exp_set

if stim_type == 1
    start_time = PsychPortAudio('Start', PTB_set.pahandle2, 1, prev_event + stim_delay, 1); % 'Start', pahandle, repetitions, time, Waitfordevicestart.
    send_trigger(action_type, catch_trial, stim_type, 4) ; % Send trigger  
    [~, ~, ~, end_time] = PsychPortAudio('Stop', PTB_set.pahandle2, 1, 1); % Stop Audio
elseif stim_type == 2
    start_time = PsychPortAudio('Start', PTB_set.pahandle3, 1, prev_event + stim_delay, 1);
    send_trigger(action_type, catch_trial, stim_type, 4) ; 
    [~, ~, ~, end_time] = PsychPortAudio('Stop', PTB_set.pahandle3, 1, 1); 
elseif stim_type == 3
    start_time = PsychPortAudio('Start', PTB_set.pahandle4, 1, prev_event + stim_delay, 1); 
    send_trigger(action_type, catch_trial, stim_type, 4) ; 
    [~, ~, ~, end_time] = PsychPortAudio('Stop', PTB_set.pahandle4, 1, 1); 
else
    start_time = PsychPortAudio('Start', PTB_set.pahandle5, 1, prev_event + stim_delay, 1); 
    send_trigger(action_type, catch_trial, stim_type, 4) ; 
    [~, ~, ~, end_time] = PsychPortAudio('Stop', PTB_set.pahandle5, 1, 1); 
end
      
real_stim_dur = end_time - start_time;
real_stim_delay = start_time - prev_event;