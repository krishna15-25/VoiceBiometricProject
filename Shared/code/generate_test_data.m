% generate_test_data.m
% Run this from Shared/code/

fs = 16000;
duration = 2;
t = 0:1/fs:duration-1/fs;

speakers = {'speaker1', 'speaker2', 'speaker3'};
baseDir = '../../data'; % Look up two levels

for s = 1:length(speakers)
    name = speakers{s};
    trainPath = fullfile(baseDir, 'train', name);
    testPath = fullfile(baseDir, 'test', name);
    if ~exist(trainPath, 'dir'), mkdir(trainPath); end
    if ~exist(testPath, 'dir'), mkdir(testPath); end
    
    freqs = randi([100 1000], 1, 3); 
    for i = 1:5
        signal = 0.3*sin(2*pi*freqs(1)*t) + 0.1*sin(2*pi*freqs(2)*t) + 0.05*randn(size(t));
        audiowrite(fullfile(trainPath, sprintf('trial%d.wav', i)), signal, fs);
    end
    for i = 1:2
        signal = 0.3*sin(2*pi*freqs(1)*t) + 0.1*sin(2*pi*freqs(2)*t) + 0.05*randn(size(t));
        audiowrite(fullfile(testPath, sprintf('test%d.wav', i)), signal, fs);
    end
end
disp('Data Generated in VoiceBiometricProject/data/');
