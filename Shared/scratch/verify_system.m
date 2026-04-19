% verify_system.m
% Sanity check for Voice Biometric System core components

fprintf('--- Starting Sanity Check ---\n');

% 1. Test disteu.m
fprintf('Testing disteu.m... ');
x = [1 0; 0 1]; % Two vectors in 2D
y = [1 0; 0 1];
d = disteu(x, y);
expected = [0 sqrt(2); sqrt(2) 0];
if max(abs(d - expected), [], 'all') < 1e-9
    fprintf('PASSED\n');
else
    fprintf('FAILED (Distance mismatch)\n');
    disp('Calculated:'); disp(d);
    disp('Expected:');   disp(expected);
end

% 2. Test vqlbg.m
fprintf('Testing vqlbg.m... ');
data = [randn(2, 50)+5, randn(2, 50)-5]; % Two clusters
try
    cb = vqlbg(data, 2);
    if size(cb, 2) == 2 && all(abs(mean(cb, 2)) < 5)
        fprintf('PASSED\n');
    else
        fprintf('FAILED (Codebook size or centroid mismatch)\n');
    end
catch ME
    fprintf('FAILED (Error: %s)\n', ME.message);
end

fprintf('--- Sanity Check Complete ---\n');
