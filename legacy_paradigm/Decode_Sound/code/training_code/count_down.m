function count_down

global PTB_set

Screen('TextSize', PTB_set.w, 60);
DrawFormattedText(PTB_set.w, '3' ,'center', PTB_set.posText-150, [1 1 1], 100, [], [], [1.7]);
Screen('Flip', PTB_set.w);
WaitSecs(1);

Screen('TextSize', PTB_set.w, 60);
DrawFormattedText(PTB_set.w, '2' ,'center', PTB_set.posText-150, [1 1 1], 100, [], [], [1.7]);
Screen('Flip', PTB_set.w);
WaitSecs(1);

Screen('TextSize', PTB_set.w, 60);
DrawFormattedText(PTB_set.w, '1' ,'center', PTB_set.posText-150, [1 1 1], 100, [], [], [1.7]);
Screen('Flip', PTB_set.w);
WaitSecs(1);