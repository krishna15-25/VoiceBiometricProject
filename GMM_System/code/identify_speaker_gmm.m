% identify_speaker_gmm.m
% Detects the identity of a speaker using the 1.25% accuracy GMM model

function identifiedName = identify_speaker_gmm(testFile)

% 1. Get the path of THIS script to find models and shared code relatively
scriptPath = mfilename('fullpath');
[scriptDir, ~, ~] = fileparts(scriptPath);
projectRoot = fullfile(scriptDir, '..', '..');
sharedCodeDir = fullfile(projectRoot, 'Shared', 'code');
modelPath = fullfile(scriptDir, '..', 'results', 'gmm_models.mat');

% Ensure shared code is on path for MFCC function
addpath(sharedCodeDir);

if ~exist(modelPath, 'file')
    error('Detector brain not found at: %s', modelPath);
end
load(modelPath, 'gmmModels', 'speakerNames');


% 2. Pre-process
[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);

% 3. Extract Features (MFCC + Delta + Delta-Delta)
[coeffs, delta, delta2] = mfcc(preEmphasized, fs, 'NumCoeffs', 13);
energy = coeffs(:,1);

% Combine (36-dimensional feature vector)
combinedFeats = [coeffs(:, 2:end), delta, delta2];

% Robust VAD
vadThreshold = mean(energy) + 0.1 * std(energy);
isSpeech = energy > vadThreshold;
testFeats = combinedFeats(isSpeech, :); 

if isempty(testFeats)
    identifiedName = 'No Speech Detected';
    return;
end

% 4. Feature Normalization (CMVN)
testFeats = (testFeats - mean(testFeats)) ./ (std(testFeats) + 1e-6);

% 5. Scoring with Cohort Normalization
numSpeakers = length(speakerNames);
rawScores = zeros(1, numSpeakers);
for k = 1:numSpeakers
    if ~isempty(gmmModels{k})
        rawScores(k) = mean(log(pdf(gmmModels{k}, testFeats)));
    else, rawScores(k) = -inf; end
end

% Cohort Normalization: Subtract the average score of all other speakers
% This highlights the 'Real One' and cancels out common audio artifacts.
normScores = zeros(1, numSpeakers);
for k = 1:numSpeakers
    otherScores = rawScores([1:k-1, k+1:end]);
    backgroundAvg = mean(otherScores(otherScores > -inf));
    normScores(k) = rawScores(k) - backgroundAvg;
end

% 6. Decision & Debugging
[sortedNorm, sortedIdx] = sort(normScores, 'descend');

fprintf('\nDEBUG: Biometric Analysis (Cohort Normalized):\n');
for i = 1:min(3, numSpeakers)
    fprintf('  Rank %d: %-12s | Conf. Score: %8.4f\n', i, speakerNames{sortedIdx(i)}, sortedNorm(i));
end

identifiedName = speakerNames{sortedIdx(1)};




end
