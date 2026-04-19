% evaluate_gmm.m
function [EER, threshold] = evaluate_gmm()

addpath('../../Shared/code');
testDir = '../../data/test/';
load('../results/gmm_models.mat', 'gmmModels', 'speakerNames');

numSpeakers = length(speakerNames);
numCoeffs = 13;
genuineScores = []; impostorScores = [];

fprintf('Evaluating Optimized GMM System...\n');

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = [dir(fullfile(testPath, '*.wav')); dir(fullfile(testPath, '*.flac'))];
    
    for j = 1:length(wavFiles)
        [audio, fs] = audioread(fullfile(testPath, wavFiles(j).name));
        preEmphasized = filter([1 -0.97], 1, audio);
        
        % Extract MFCCs
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        
        % VAD (Same as training)
        energy = coeffs(:,1);
        isSpeech = energy > (min(energy) + 0.7*(max(energy) - min(energy)));
        testFeats = coeffs(isSpeech, 2:end); % Use C2:C13
        
        logLikelihoods = zeros(1, numSpeakers);
        for k = 1:numSpeakers
            if ~isempty(gmmModels{k})
                logLikelihoods(k) = sum(log(pdf(gmmModels{k}, testFeats)));
            else
                logLikelihoods(k) = -inf;
            end
            
            % Normalize Likelihood by frame count
            score = -logLikelihoods(k) / size(testFeats, 1);
            if i == k, genuineScores = [genuineScores; score];
            else, impostorScores = [impostorScores; score]; end
        end
    end
end

% Stats calculation
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

save('../results/gmm_performance.mat', 'far', 'frr', 'EER', 'threshold');
fprintf('Final Optimized GMM EER: %.2f%%\n', EER*100);
end
