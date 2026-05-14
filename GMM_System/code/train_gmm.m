% train_gmm.m
function train_gmm()
    % Get the absolute path to this script
    scriptPath = mfilename('fullpath');
    [scriptDir, ~, ~] = fileparts(scriptPath);
    
    % Define absolute paths to project directories
    projectRoot = fullfile(scriptDir, '..', '..');
    sharedCodeDir = fullfile(projectRoot, 'Shared', 'code');
    trainDir = fullfile(projectRoot, 'data', 'train');
    resultsDir = fullfile(scriptDir, '..', 'results');
    modelFile = fullfile(resultsDir, 'gmm_models.mat');
    
    % Add required paths
    addpath(sharedCodeDir);
    
    fs = 16000;
    numCoeffs = 13;
    numMixtures = 16; % Upgraded for high-resolution speaker discrimination

    % Verify training directory exists
    if ~exist(trainDir, 'dir')
        error('Training data directory not found: %s', trainDir);
    end

    speakerFolders = dir(trainDir);
    speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));
    numSpeakers = length(speakerFolders);

    if numSpeakers == 0
        warning('No speaker folders found in %s', trainDir);
        return;
    end

    gmmModels = cell(1, numSpeakers);
    speakerNames = {speakerFolders.name};

    fprintf('Training Optimized GMM for %d speakers...\n', numSpeakers);

    for i = 1:numSpeakers
        speakerName = speakerNames{i};
        speakerPath = fullfile(trainDir, speakerName);
        wavFiles = [dir(fullfile(speakerPath, '*.wav')); dir(fullfile(speakerPath, '*.flac'))];
        
        if isempty(wavFiles)
            warning('No audio files found for speaker: %s', speakerName);
            continue;
        end
        
        all_features = [];
        for j = 1:length(wavFiles)
            [audio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
            preEmphasized = filter([1 -0.97], 1, audio);
            
            % Extract MFCCs + Deltas + Delta-Deltas (The 'Gold Standard')
            [coeffs, delta, delta2] = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
            
            % Combine into a single feature vector (36 dimensions)
            combinedFeats = [coeffs(:, 2:end), delta, delta2];
            
            % Robust VAD
            energy = coeffs(:,1);
            vadThreshold = mean(energy) + 0.1 * std(energy);
            isSpeech = energy > vadThreshold;
            
            % Feature Pruning
            prunedFeats = combinedFeats(isSpeech, :);
            
            % CMVN (Normalization)
            if ~isempty(prunedFeats)
                prunedFeats = (prunedFeats - mean(prunedFeats)) ./ (std(prunedFeats) + 1e-6);
            end
            
            all_features = [all_features; prunedFeats];
        end
        
        if isempty(all_features)
            warning('No speech detected for speaker: %s. Skipping.', speakerName);
            continue;
        end
        
        fprintf('  Fitting GMM for %s (%d samples)...\n', speakerName, length(wavFiles));
        try
            options = statset('MaxIter', 100);
            gmmModels{i} = fitgmdist(all_features, numMixtures, ...
                'CovarianceType', 'diagonal', ...
                'Options', options, ...
                'RegularizationValue', 0.01);
        catch ME
            warning('GMM failed for %s: %s', speakerName, ME.message);
        end
    end

    if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end
    save(modelFile, 'gmmModels', 'speakerNames');
    fprintf('Optimized GMM Training Complete. Model saved to: %s\n', modelFile);
end
