function disp_text_train(text, cont_delay, colour)
% Text for the string of text you want to display
% cont_delay for the delay between text and button press
% colour, red = 0, green = 1

global PTB_set

Screen('TextSize', PTB_set.w, 40);
if colour == 0
    DrawFormattedText(PTB_set.w, text ,'center', PTB_set.posText-100, [1 0 0], 100, [], [], [1.7]);
elseif colour == 1   
    DrawFormattedText(PTB_set.w, text ,'center', PTB_set.posText-100, [0 1 0], 100, [], [], [1.7]); 
else  
    DrawFormattedText(PTB_set.w, text ,'center', PTB_set.posText-100, [1 1 1], 100, [], [], [1.7]);   
end
Screen('Flip', PTB_set.w);
WaitSecs(cont_delay);
