% BiometricDetector.m
% The main entry point for the Voice Biometric Application

clc; clear;
fprintf('=========================================\n');
fprintf('     VOICE BIOMETRIC AI DETECTOR         \n');
fprintf('=========================================\n\n');

% 1. Initialization
addpath(genpath('.')); % Add all subfolders to path

% 2. Choice: Record or Load
choice = input('Press [1] to Record New Voice, [2] to Load a File: ');

if choice == 1
    % Use our standardized recording script
    fs = 16000; duration = 5;
    recorder = audiorecorder(fs, 16, 1);
    disp('Recording for 5 seconds... Speak now!');
    recordblocking(recorder, duration);
    disp('Recording complete. Processing...');
    
    % Save to a temporary file for the detector
    audioData = getaudiodata(recorder);
    tempFile = 'temp_detection.wav';
    audiowrite(tempFile, audioData, fs);
    testFile = tempFile;
else
    [file, path] = uigetfile('data/test/**/*.wav;data/test/**/*.flac', 'Select a voice file');
    if isequal(file, 0), disp('Operation cancelled.'); return; end
    testFile = fullfile(path, file);
end

% 3. Run the 1.25% Accuracy GMM Engine
try
    cd GMM_System/code
    name = identify_speaker_gmm(testFile);
    cd ../..
    
    fprintf('\n-----------------------------------------\n');
    fprintf('  DETECTION RESULT: %s\n', upper(name));
    fprintf('-----------------------------------------\n');
    
    % Visual Confirmation
    visualize_voiceprint(testFile);
    
catch ME
    cd ../..
    fprintf('Error during detection: %s\n', ME.message);
end
