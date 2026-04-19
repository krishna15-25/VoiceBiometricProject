% train_gmm.m
function train_gmm()
addpath('../../Shared/code');
trainDir = '../../data/train/';
fs = 16000;
numCoeffs = 13;
numMixtures = 16; 

speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));
numSpeakers = length(speakerFolders);

gmmModels = cell(1, numSpeakers);
speakerNames = {speakerFolders.name};

fprintf('Training Optimized GMM (Pruned Features) for %d speakers...\n', numSpeakers);

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
        
        % VAD (Aggressive)
        energy = coeffs(:,1);
        threshold = min(energy) + 0.7*(max(energy) - min(energy));
        isSpeech = energy > threshold;
        
        % Feature Pruning: Use only C2:C13 (Volume-independent spectral shape)
        prunedFeats = coeffs(isSpeech, 2:end);
        
        all_features = [all_features; prunedFeats];
    end
    
    fprintf('  Fitting GMM for %s...\n', speakerName);
    try
        options = statset('MaxIter', 100);
        gmmModels{i} = fitgmdist(all_features, numMixtures, ...
            'CovarianceType', 'diagonal', ...
            'Options', options, ...
            'RegularizationValue', 0.1);
    catch ME
        warning('GMM failed for %s. Check data.', speakerName);
    end
end

if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/gmm_models.mat', 'gmmModels', 'speakerNames');
disp('Optimized GMM Training Complete.');
end
