global pp
global sub_set
global PTB_set

pkg load ltfat

% General settings
nrchannels = 2;
samp_rate = 44100;
achannels = 2;

% Create noise and open pamaster
x_noise = noise(100*44100, 2, 'pink')';
noisedata = x_noise*100;
waitForDeviceStart = 1;
InitializePsychSound(1);
try
    % Try open sound handle for playback
    pamaster = PsychPortAudio('Open', [], 1+8, 4, samp_rate, nrchannels, [], 0.01);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', 8000);
    fprintf('Sound may sound a bit out of tune, ...\n\n');     
    psychlasterror('reset');
    pamaster = PsychPortAudio('Open', [], 9, 0, [], 2);
end   
PTB_set.pahandle1 = PsychPortAudio('OpenSlave', pamaster, 1, nrchannels);
PsychPortAudio('Start', pamaster, 0, 0, 1);

PsychPortAudio('Volume', PTB_set.pahandle1, 0.1);
PsychPortAudio('FillBuffer', PTB_set.pahandle1, noisedata);
PsychPortAudio('Start', PTB_set.pahandle1,0);

% Initialise the beep
beepLengthSecs = 0.1;
freq = 1000;
myBeep = MakeBeep(freq, beepLengthSecs, samp_rate);
PTB_set.pahandle2 = PsychPortAudio('OpenSlave', pamaster, 1, nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle2, [myBeep; myBeep]);
PsychPortAudio('Volume', PTB_set.pahandle2, 0.05);
