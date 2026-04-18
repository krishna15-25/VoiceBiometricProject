% record_voice.m
% Standardized recording script for the Voice Biometric Project
% Format: 16kHz, Mono, 16-bit WAV (per Reynolds 2002 requirements)

fs = 16000;
nbits = 16;
nchannels = 1;
duration = 5; % 5-second utterances

speakerName = input('Enter Speaker Name (e.g., speaker1): ', 's');
trialNum = input('Enter Trial Number (e.g., 1): ', 's');
setPath = input('Is this for "train" or "test"? ', 's');

recorder = audiorecorder(fs, nbits, nchannels);
fprintf('Recording %s for %s... Stay silent for a moment then speak.\n', trialNum, speakerName);
recordblocking(recorder, duration);
disp('Recording finished.');

% Save output
audioData = getaudiodata(recorder);
folderPath = sprintf('../data/%s/%s', setPath, speakerName);
if ~exist(folderPath, 'dir')
    mkdir(folderPath);
end

filename = sprintf('%s/trial%s.wav', folderPath, trialNum);
audiowrite(filename, audioData, fs);
fprintf('File saved: %s\n', filename);
