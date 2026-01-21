%function MakeCue(w, colour, PTB_set.xCenter, PTB_set.yCenter)
%Screen('drawline', w, colour, PTB_set.xCenter-20, PTB_set.yCenter, PTB_set.xCenter+20, PTB_set.yCenter, 2);
%Screen('drawline', w, colour, PTB_set.xCenter, PTB_set.yCenter-20, PTB_set.xCenter, PTB_set.yCenter+20, 2);
%Screen('drawline', w, colour, PTB_set.xCenter-20, PTB_set.yCenter-20, PTB_set.xCenter+20, PTB_set.yCenter-20, 2);
%Screen('drawline', w, colour, PTB_set.xCenter-20, PTB_set.yCenter+20, PTB_set.xCenter+20, PTB_set.yCenter+20, 2);
%Screen('drawline', w, colour, PTB_set.xCenter+20, PTB_set.yCenter-20, PTB_set.xCenter+20, PTB_set.yCenter+20, 2);
%Screen('drawline', w, colour, PTB_set.xCenter-20, PTB_set.yCenter-20, PTB_set.xCenter-20, PTB_set.yCenter+20, 2);
%end

function draw_fix_cross(size)

global PTB_set

if size == 1

Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter-20, PTB_set.yCenter, PTB_set.xCenter+20, PTB_set.yCenter, 4);
Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter, PTB_set.yCenter-20, PTB_set.xCenter, PTB_set.yCenter+20, 4);

else

Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter-30, PTB_set.yCenter, PTB_set.xCenter+30, PTB_set.yCenter, 4);
Screen('drawline', PTB_set.w, PTB_set.text_col, PTB_set.xCenter, PTB_set.yCenter-30, PTB_set.xCenter, PTB_set.yCenter+30, 4);

end