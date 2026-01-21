function [start_time, end_time, real_stim_dur, button_up, button_time, real_stim_delay, length_frames]...
 = show_stim(prev_event, stim_delay, stim_length, action_type, orient, catch_trial)
% prev_event is the offset time of the previous screen flip. Delay must be specified in frames. Length must be
% specified in ms.

global PTB_set
global pp
global pp1
global exp_set

length_frames = round(stim_length/(PTB_set.ifi*1000));
length_secs = stim_length/1000;
delay_secs = PTB_set.ifi*stim_delay;

if action_type == 3
    draw_stim(orient); % Draw stimulus
    start_time = Screen('Flip', PTB_set.w, prev_event + stim_delay*PTB_set.ifi - PTB_set.ifi/2);
    end_time = show_blank_screen(start_time, length_frames);
    button_up = 'N/A';

%% If it's a passive trial, we need to implement the code to release the button. The button should stay down for 12 frames (200ms).
elseif action_type == 2
    draw_stim(orient); % Draw stimulus
    start_time = Screen('Flip', PTB_set.w, prev_event + stim_delay*PTB_set.ifi - PTB_set.ifi/2);
%   send_trigger(action_type, stim_delay, 4)
    draw_stim(orient);
    button_up = Screen('Flip', PTB_set.w, prev_event + exp_set.pas_butt_t*PTB_set.ifi - PTB_set.ifi/2);
    pp_data(pp,0)
    end_time = show_blank_screen(start_time, length_frames);
    
else % If it's an active trial
    button_release = 1; % If this variable gets set to 0, it means the button wasn't released before the next flip event.
    [~,~,buttons] = GetMouse;
    while any(buttons) % Wait for button release
        [~,~,buttons] = GetMouse;
        if (GetSecs - prev_event) >= delay_secs - PTB_set.ifi/2 % If the button isn't released by half a frame before we need to flip the stimulus,
            % then draw and flip the stimulus
            button_release = 0;
            draw_stim(orient); % Draw stimulus
            start_time = Screen('Flip', PTB_set.w, prev_event + stim_delay*PTB_set.ifi - PTB_set.ifi/2); % Flip the stimulus after the delay
%            send_trigger(action_type, stim_delay, 4)
            break
        end
    end
    if button_release == 1 % The button was released before the stimulus flipped.
        button_up = GetSecs;
        draw_stim(orient); % Draw stimulus
        start_time = Screen('Flip', PTB_set.w, prev_event + stim_delay*PTB_set.ifi - PTB_set.ifi/2); % Flip the stimulus after the delay
%        send_trigger(action_type, stim_delay, 4)
        
        end_time = show_blank_screen(start_time, length_frames);
    else % The stimulus flipped before the button was released.
        button_release = 1;
         while any(buttons) % Wait for button release
            [~,~,buttons] = GetMouse;
            if (GetSecs - start_time) >= length_secs - PTB_set.ifi/2 % If the button isn't released before the question flips, flip it
                button_release = 0;
                end_time = show_blank_screen(start_time, length_frames);
                break
            end
         end
         if button_release == 1 % If the button was already released
            button_up = GetSecs;
            end_time = show_blank_screen(start_time, length_frames);
         end
    end
end

if action_type == 1
    if button_release == 0 % Error 1 means the button wasn't released before the stimulus was displayed for its whole duration.
        %button_up = 'error1'; 
        button_time = 'error1';  
        fprintf('error1')
    elseif ~exist('button_up', 'var')
        % Error 2 means something went wrong (probably the button was released in the first 16ms in 0 frame delay condition or
        % within the 8ms before the stimulus was flipped.
        button_up = 'error2';
        button_time = 'error2';
    else
        button_time = button_up-prev_event;
    end 
elseif
    button_time = button_up-prev_event;   
else
button_time = 'N/A'; 
end    

real_stim_dur = end_time - start_time;
real_stim_delay = start_time - prev_event;
