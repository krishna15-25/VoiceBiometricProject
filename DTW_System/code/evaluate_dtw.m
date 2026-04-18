% evaluate_dtw.m
function [EER, threshold] = evaluate_dtw()

addpath('../../Shared/code');
testDir = '../../data/test/';
load('../results/templates.mat', 'templates', 'speakerNames');

numSpeakers = length(speakerNames);
numCoeffs = 13;
chunkSize = 50; % ~0.5 seconds
genuineScores = []; impostorScores = [];

fprintf('Evaluating Segmental-DTW (Chunked Alignment)...\n');

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = [dir(fullfile(testPath, '*.wav')); dir(fullfile(testPath, '*.flac'))];
    
    for j = 1:length(wavFiles)
        [audio, fs] = audioread(fullfile(testPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        
        energy = coeffs(:,1);
        isSpeech = energy > (min(energy) + 0.7*(max(energy) - min(energy)));
        testFeats = coeffs(isSpeech, 2:end)';
        
        numFrames = size(testFeats, 2);
        if numFrames < 5, continue; end
        
        currentChunkSize = min(chunkSize, numFrames);
        mid = max(1, round(numFrames/2) - round(currentChunkSize/2));
        testChunk = testFeats(:, mid:mid+currentChunkSize-1);
        
        for k = 1:numSpeakers
            speakerTemplates = templates{k};
            allTemplateDists = [];
            
            for t = 1:length(speakerTemplates)
                ref = speakerTemplates{t};
                [d, ix, ~] = dtw(testChunk, ref);
                allTemplateDists = [allTemplateDists; d/length(ix)];
            end
            
            minDist = min(allTemplateDists);
            if i == k
                genuineScores = [genuineScores; minDist];
            else
                impostorScores = [impostorScores; minDist];
            end
        end
    end
end

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

save('../results/dtw_performance.mat', 'far', 'frr', 'EER', 'threshold');
fprintf('Final Segmental-DTW EER: %.2f%%\n', EER*100);
end
