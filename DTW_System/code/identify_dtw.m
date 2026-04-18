% identify_dtw.m
function identifiedName = identify_dtw(testFile)

addpath('../../Shared/code');
load('../results/templates.mat', 'templates', 'speakerNames');

[audio, fs] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);
testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';

numSpeakers = length(speakerNames);
bestDist = inf;
identifiedName = 'Unknown';

for i = 1:numSpeakers
    speakerTemplates = templates{i};
    minDistForSpeaker = inf;
    for j = 1:length(speakerTemplates)
        d = dtw(testCoeffs, speakerTemplates{j});
        if d < minDistForSpeaker, minDistForSpeaker = d; end
    end
    if minDistForSpeaker < bestDist
        bestDist = minDistForSpeaker;
        identifiedName = speakerNames{i};
    end
end
fprintf('DTW Result: %s (Dist: %.2f)\n', identifiedName, bestDist);
end
