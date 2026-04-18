% identify_vq.m
function identifiedName = identify_vq(testFile)

addpath('../../Shared/code');

% 1. Load trained models
modelPath = '../results/models.mat';
if ~exist(modelPath, 'file')
    error('No models found! Run train_vq.m first.');
end
load(modelPath, 'codebooks', 'speakerNames');

% 2. Extract Features
[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);
testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';

% 3. Calculate Distortion
numSpeakers = length(speakerNames);
distortions = zeros(1, numSpeakers);

for i = 1:numSpeakers
    dist = disteu(testCoeffs, codebooks{i});
    distortions(i) = mean(min(dist, [], 2));
end

[minDist, index] = min(distortions);
identifiedName = speakerNames{index};

fprintf('Identified as: %s (Distortion: %.4f)\n', identifiedName, minDist);

end
