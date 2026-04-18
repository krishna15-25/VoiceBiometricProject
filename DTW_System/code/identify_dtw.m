% identify_dtw.m
function identifiedName = identify_dtw(testFile)

addpath('../../Shared/code');

% 1. Load pre-extracted templates
if ~exist('../results/templates.mat', 'file')
    error('No templates found! Run train_dtw.m first.');
end
load('../results/templates.mat', 'templates', 'speakerNames');

% 2. Process test voice
[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);
testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';

% 3. Compare testCoeffs against ALL templates
numSpeakers = length(speakerNames);
bestDist = inf;
identifiedName = 'Unknown';

for i = 1:numSpeakers
    speakerTemplates = templates{i};
    minDistForSpeaker = inf;
    
    % Match against every reference recording of this speaker
    for j = 1:length(speakerTemplates)
        % dtw() aligns and calculates Euclidean distance
        d = dtw(testCoeffs, speakerTemplates{j});
        if d < minDistForSpeaker
            minDistForSpeaker = d;
        end
    end
    
    if minDistForSpeaker < bestDist
        bestDist = minDistForSpeaker;
        identifiedName = speakerNames{i};
    end
end

fprintf('DTW Result: %s (Distance: %.2f)\n', identifiedName, bestDist);

end
