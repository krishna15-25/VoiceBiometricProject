% main_pipeline.m
% Core processing script for Speaker Identification

%% 1. Parameters
fs = 16000;
numCoeffs = 13;
codebookSize = 16; % M=16 per Slide 15

%% 2. Feature Extraction (Reynolds Pipeline)
% Example for one speaker (to be looped)
[audio, fs_load] = audioread('../data/train/speaker1/trial1.wav');

% Pre-emphasis
preEmphasized = filter([1 -0.97], 1, audio);

% MFCC Extraction
coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);

%% 3. Modeling (VQ)
% Note: You will need to implement or include the vqlbg.m function
% codebook = vqlbg(coeffs, codebookSize);

disp('Pipeline initialized. Ready for LBG implementation.');
