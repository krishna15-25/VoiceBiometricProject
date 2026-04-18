% identify_dtw.m
% Identifies a speaker using Dynamic Time Warping (Template Matching)

function identifiedName = identify_dtw(testFile)

% 1. Parameters
fs = 16000;
trainDir = '../../data/train/';
numCoeffs = 13;

% 2. Extract Features from test voice
[audio, ~] = audioread(testFile);
preEmphasized = filter([1 -0.97], 1, audio);
testCoeffs = mfcc(preEmphasized, fs, 'NumCoeffs', numCoeffs);

% 3. Get all speakers
speakerFolders = dir(trainDir);
speakerFolders = speakerFolders([speakerFolders.isdir] & ~startsWith({speakerFolders.name}, '.'));
numSpeakers = length(speakerFolders);

bestDist = inf;
identifiedName = 'Unknown';

fprintf('Comparing test file using DTW...\n');

for i = 1:numSpeakers
    speakerName = speakerFolders(i).name;
    speakerPath = fullfile(trainDir, speakerName);
    wavFiles = dir(fullfile(speakerPath, '*.wav'));
    
    % Compare test file against EACH training file of this speaker
    % and take the minimum distance found
    speakerMinDist = inf;
    
    for j = 1:length(wavFiles)
        [refAudio, ~] = audioread(fullfile(speakerPath, wavFiles(j).name));
        refPre = filter([1 -0.97], 1, refAudio);
        refCoeffs = mfcc(refPre, fs, 'NumCoeffs', numCoeffs);
        
        % MATLAB Built-in DTW (Slide 8)
        % dtw() calculates the distance between the two MFCC sequences
        d = dtw(testCoeffs', refCoeffs');
        
        if d < speakerMinDist
            speakerMinDist = d;
        end
    end
    
    fprintf('  Distance to %s: %.2f\n', speakerName, speakerMinDist);
    
    if speakerMinDist < bestDist
        bestDist = speakerMinDist;
        identifiedName = speakerName;
    end
end

fprintf('\nFinal DTW Result: Identified as %s\n', identifiedName);

end
