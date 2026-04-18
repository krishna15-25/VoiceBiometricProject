% train_all.m
% Enrolls all speakers found in data/train/ and saves codebooks

% Parameters
fs = 16000;
numCoeffs = 13;
codebookSize = 16;
trainDir = '../data/train/';

% Get list of speaker folders
speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));

numSpeakers = length(speakerFolders);
codebooks = cell(1, numSpeakers);
speakerNames = {speakerFolders.name};

fprintf('Starting enrollment for %d speakers...\n', numSpeakers);

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    speakerPath = fullfile(trainDir, speakerName);
    wavFiles = dir(fullfile(speakerPath, '*.wav'));
    
    fprintf('  Processing %s (%d files)...\n', speakerName, length(wavFiles));
    
    % Concatenate MFCCs from all training files for this speaker
    all_coeffs = [];
    for j = 1:length(wavFiles)
        [audio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
        
        % Pre-emphasis
        preEmphasized = filter([1 -0.97], 1, audio);
        
        % Feature Extraction
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        all_coeffs = [all_coeffs; coeffs];
    end
    
    % Build VQ Codebook (transpose for vqlbg: needs columns as vectors)
    codebooks{i} = vqlbg(all_coeffs', codebookSize);
end

% Save models to results folder
if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/models.mat', 'codebooks', 'speakerNames');
fprintf('\nEnrollment complete! Models saved to results/models.mat\n');
