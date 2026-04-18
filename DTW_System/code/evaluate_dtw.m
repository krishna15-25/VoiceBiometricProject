% evaluate_dtw.m
function [EER, threshold] = evaluate_dtw()

addpath('../../Shared/code');
testDir = '../../data/test/';
load('../results/templates.mat', 'templates', 'speakerNames');

numSpeakers = length(speakerNames);
genuineScores = [];
impostorScores = [];

fprintf('Comparing all test files against all DTW templates...\n');

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = dir(fullfile(testPath, '*.wav'));
    
    for j = 1:length(wavFiles)
        % Process test file
        [audio, fs] = audioread(fullfile(testPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';
        
        for k = 1:numSpeakers
            % Get templates for target speaker
            speakerTemplates = templates{k};
            minDist = inf;
            % Find match against all templates of this speaker
            for t = 1:length(speakerTemplates)
                d = dtw(testCoeffs, speakerTemplates{t});
                if d < minDist, minDist = d; end
            end
            
            if i == k
                genuineScores = [genuineScores; minDist];
            else
                impostorScores = [impostorScores; minDist];
            end
        end
    end
end

% Statistics calculation
minS = min([genuineScores; impostorScores]);
maxS = max([genuineScores; impostorScores]);
thresholds = linspace(minS, maxS, 100);
far = zeros(size(thresholds)); frr = zeros(size(thresholds));

for i = 1:length(thresholds)
    far(i) = sum(impostorScores < thresholds(i)) / length(impostorScores);
    frr(i) = sum(genuineScores > thresholds(i)) / length(genuineScores);
end

[~, idx] = min(abs(far - frr));
EER = (far(idx) + frr(idx)) / 2;
threshold = thresholds(idx);

save('../results/dtw_performance.mat', 'far', 'frr', 'thresholds', 'EER');
fprintf('DTW Evaluation Complete. EER: %.2f%%\n', EER*100);

end
