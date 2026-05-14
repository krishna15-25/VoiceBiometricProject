% VoiceLoginApp.m
% A Secure Biometric Login & Signup Portal using GMM Voice Recognition (Passphrase Edition)

function VoiceLoginApp
    % 1. Main Figure Setup
    fig = uifigure('Name', 'Secure Biometric Portal', 'Position', [100 100 800 500], 'Color', [0.95 0.95 0.95]);
    
    % Add paths relative to ROOT
    addpath(genpath('Shared/code'));
    addpath(genpath('GMM_System/code'));
    addpath(genpath('VQ_System/code'));

    % Global variables for state management
    signupSamples = 0;
    maxSignupSamples = 5;

    % --- PANEL: SIGNUP PAGE ---
    signupPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'Visible', 'off', 'BackgroundColor', [0.15 0.15 0.25]);
    uilabel(signupPanel, 'Text', 'CREATE ACCOUNT', 'Position', [0 400 800 50], ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    uilabel(signupPanel, 'Text', 'Choose Username:', 'Position', [300 330 200 25], 'FontColor', 'w');
    txtSignupUser = uieditfield(signupPanel, 'Position', [300 300 200 30]);
    
    lblSignupStatus = uilabel(signupPanel, 'Text', 'Choose a SECRET PASSPHRASE and record it 5 times', 'Position', [0 260 800 30], ...
        'FontSize', 12, 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    btnRecordSignup = uibutton(signupPanel, 'Text', 'RECORD PASSPHRASE (0/5)', 'Position', [300 180 200 50], ...
        'BackgroundColor', [0.8 0.4 0.2], 'FontColor', 'w', 'FontSize', 14, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn,event) performSignupRecording());
    
    % --- PANEL: LOGIN PAGE ---
    loginPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'Visible', 'off', 'BackgroundColor', [0.1 0.1 0.2]);
    uilabel(loginPanel, 'Text', 'BIOMETRIC LOGIN', 'Position', [0 400 800 50], ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    uilabel(loginPanel, 'Text', 'Username:', 'Position', [300 330 200 25], 'FontColor', 'w');
    txtLoginUser = uieditfield(loginPanel, 'Position', [300 300 200 30]);
    
    lblLoginStatus = uilabel(loginPanel, 'Text', 'Speak your SECRET PASSPHRASE to login', 'Position', [0 260 800 30], ...
        'FontSize', 12, 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    btnLoginAction = uibutton(loginPanel, 'Text', 'RECORD & VERIFY', 'Position', [300 180 200 50], ...
        'BackgroundColor', [0.2 0.4 0.8], 'FontColor', 'w', 'FontSize', 14, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn,event) performLoginVerification());
    
    % --- PANEL: SUCCESS PAGE ---
    successPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'Visible', 'off', 'BackgroundColor', [0.95 0.98 0.95]);
    uilabel(successPanel, 'Text', char(9989), 'Position', [0 300 800 100], ...
        'FontSize', 72, 'FontColor', [0.2 0.6 0.2], 'HorizontalAlignment', 'center');
    lblWelcome = uilabel(successPanel, 'Text', 'ACCESS GRANTED', 'Position', [0 230 800 50], ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontColor', [0.1 0.3 0.1], 'HorizontalAlignment', 'center');
    uilabel(successPanel, 'Text', 'You have successfully logged into the Secure Environment.', 'Position', [0 180 800 30], ...
        'FontSize', 16, 'HorizontalAlignment', 'center');
    uibutton(successPanel, 'Text', 'LOGOUT', 'Position', [350 80 100 30], ...
        'ButtonPushedFcn', @(btn,event) showPanel([])); 

    % --- PANEL: LANDING PAGE ---
    landingPanel = uipanel(fig, 'Position', [0 0 800 500], 'BorderType', 'none', 'BackgroundColor', [0.1 0.1 0.2]);
    uilabel(landingPanel, 'Text', 'VOICE BIOMETRIC PORTAL', 'Position', [0 350 800 60], ...
        'FontSize', 36, 'FontWeight', 'bold', 'FontColor', 'w', 'HorizontalAlignment', 'center');
    
    uibutton(landingPanel, 'Text', 'LOGIN', 'Position', [300 240 200 60], ...
        'BackgroundColor', [0.2 0.6 0.2], 'FontColor', 'w', 'FontSize', 18, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn,event) showPanel(loginPanel));
    
    uibutton(landingPanel, 'Text', 'SIGN UP', 'Position', [300 140 200 60], ...
        'BackgroundColor', [0.2 0.4 0.8], 'FontColor', 'w', 'FontSize', 18, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(btn,event) showPanel(signupPanel));

    % Add BACK buttons
    uibutton(signupPanel, 'Text', 'BACK', 'Position', [20 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) showPanel(landingPanel));
    uibutton(loginPanel, 'Text', 'BACK', 'Position', [20 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) showPanel(landingPanel));

    % --- HELPER: SHOW PANEL ---
    function showPanel(targetPanel)
        if isempty(targetPanel), targetPanel = landingPanel; end
        landingPanel.Visible = 'off';
        signupPanel.Visible = 'off';
        loginPanel.Visible = 'off';
        successPanel.Visible = 'off';
        targetPanel.Visible = 'on';
        
        if targetPanel == signupPanel
            signupSamples = 0;
            btnRecordSignup.Text = 'RECORD PASSPHRASE (0/5)';
            btnRecordSignup.Enable = 'on';
            txtSignupUser.Value = '';
            txtSignupUser.Editable = 'on';
            lblSignupStatus.Text = 'Choose a SECRET PASSPHRASE and record it 5 times';
            lblSignupStatus.FontColor = 'w';
        elseif targetPanel == loginPanel
            txtLoginUser.Value = '';
            txtLoginUser.Editable = 'on';
            btnLoginAction.Enable = 'on';
            lblLoginStatus.Text = 'Speak your SECRET PASSPHRASE to login';
            lblLoginStatus.FontColor = 'w';
        end
    end

    % --- LOGIC: SIGNUP ---
    function performSignupRecording()
        user = strtrim(txtSignupUser.Value);
        if isempty(user)
            lblSignupStatus.Text = 'ERROR: Please enter a username first!';
            lblSignupStatus.FontColor = [1 0.3 0.3];
            return;
        end
        
        txtSignupUser.Editable = 'off';
        signupSamples = signupSamples + 1;
        btnRecordSignup.Enable = 'off';
        lblSignupStatus.Text = sprintf('SPEAK PASSPHRASE NOW (%d/5)...', signupSamples);
        lblSignupStatus.FontColor = [1 0.8 0];
        drawnow;

        fs = 16000; duration = 4;
        rec = audiorecorder(fs, 16, 1);
        recordblocking(rec, duration);
        
        audioData = getaudiodata(rec);
        userDir = fullfile('data', 'train', user);
        if ~exist(userDir, 'dir'), mkdir(userDir); end
        audiowrite(fullfile(userDir, sprintf('sample_%d.wav', signupSamples)), audioData, fs);

        btnRecordSignup.Text = sprintf('RECORD PASSPHRASE (%d/5)', signupSamples);
        
        if signupSamples >= maxSignupSamples
            lblSignupStatus.Text = 'TRAINING SECURE ENGINE... Please wait.';
            drawnow;
            try
                train_gmm(); 
                lblSignupStatus.Text = 'SIGNUP COMPLETE! You can now log in.';
                lblSignupStatus.FontColor = [0.4 1 0.4];
                btnRecordSignup.Text = 'DONE';
            catch ME
                lblSignupStatus.Text = ['Training Error: ', ME.message];
            end
        else
            lblSignupStatus.Text = 'Passphrase captured! Click to record again.';
            lblSignupStatus.FontColor = [0.4 1 0.4];
            btnRecordSignup.Enable = 'on';
        end
    end

    % --- LOGIC: LOGIN ---
    function performLoginVerification()
        user = strtrim(txtLoginUser.Value);
        if isempty(user)
            lblLoginStatus.Text = 'ERROR: Please enter your username!';
            lblLoginStatus.FontColor = [1 0.3 0.3];
            return;
        end

        btnLoginAction.Enable = 'off';
        lblLoginStatus.Text = 'SPEAK PASSPHRASE NOW...';
        lblLoginStatus.FontColor = [1 0.8 0];
        drawnow;

        fs = 16000; duration = 4;
        rec = audiorecorder(fs, 16, 1);
        recordblocking(rec, duration);
        
        lblLoginStatus.Text = 'VERIFYING PASSPHRASE...';
        drawnow;

        audioData = getaudiodata(rec);
        tempFile = 'results/login_attempt.wav';
        audiowrite(tempFile, audioData, fs);

        try
            identifiedName = identify_speaker_gmm(tempFile);
            if strcmpi(identifiedName, user)
                showPanel(successPanel);
                lblWelcome.Text = ['WELCOME BACK, ', upper(user)];
            else
                lblLoginStatus.Text = 'ACCESS DENIED: Passphrase or Voice incorrect.';
                lblLoginStatus.FontColor = [1 0.3 0.3];
                btnLoginAction.Enable = 'on';
            end
        catch ME
            lblLoginStatus.Text = ['Auth Error: ', ME.message];
            btnLoginAction.Enable = 'on';
        end
    end
end
