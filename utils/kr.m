function X = kr(U,varargin) 
% Khatri-Rao product of two matrices A and B
if ~iscell(U), U = [U varargin]; end

K = size(U{1},2);
if any(cellfun('size',U,2)-K) error('kr:ColumnMismatch','Input matrices must have same num. of col');
end

J = size(U{end},1);
X = reshape(U{end},[J 1 K]);
for n = length(U)-1:-1:1
    I = size(U{n},1);
    A = reshape(U{n},[1 I K]);
    X = reshape(bsxfun(@times,A,X),[I*J 1 K]);
    J = I*J;
end
X = reshape(X,[size(X,1) K]);
end 