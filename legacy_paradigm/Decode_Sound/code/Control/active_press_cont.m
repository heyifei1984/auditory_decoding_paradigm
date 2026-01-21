function [button_down, button_delay, valid_press] = active_press_cont(prev_event)

% Change the times outside which button press is considered invalid.
min_butt_time = 0.7;

[~,~,buttons] = GetMouse;
while ~any(buttons) % Wait for press
    [~,~,buttons] = GetMouse;
end
button_down = GetSecs;
button_delay = button_down - prev_event; % How long the press took, in seconds.

if button_delay < min_butt_time % If button was pressed quicker than 700ms
    send_trigger_cont(1, 9)
    speed_warning('Zu Schnell. Versuche es nochmal.')
    valid_press = 0;
else
    valid_press = 1;
    send_trigger_cont(1, 3) 
end