% evaluate_performance.m
% Computes FAR, FRR and plots the DET curve for the system

function [EER, threshold] = evaluate_performance()

% 1. Load models
if ~exist('../results/models.mat', 'file')
    error('No models found! Run train_all.m first.');
end
load('../results/models.mat', 'codebooks', 'speakerNames');

% 2. Get all test files
testDir = '../data/test/';
numSpeakers = length(speakerNames);
genuineScores = [];
impostorScores = [];

fprintf('Calculating similarity scores for all test files...\n');

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    testPath = fullfile(testDir, speakerName);
    wavFiles = dir(fullfile(testPath, '*.wav'));
    
    for j = 1:length(wavFiles)
        testFile = fullfile(testPath, wavFiles(j).name);
        
        % Process test file (MFCC extraction)
        [audio, fs] = audioread(testFile);
        preEmphasized = filter([1 -0.97], 1, audio);
        testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', 13)';
        
        % Compare against EVERY codebook
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

% 3. Sweep thresholds to find FAR and FRR
minScore = min([genuineScores; impostorScores]);
maxScore = max([genuineScores; impostorScores]);
thresholds = linspace(minScore, maxScore, 100);

far = zeros(size(thresholds));
frr = zeros(size(thresholds));

for i = 1:length(thresholds)
    t = thresholds(i);
    % FAR: Impostors with score BELOW threshold (incorrectly accepted)
    far(i) = sum(impostorScores < t) / length(impostorScores);
    % FRR: Genuines with score ABOVE threshold (incorrectly rejected)
    frr(i) = sum(genuineScores > t) / length(genuineScores);
end

% 4. Find EER (where FAR and FRR are closest)
[~, idx] = min(abs(far - frr));
EER = (far(idx) + frr(idx)) / 2;
threshold = thresholds(idx);

% 5. Plotting (Slide 9)
figure;
plot(thresholds, far*100, 'r', 'LineWidth', 2); hold on;
plot(thresholds, frr*100, 'b', 'LineWidth', 2);
plot(threshold, EER*100, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
xlabel('Threshold (Distortion)');
ylabel('Error Rate (%)');
legend('FAR (False Acceptance)', 'FRR (False Rejection)', 'EER');
title(['Performance Analysis: EER = ', num2str(EER*100, '%.2f'), '%']);
grid on;

% Save results
save('../results/performance_results.mat', 'far', 'frr', 'thresholds', 'EER');
fprintf('\nAnalysis complete! EER: %.2f%%\n', EER*100);

end
