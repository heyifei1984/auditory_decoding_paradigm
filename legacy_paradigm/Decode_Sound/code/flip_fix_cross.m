function start_time = flip_fix_cross(type, prev_event, delay)

global PTB_set

if type == 1
  start_time = Screen('Flip', PTB_set.w);
else
  start_time = Screen('Flip', PTB_set.w, prev_event + delay - PTB_set.ifi/2);
end