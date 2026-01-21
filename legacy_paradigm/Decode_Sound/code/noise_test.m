global pp
global sub_set
global PTB_set
global sound

pkg load ltfat
sound.nrchannels = 2;
sound.samp_rate = 44100;
sound.achannels = 2;
sound.x_noise = noise(100*44100, 2, 'pink')';
sound.noisedata = sound.x_noise*10;
sound.noise_vol = 2;  
waitForDeviceStart = 1;
InitializePsychSound(1);
try
    % Try open sound handle for playback
    sound.pamaster = PsychPortAudio('Open', [], 1+8, 4, sound.samp_rate, sound.nrchannels, [], 0.01);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', 8000);
    fprintf('Sound may sound a bit out of tune, ...\n\n');     
    psychlasterror('reset');
    sound.pamaster = PsychPortAudio('Open', [], 9, 0, [], 2);
end   
PTB_set.pahandle1 = PsychPortAudio('OpenSlave', sound.pamaster, 1, sound.nrchannels);
PsychPortAudio('Start', sound.pamaster, 0, 0, 1);

% Set the volume for noise by changing 1
PsychPortAudio('Volume', PTB_set.pahandle1, sound.noise_vol);
% fill sound buffer1 with white noise on both channels
PsychPortAudio('FillBuffer', PTB_set.pahandle1, sound.noisedata);
% start playback of noise
PsychPortAudio('Start', PTB_set.pahandle1,0);

% Initialise the beep
sound.beepLengthSecs = 0.1;
sound.beep_vol = 0.1;
sound.freq = 1000;
sound.myBeep = MakeBeep(sound.freq, sound.beepLengthSecs, sound.samp_rate);
PTB_set.pahandle2 = PsychPortAudio('OpenSlave', sound.pamaster, 1, sound.nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle2, [sound.myBeep; sound.myBeep]);
PsychPortAudio('Volume', PTB_set.pahandle2, sound.beep_vol);

WaitSecs(4)

sound.noise_test_finished = 0;

while sound.noise_test_finished == 0
    
    sound.btn1 = questdlg(sprintf('Click the mouse! Current noise volume is %d. Adjust noise volume?', sound.noise_vol), "", "Yes", "No", "No");
    if sound.btn1(1) == "N"
      sound.btn2 = questdlg("Save current noise volume?", "", "Save", "Repeat Test", "Repeat Test");
        if sound.btn2(1) == "S"
            sub_set.noise_vol = sound.noise_vol;
            sound.noise_test_finished = 1;
            msgbox(sprintf('Noise volume of %d was saved!', sound.noise_vol));
        end
    else
    sound.new_vol = inputdlg({'New Volume'}, sprintf('Current noise volume is %d. Please enter new volume.', sound.noise_vol), 1);
    sound.noise_vol = str2double(sound.new_vol{1,1});
    PsychPortAudio('Volume', PTB_set.pahandle1, sound.noise_vol);
    end
end

sound.beep_test_finished = 0;

while sound.beep_test_finished == 0
    for repeats = 1:5
    PsychPortAudio('Start', PTB_set.pahandle2, 1); % 'Start', pahandle, repetitions, time, Waitfordevicestart.
    [~, ~, ~, sound.end_time] = PsychPortAudio('Stop', PTB_set.pahandle2, 1, 1); % Stop Audio
    WaitSecs(1);
    end
    
    sound.btn1 = questdlg(sprintf('Current beep volume is %d. Adjust beep volume?', sound.beep_vol), "", "Yes", "No", "No");
    if sound.btn1(1) == "N"
      sound.btn2 = questdlg("Save current beep volume?", "", "Save", "Repeat Test", "Repeat Test");
        if sound.btn2(1) == "S"
            sub_set.beep_vol = sound.beep_vol;
            sound.beep_test_finished = 1;
            msgbox(sprintf('Beep volume of %d was saved!', sound.beep_vol));
        end
    else
    sound.new_vol = inputdlg({'New Volume'}, sprintf('Current beep volume is %d. Please enter new volume.', sound.beep_vol), 1);
    sound.beep_vol = str2double(sound.new_vol{1,1});
    PsychPortAudio('Volume', PTB_set.pahandle2, sound.beep_vol);
    end
end

%PsychPortAudio('Close', PTB_set.pahandle1) % Comment out when finished debugging