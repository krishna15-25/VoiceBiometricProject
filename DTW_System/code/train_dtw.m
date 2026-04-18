% train_dtw.m
% "Enrolls" speakers for the DTW system by pre-extracting MFCC templates

% 1. Setup paths
addpath('../../Shared/code'); 
trainDir = '../../data/train/';

% Parameters
fs = 16000;
numCoeffs = 13;

% Get list of speaker folders
speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));

numSpeakers = length(speakerFolders);
if numSpeakers == 0
    error('No speaker folders found! Run generate_test_data first.');
end

% We will store templates as a cell array of MFCC matrices
templates = cell(1, numSpeakers);
speakerNames = {speakerFolders.name};

fprintf('Starting DTW Enrollment (Pre-extracting Templates) for %d speakers...\n', numSpeakers);

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    speakerPath = fullfile(trainDir, speakerName);
    wavFiles = dir(fullfile(speakerPath, '*.wav'));
    
    fprintf('  Processing %s (%d files)...\n', speakerName, length(wavFiles));
    
    speakerTemplates = cell(1, length(wavFiles));
    for j = 1:length(wavFiles)
        [audio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        
        % Extract MFCCs and store the entire sequence as a template
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        speakerTemplates{j} = coeffs'; % Store as [Coeffs x Frames]
    end
    templates{i} = speakerTemplates;
end

if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/templates.mat', 'templates', 'speakerNames');
fprintf('\nDTW Enrollment complete! Templates saved to DTW_System/results/templates.mat\n');
