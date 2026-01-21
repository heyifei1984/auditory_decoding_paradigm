% finish experiment
global sub_set
global PTB_set
global pp1

%send_trigger(1,0,10)

%if exist('sub_set', 'var')
%    save(sprintf('subject%d.mat', sub_set.sub), 'sub_set')
%end
Screen( 'CloseAll' );
try
    PsychPortAudio( 'Stop', PTB_set.pahandle2 );
    PsychPortAudio( 'Close', PTB_set.pahandle2 );
catch
    disp('Clean_UP: PsychPortAudio wasn''t opened yet!')
end
ShowCursor();
clear all;

disp('EXPERIMENT FINISHED')