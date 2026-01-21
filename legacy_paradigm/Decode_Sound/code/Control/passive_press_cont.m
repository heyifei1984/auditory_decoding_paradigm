function [button_down, button_delay, button_up] = passive_press_cont(prev_event, delay)

global PTB_set
global pp
global pp1

wait_for_esc(prev_event, delay)
button_down = WaitSecs('UntilTime', prev_event + delay - PTB_set.ifi/2);
pp_data(pp,255)

send_trigger_cont(2,3)

draw_fix_cross
button_up = Screen('Flip', PTB_set.w, button_down + 12*PTB_set.ifi - PTB_set.ifi/2);
pp_data(pp,0)
button_delay = button_down - prev_event;