function r = vqlbg(d, k)
% VQLBG Vector quantization using the LBG algorithm
%
% d contains training vectors as columns
% k is the number of codevectors (must be a power of 2)
%
% Result r is a matrix with k columns, each being a codevector

% Initial codevector is the average of all training vectors
r = mean(d, 2);
nve = 1;

while nve < k
    % Split each codevector into two
    r = [r*(1+0.01), r*(1-0.01)];
    nve = nve * 2;
    
    while 1
        % Compute distance between all training vectors and all codevectors
        z = disteu(d, r);
        
        % Find the nearest codevector for each training vector
        [~, ind] = min(z, [], 2);
        
        t = 0;
        for i = 1:nve
            % Update each codevector to be the mean of its assigned training vectors
            subset = d(:, ind==i);
            if ~isempty(subset)
                r(:, i) = mean(subset, 2);
                % Compute distortion
                x = disteu(subset, r(:, i));
                t = t + sum(x);
            else
                % If no vectors assigned, keep the centroid or perturb it
                % to avoid NaNs but this case is rare with large dataset
                warning('Cluster %d is empty. Maintaining previous centroid.', i);
            end
        end
        
        % Check for convergence (simple version)
        if exist('t_old', 'var') && (t_old - t) / t < 0.001
            break;
        end
        t_old = t;
    end
end
