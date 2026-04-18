% identify_speaker.m
% Identifies a speaker from an unknown test voice file

function identifiedName = identify_speaker(testFile)

% 1. Load trained models
if ~exist('../results/models.mat', 'file')
    error('No models found! Run train_all.m first.');
end
load('../results/models.mat', 'codebooks', 'speakerNames');

% 2. Extract Features from test voice
[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);
testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13);
testCoeffs = testCoeffs'; % Transpose for distance calculation

% 3. Calculate Distortion for every speaker
numSpeakers = length(speakerNames);
distortions = zeros(1, numSpeakers);

for i = 1:numSpeakers
    % Distance between test MFCCs and current speaker's codebook
    dist = disteu(testCoeffs, codebooks{i});
    % Minimum distance for each test frame, averaged over the utterance
    distortions(i) = mean(min(dist, [], 2));
end

% 4. Find the minimum distortion
[minDist, index] = min(distortions);
identifiedName = speakerNames{index};

fprintf('Test File: %s\n', testFile);
fprintf('Identified as: %s (Distortion: %.4f)\n', identifiedName, minDist);

end
