% Set up everything to do with audio

global pp
global sub_set
global PTB_set

pkg load ltfat

% General settings
snd.nrchannels = 2;
snd.fs = 44100;
%snd.achannels = 2;

% Create noise and open pamaster
%snd.x_noise = noise(100*44100, 2, 'pink')';
%snd.noisedata = snd.x_noise*10;
InitializePsychSound(1);
try
    % Try open sound handle for playback
    snd.pamaster = PsychPortAudio('Open', [], 1+8, 4, samp_rate, nrchannels, [], 0.01);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', 8000);
    fprintf('sound may sound a bit out of tune, ...\n\n');     
    psychlasterror('reset');
    snd.pamaster = PsychPortAudio('Open', [], 9, 0, [], 2);
end   
%PTB_set.pahandle1 = PsychPortAudio('OpenSlave', snd.pamaster, 1, snd.nrchannels);
PsychPortAudio('Start', snd.pamaster, 0, 0, 1);
%
%PsychPortAudio('Volume', PTB_set.pahandle1, 0);
%PsychPortAudio('FillBuffer', PTB_set.pahandle1, snd.noisedata);
%PsychPortAudio('Start', PTB_set.pahandle1,0);

% Initialise the beep
snd.dur = 0.2; % sound duration in seconds
snd.freq = [532.25, 1046.5];
snd.beep_vol = 0.07; 
snd.fade_dur = 0.03; % Fade duraton in seconds

% Generate fade envelope

snd.beep_fs = [251.63, 261.63*2, 261.63*1.5];

t = 0:1/snd.fs:snd.dur - 1/snd.fs;
snd.low = sin(2 * pi * snd.beep_fs(1) * t);
snd.high = sin(2 * pi * snd.beep_fs(2) * t);
snd.mid = sin(2 * pi * snd.beep_fs(3) * t);

n_fade = round(snd.fade_dur * snd.fs);
fade_in = linspace(0, 1, n_fade);
fade_out = linspace(1, 0, n_fade);
steady = ones(1, length(snd.low) - 2*n_fade);
envelope = [fade_in, steady, fade_out];

% Generate tones with envelope
snd.low_env = snd.low .*envelope;
snd.high_env = snd.high .*envelope;
%snd.mid_env = snd.mid + snd.noisedata .*envelope;

% Low tone
PTB_set.pahandle2 = PsychPortAudio('OpenSlave', snd.pamaster, 1, snd.nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle2, [snd.low_env; snd.low_env]);
PsychPortAudio('Volume', PTB_set.pahandle2, snd.beep_vol);

% High tone
PTB_set.pahandle3 = PsychPortAudio('OpenSlave', snd.pamaster, 1, snd.nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle3, [snd.high_env; snd.high_env]);
PsychPortAudio('Volume', PTB_set.pahandle3, snd.beep_vol);

% Catch trials
snd.x_noise = noise(length(t), 1, 'white')';
snd.noisedata = snd.x_noise*2;

% Generate tones with noise and envelope
snd.low_noise = (snd.low + snd.noisedata) .*envelope;
snd.high_noise = (snd.high + snd.noisedata) .*envelope;

% Low tone + noise
PTB_set.pahandle4 = PsychPortAudio('OpenSlave', snd.pamaster, 1, snd.nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle4, [snd.low_noise; snd.low_noise]);
PsychPortAudio('Volume', PTB_set.pahandle4, snd.beep_vol);

% High tone + noise
PTB_set.pahandle5 = PsychPortAudio('OpenSlave', snd.pamaster, 1, snd.nrchannels);
PsychPortAudio('FillBuffer', PTB_set.pahandle5, [snd.high_noise; snd.high_noise]);
PsychPortAudio('Volume', PTB_set.pahandle5, snd.beep_vol);

