% compare_systems.m
% Runs VQ, DTW, and GMM systems side-by-side for comparison

fprintf('=== VOICE BIOMETRIC SYSTEM COMPARISON ===\n\n');

% 1. VQ System (Optimized Baseline)
fprintf('Step 1: Training and Evaluating VQ System...\n');
cd VQ_System/code
train_vq; 
[eer_vq, ~] = evaluate_vq;
cd ../..

% 2. DTW System (Temporal Alignment)
fprintf('\nStep 2: Training and Evaluating DTW System...\n');
cd DTW_System/code
train_dtw; 
[eer_dtw, ~] = evaluate_dtw;
cd ../..

% 3. GMM System (State-of-the-Art)
fprintf('\nStep 3: Training and Evaluating GMM System...\n');
cd GMM_System/code
train_gmm;
[eer_gmm, ~] = evaluate_gmm;
cd ../..

% 4. Final Comparison Table
fprintf('\n\n=======================================================\n');
fprintf('           FINAL PERFORMANCE COMPARISON                \n');
fprintf('=======================================================\n');
fprintf('Metric          | VQ System    | DTW System    | GMM System  \n');
fprintf('----------------|--------------|---------------|-------------\n');
fprintf('EER (%%)         | %6.2f%%     | %6.2f%%      | %6.2f%%    \n', eer_vq*100, eer_dtw*100, eer_gmm*100);
fprintf('Complexity      | Moderate     | High          | Very High   \n');
fprintf('Mechanism       | Clustering   | Alignment     | Probabilistic\n');
fprintf('=======================================================\n');
