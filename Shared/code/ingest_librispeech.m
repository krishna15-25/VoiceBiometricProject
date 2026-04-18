% ingest_librispeech.m
% Moves files from a LibriSpeech dev-clean folder into the project structure

function ingest_librispeech(sourcePath)
% sourcePath: Path to 'LibriSpeech/dev-clean'

if nargin < 1
    sourcePath = uigetdir('', 'Select the LibriSpeech/dev-clean folder');
    if isequal(sourcePath, 0), return; end
end

targetTrain = '../../data/train';
targetTest = '../../data/test';

% Get list of speakers
speakerDirs = dir(sourcePath);
speakerDirs = speakerDirs([speakerDirs.isdir] & ~startsWith({speakerDirs.name}, '.'));

fprintf('Ingesting LibriSpeech data...\n');

% Only take the first 10-20 speakers for now (to keep it fast)
numToIngest = min(20, length(speakerDirs));

for i = 1:numToIngest
    speakerID = speakerDirs(i).name;
    speakerFolder = fullfile(sourcePath, speakerID);
    
    % Find all .flac files for this speaker (recursively)
    files = dir(fullfile(speakerFolder, '**/*.flac'));
    
    if length(files) < 10, continue; end % Skip if too little data
    
    % Create target folders
    trainPath = fullfile(targetTrain, ['libri_', speakerID]);
    testPath = fullfile(targetTest, ['libri_', speakerID]);
    if ~exist(trainPath, 'dir'), mkdir(trainPath); end
    if ~exist(testPath, 'dir'), mkdir(testPath); end
    
    % Move 8 files to train, 2 to test
    for j = 1:8
        copyfile(fullfile(files(j).folder, files(j).name), fullfile(trainPath, [files(j).name]));
    end
    for j = 9:min(10, length(files))
        copyfile(fullfile(files(j).folder, files(j).name), fullfile(testPath, [files(j).name]));
    end
    
    fprintf('  Ingested Speaker %s\n', speakerID);
end

disp('LibriSpeech ingestion complete. Note: Update scripts to handle .flac files.');
end
