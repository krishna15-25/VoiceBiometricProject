function d = disteu(x, y)
% DISTEU Pairwise Euclidean distance between columns of x and y
%
% x: matrix of size [D, M]
% y: matrix of size [D, N]
% d: matrix of size [M, N] where d(i,j) is the distance from x(:,i) to y(:,j)

[M, ~] = size(x);
[N, ~] = size(y);

% x2 = sum(x.^2, 1);
% y2 = sum(y.^2, 1);
% d = repmat(x2', 1, N) + repmat(y2, M, 1) - 2*x'*y;
% d = sqrt(max(d, 0));

% Vectorized version for MATLAB efficiency
d = zeros(size(x, 2), size(y, 2));
for i = 1:size(y, 2)
    d(:, i) = sqrt(sum((x - y(:, i)).^2, 1))';
end
