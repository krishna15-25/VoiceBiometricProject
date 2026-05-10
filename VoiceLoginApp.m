% VoiceLoginApp.m
% A Secure Biometric Login Interface using GMM Voice Recognition

function VoiceLoginApp
    % 1. Main Figure Setup
    fig = uifigure('Name', 'Secure Biometric Portal', 'Position', [100 100 800 500], 'Color', [0.95 0.95 0.95]);
    addpath(genpath('../../')); 

    % --- PANEL 1: LOGIN PAGE ---
    loginPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'BackgroundColor', [0.1 0.1 0.2]);
    
    uilabel(loginPanel, 'Text', 'BIOMETRIC LOGIN', 'Position', [0 350 800 50], ...
        'FontSize', 32, 'FontWeight', 'bold', 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    uilabel(loginPanel, 'Text', 'Please record your voice to verify your identity', 'Position', [0 310 800 30], ...
        'FontSize', 14, 'FontColor', [0.7 0.7 0.8], 'HorizontalAlignment', 'center');

    % Status Icon (Circle)
    statusLight = uilabel(loginPanel, 'Text', char(11044), 'Position', [385 220 30 30], ...
        'FontSize', 24, 'FontColor', [0.5 0.5 0.5], 'HorizontalAlignment', 'center');

    % Record Button
    btnLogin = uibutton(loginPanel, 'Text', 'RECORD & LOGIN', 'Position', [300 150 200 50], ...
        'BackgroundColor', [0.2 0.4 0.8], 'FontColor', 'w', 'FontSize', 16, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn,event) performLogin());

    lblStatus = uilabel(loginPanel, 'Text', 'Ready for voice authentication', 'Position', [0 100 800 30], ...
        'FontSize', 12, 'FontColor', 'w', 'HorizontalAlignment', 'center');

    % --- PANEL 2: SUCCESS PAGE (Hidden by default) ---
    successPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'Visible', 'off', 'BackgroundColor', [0.95 0.98 0.95]);
    
    uilabel(successPanel, 'Text', char(9989), 'Position', [0 300 800 100], ...
        'FontSize', 72, 'FontColor', [0.2 0.6 0.2], 'HorizontalAlignment', 'center');
    
    lblWelcome = uilabel(successPanel, 'Text', 'ACCESS GRANTED', 'Position', [0 230 800 50], ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontColor', [0.1 0.3 0.1], 'HorizontalAlignment', 'center');
    
    uilabel(successPanel, 'Text', 'You have successfully logged into the Secure Environment.', 'Position', [0 180 800 30], ...
        'FontSize', 16, 'HorizontalAlignment', 'center');

    uibutton(successPanel, 'Text', 'LOGOUT', 'Position', [350 80 100 30], ...
        'ButtonPushedFcn', @(btn,event) logout());

    % --- LOGIN LOGIC ---
    function performLogin()
        % UI Feedback
        btnLogin.Enable = 'off';
        lblStatus.Text = 'LISTENING... Please speak clearly.';
        statusLight.FontColor = [1 0.2 0.2]; % Red for recording
        drawnow;

        % 1. Record Audio (5 seconds)
        fs = 16000; duration = 4;
        rec = audiorecorder(fs, 16, 1);
        recordblocking(rec, duration);
        
        lblStatus.Text = 'ANALYZING BIOMETRICS...';
        statusLight.FontColor = [1 0.8 0]; % Yellow for processing
        drawnow;

        % 2. Process and Identify
        audioData = getaudiodata(rec);
        tempFile = 'login_attempt.wav';
        audiowrite(tempFile, audioData, fs);

        try
            cd ../../GMM_System/code
            speakerName = identify_speaker_gmm(fullfile('../../Shared/code', tempFile));
            cd ../../Shared/code
            
            % 3. Transition to Success Page
            loginPanel.Visible = 'off';
            successPanel.Visible = 'on';
            lblWelcome.Text = ['WELCOME BACK, ', upper(speakerName)];
            
        catch ME
            cd ../../Shared/code
            lblStatus.Text = ['Authentication Failed: ', ME.message];
            btnLogin.Enable = 'on';
            statusLight.FontColor = [0.5 0.5 0.5];
        end
    end

    function logout()
        successPanel.Visible = 'off';
        loginPanel.Visible = 'on';
        btnLogin.Enable = 'on';
        lblStatus.Text = 'Ready for voice authentication';
        statusLight.FontColor = [0.5 0.5 0.5];
    end
end
