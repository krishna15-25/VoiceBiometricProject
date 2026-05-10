% BiometricDetector.m
% The main entry point for the Voice Biometric Application

clc; clear;
fprintf('=========================================\n');
fprintf('     VOICE BIOMETRIC AI DETECTOR         \n');
fprintf('=========================================\n\n');

% 1. Initialization - Add relative paths
addpath(genpath('Shared/code'));
addpath(genpath('GMM_System/code'));
addpath(genpath('VQ_System/code'));

% 2. Choice: Record or Load
choice = input('Press [1] to Record New Voice, [2] to Load a File: ');

if choice == 1
    fs = 16000; duration = 5;
    recorder = audiorecorder(fs, 16, 1);
    disp('Recording for 5 seconds... Speak now!');
    recordblocking(recorder, duration);
    disp('Recording complete. Processing...');
    
    audioData = getaudiodata(recorder);
    testFile = 'results/temp_detection.wav';
    audiowrite(testFile, audioData, fs);
else
    [file, path] = uigetfile('data/test/**/*.wav;data/test/**/*.flac', 'Select a voice file');
    if isequal(file, 0), disp('Operation cancelled.'); return; end
    testFile = fullfile(path, file);
end

% 3. Run Engine
try
    name = identify_speaker_gmm(testFile);
    
    fprintf('\n-----------------------------------------\n');
    fprintf('  DETECTION RESULT: %s\n', upper(name));
    fprintf('-----------------------------------------\n');
    
    visualize_voiceprint(testFile);
catch ME
    fprintf('Error during detection: %s\n', ME.message);
end
