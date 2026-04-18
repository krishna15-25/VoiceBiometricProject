% visualize_voiceprint.m
% Visualizes a voice signal, its spectrogram, and its MFCC features

function visualize_voiceprint(wavFile)

% If no file is provided, open a dialog box to pick one
if nargin < 1
    [file, path] = uigetfile('../../data/**/*.wav', 'Select a Voice Sample');
    if isequal(file, 0)
        disp('User selected Cancel');
        return;
    end
    wavFile = fullfile(path, file);
end

[audio, fs] = audioread(wavFile);
preEmphasized = filter([1 -0.97], 1, audio);

% 1. Extract MFCCs (using ~ for unused delta outputs to remove warnings)
[coeffs, ~, ~] = mfcc(preEmphasized, fs, 'NumCoeffs', 13);

% 2. Plotting
figure('Name', ['Voiceprint Analysis: ', wavFile], 'Position', [100 100 800 600]);

% Subplot 1: Time Domain Signal
subplot(3, 1, 1);
plot((1:length(audio))/fs, audio);
title('Time Domain Audio Signal');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

% Subplot 2: Spectrogram
subplot(3, 1, 2);
spectrogram(audio, hamming(400), 200, 1024, fs, 'yaxis');
title('Spectrogram (Frequency Content Over Time)');

% Subplot 3: MFCC Heatmap (The "Voiceprint")
subplot(3, 1, 3);
imagesc(coeffs');
axis xy;
colorbar;
title('Mel-Frequency Cepstral Coefficients (MFCCs)');
xlabel('Frame Index'); ylabel('Coeff Index (1-13)');

end
