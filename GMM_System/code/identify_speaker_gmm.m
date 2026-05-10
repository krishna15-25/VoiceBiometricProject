% identify_speaker_gmm.m
% Detects the identity of a speaker using the 1.25% accuracy GMM model

function identifiedName = identify_speaker_gmm(testFile)

% 1. Get the path of THIS script to find models relatively
scriptPath = mfilename('fullpath');
[scriptDir, ~, ~] = fileparts(scriptPath);
modelPath = fullfile(scriptDir, '..', 'results', 'gmm_models.mat');

if ~exist(modelPath, 'file')
    error('Detector brain not found at: %s', modelPath);
end
load(modelPath, 'gmmModels', 'speakerNames');

% 2. Pre-process
[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);

% 3. Extract Features (C2:C13 + VAD)
[coeffs, ~, ~] = mfcc(preEmphasized, fs, 'NumCoeffs', 13);
energy = coeffs(:,1);
isSpeech = energy > (min(energy) + 0.7*(max(energy) - min(energy)));
testFeats = coeffs(isSpeech, 2:end); 

if isempty(testFeats)
    identifiedName = 'No Speech Detected';
    return;
end

% 4. Scoring
numSpeakers = length(speakerNames);
logLikelihoods = zeros(1, numSpeakers);
for k = 1:numSpeakers
    if ~isempty(gmmModels{k})
        logLikelihoods(k) = sum(log(pdf(gmmModels{k}, testFeats)));
    else, logLikelihoods(k) = -inf; end
end

% 5. Decision
[~, id] = max(logLikelihoods);
identifiedName = speakerNames{id};

end
