% RecordAndIdentify.m
% Records a voice, saves it permanently with a timestamp, and identifies the speaker

clc; clear;
fprintf('=========================================\n');
fprintf('   PERMANENT RECORD & IDENTIFY TOOL      \n');
fprintf('=========================================\n\n');

% 1. Setup paths
addpath(genpath('Shared/code'));
addpath(genpath('GMM_System/code'));
addpath(genpath('VQ_System/code'));

% 2. Recording Parameters
fs = 16000;
duration = 5; % 5-second recording
recorder = audiorecorder(fs, 16, 1);

fprintf('STATUS: Recording for %d seconds...\n', duration);
fprintf('>>> PLEASE SPEAK NOW <<<\n');
recordblocking(recorder, duration);
fprintf('STATUS: Recording complete. Saving file...\n');

% 3. Save with Timestamp (Persistent Storage)
audioData = getaudiodata(recorder);
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename = fullfile('results', 'recordings', ['capture_', timestamp, '.wav']);

if ~exist(fullfile('results', 'recordings'), 'dir')
    mkdir(fullfile('results', 'recordings'));
end

audiowrite(filename, audioData, fs);
fprintf('STATUS: File permanently stored at: %s\n', filename);

% 4. Identify using the 1.25% GMM Engine
fprintf('STATUS: Analyzing biometrics...\n');
try
    speakerName = identify_speaker_gmm(filename);
    
    fprintf('\n-----------------------------------------\n');
    fprintf('  DETECTION RESULT: %s\n', upper(speakerName));
    fprintf('-----------------------------------------\n');
    
    % Visual Confirmation
    visualize_voiceprint(filename);
    
catch ME
    fprintf('ERROR: Detection failed - %s\n', ME.message);
end
