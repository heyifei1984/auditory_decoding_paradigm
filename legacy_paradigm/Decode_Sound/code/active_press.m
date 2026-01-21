function [button_down, button_time, valid_press] = active_press(prev_event, stim_delay, catch_trial, stim_type)
% Wait for a button press and send a trigger. If the button press is
% quicker than 700ms, valid_press is set to 0 and the trial will restart.
global pp1
global lang
% Change the times outside which button press is considered invalid.
min_butt_time = 0.7;

[~,~,buttons] = GetMouse;
while ~any(buttons) % Wait for press
    [~,~,buttons] = GetMouse;
end
button_down = GetSecs;
button_time = button_down - prev_event; % How long the press took, in seconds.

if button_time < min_butt_time % If button was pressed quicker than 700ms
    send_trigger(1, catch_trial, stim_type, 9)
    if strcmp(lang, 'Deutsch')
        speed_warning('Zu Schnell. Versuche es nochmal.')
    else
        speed_warning('Too fast. Try again.')
    end    
    valid_press = 0;
else
    send_trigger(1, catch_trial, stim_type, 3)

    valid_press = 1;
end