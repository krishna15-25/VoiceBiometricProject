% TrainAndSwapBrain.m
% Script to train a high-performance GMM engine and install it as the new project brain.

fprintf('=========================================\n');
fprintf('   HIGH-PERFORMANCE VOICE ENGINE TRAIN   \n');
fprintf('=========================================\n\n');

% 1. Add paths
addpath(genpath('GMM_System/code'));
addpath(genpath('Shared/code'));

% 2. Trigger the improved training
try
    fprintf('STATUS: Initiating large-scale GMM training...\n');
    train_gmm();
    
    fprintf('\nSUCCESS: High-performance brain has been trained and installed.\n');
    fprintf('The system now has a robust baseline with LibriSpeech + your recordings.\n');
    
    % 3. Verify the model file
    modelPath = 'GMM_System/results/gmm_models.mat';
    if exist(modelPath, 'file')
        data = load(modelPath);
        fprintf('IDENTIFIED SPEAKERS: %d\n', length(data.speakerNames));
        disp('Speakers in database:');
        disp(data.speakerNames);
    end
    
catch ME
    fprintf('\nERROR: Training failed - %s\n', ME.message);
end
