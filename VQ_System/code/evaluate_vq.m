% evaluate_vq.m
function [EER, threshold] = evaluate_vq()

addpath('../../Shared/code');
testDir = '../../data/test/';
load('../results/models.mat', 'codebooks', 'speakerNames');

numSpeakers = length(speakerNames);
genuineScores = [];
impostorScores = [];

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = dir(fullfile(testPath, '*.wav'));
    
    for j = 1:length(wavFiles)
        [audio, fs] = audioread(fullfile(testPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';
        
        for k = 1:numSpeakers
            dist = disteu(testCoeffs, codebooks{k});
            score = mean(min(dist, [], 2));
            if i == k
                genuineScores = [genuineScores; score];
            else
                impostorScores = [impostorScores; score];
            end
        end
    end
end

% ... [Rest of plotting logic] ...
thresholds = linspace(min([genuineScores; impostorScores]), max([genuineScores; impostorScores]), 100);
far = zeros(size(thresholds)); frr = zeros(size(thresholds));
for i = 1:length(thresholds)
    far(i) = sum(impostorScores < thresholds(i)) / length(impostorScores);
    frr(i) = sum(genuineScores > thresholds(i)) / length(genuineScores);
end
[~, idx] = min(abs(far - frr));
EER = (far(idx) + frr(idx)) / 2; threshold = thresholds(idx);

save('../results/performance_results.mat', 'far', 'frr', 'thresholds', 'EER');
disp(['EER: ', num2str(EER*100), '%']);
end
