% train_vq.m
function train_vq()
addpath('../../Shared/code'); 
trainDir = '../../data/train/';
fs = 16000;
numCoeffs = 13;
codebookSize = 128; % High Resolution

speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));
numSpeakers = length(speakerFolders);

codebooks = cell(1, numSpeakers);
speakerNames = {speakerFolders.name};

fprintf('Training Optimized VQ (128-Centroids + Energy Filtering) for %d speakers...\n', numSpeakers);

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    speakerPath = fullfile(trainDir, speakerName);
    wavFiles = [dir(fullfile(speakerPath, '*.wav')); dir(fullfile(speakerPath, '*.flac'))];
    
    all_features = [];
    for j = 1:length(wavFiles)
        [audio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        
        % Extract MFCCs
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        
        % VAD (Aggressive: only keep top 70% of energy frames)
        energy = coeffs(:,1);
        threshold = min(energy) + 0.7*(max(energy) - min(energy));
        isSpeech = energy > threshold;
        
        % Feature Pruning: Remove C1 (Energy) to be volume-independent
        % We keep C2 through C13
        prunedFeats = coeffs(isSpeech, 2:end);
        
        all_features = [all_features; prunedFeats];
    end
    
    % Train High-Res Codebook
    codebooks{i} = vqlbg(all_features', codebookSize);
end

if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/models.mat', 'codebooks', 'speakerNames');
disp('Optimized VQ Models Saved.');
end
