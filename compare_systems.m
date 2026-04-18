% compare_systems.m
% Runs both VQ and DTW systems on the current dataset and compares them

fprintf('=== VOICE BIOMETRIC SYSTEM COMPARISON ===\n\n');

% 1. Run VQ System
fprintf('Step 1: Training and Evaluating VQ System...\n');
cd VQ_System/code
train_vq; 
[eer_vq, ~] = evaluate_vq;
cd ../..

% 2. Run DTW System
fprintf('\nStep 2: Training and Evaluating DTW System...\n');
cd DTW_System/code
train_dtw; 
[eer_dtw, ~] = evaluate_dtw;
cd ../..

% 3. Display Results Table
fprintf('\n\n=========================================\n');
fprintf('       FINAL PERFORMANCE COMPARISON      \n');
fprintf('=========================================\n');
fprintf('Metric          | VQ System    | DTW System  \n');
fprintf('----------------|--------------|-------------\n');
fprintf('EER (%%)         | %6.2f%%     | %6.2f%%    \n', eer_vq*100, eer_dtw*100);
fprintf('Approach        | Probabilistic| Template    \n');
fprintf('Best For        | Text-Indep.  | Text-Dep.   \n');
fprintf('=========================================\n');
