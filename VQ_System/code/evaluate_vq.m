% evaluate_vq.m
function [EER, threshold] = evaluate_vq()

addpath('../../Shared/code');
testDir = '../../data/test/';
load('../results/models.mat', 'codebooks', 'speakerNames');

numSpeakers = length(speakerNames);
numCoeffs = 13;
genuineScores = []; impostorScores = [];
confusionMat = zeros(numSpeakers, numSpeakers);

fprintf('Evaluating Optimized High-Res VQ System...\n');

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = [dir(fullfile(testPath, '*.wav')); dir(fullfile(testPath, '*.flac'))];
    
    for j = 1:length(wavFiles)
        try
            [audio, fs] = audioread(fullfile(testPath, wavFiles(j).name));
        catch
            warning('Could not read file %s. Skipping.', wavFiles(j).name);
            continue;
        end
        preEmphasized = filter([1 -0.97], 1, audio);
        
        % Extract MFCCs
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        
        % VAD (Match training threshold)
        energy = coeffs(:,1);
        threshold_vad = min(energy) + 0.7*(max(energy) - min(energy));
        isSpeech = energy > threshold_vad;
        
        % Feature Pruning: Use C2:C13
        testFeats = coeffs(isSpeech, 2:end)'; 
        
        if isempty(testFeats)
            warning('No speech detected in %s. Skipping.', wavFiles(j).name);
            continue;
        end
        
        dists = zeros(1, numSpeakers);
        for k = 1:numSpeakers
            dists(k) = mean(min(disteu(testFeats, codebooks{k}), [], 2));
            if i == k, genuineScores = [genuineScores; dists(k)];
            else, impostorScores = [impostorScores; dists(k)]; end
        end
        [~, id] = min(dists);
        confusionMat(i, id) = confusionMat(i, id) + 1;
    end
end

% Stats calculation
rowSums = sum(confusionMat, 2);
rowSums(rowSums == 0) = 1; % Prevent division by zero
confusionMat = (confusionMat ./ rowSums) * 100;

figure('Name', 'Optimized VQ Results');
imagesc(confusionMat); colorbar; title('Optimized VQ Confusion Matrix (%)');

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

save('../results/performance_results.mat', 'far', 'frr', 'EER', 'threshold');
fprintf('Final Optimized VQ EER: %.2f%%\n', EER*100);
end
