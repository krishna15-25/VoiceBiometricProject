% train_dtw.m
function train_dtw()
addpath('../../Shared/code'); 
trainDir = '../../data/train/';
fs = 16000; numCoeffs = 13;

speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));
numSpeakers = length(speakerFolders);

templates = cell(1, numSpeakers);
speakerNames = {speakerFolders.name};

fprintf('Training Cleaned DTW (VAD + Feature Pruning) for %d speakers...\n', numSpeakers);

for i = 1:numSpeakers
    speakerName = speakerNames{i};
    speakerPath = fullfile(trainDir, speakerName);
    wavFiles = [dir(fullfile(speakerPath, '*.wav')); dir(fullfile(speakerPath, '*.flac'))];
    
    speakerTemplates = cell(1, length(wavFiles));
    for j = 1:length(wavFiles)
        try
            [audio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
        catch
            warning('Could not read file %s. Skipping.', wavFiles(j).name);
            continue;
        end
        preEmphasized = filter([1 -0.97], 1, audio);
        coeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);
        
        % VAD (Remove silence)
        energy = coeffs(:,1);
        threshold = min(energy) + 0.7*(max(energy) - min(energy));
        isSpeech = energy > threshold;
        
        % Feature Pruning (Keep C2:C13)
        currentFeats = coeffs(isSpeech, 2:end)';
        if ~isempty(currentFeats)
            speakerTemplates{j} = currentFeats; 
        end
    end
    % Remove empty entries if any files were skipped
    speakerTemplates = speakerTemplates(~cellfun('isempty', speakerTemplates));
    templates{i} = speakerTemplates;
end

if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/templates.mat', 'templates', 'speakerNames');
disp('Cleaned DTW Templates Saved.');
end
