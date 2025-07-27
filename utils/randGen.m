function [U,V,W] = randGen(dims,r,sP)
% randomly generate 3 matrices with sizes according to dims and rank
% === Input =============================================================== 
% dims    = [I J K], has to be positive integers
% r       the rank parameter, has to be positive integer
% sp      = [sP1, sP2, sP3], sparsity percentage of U,V,W, [0,1)
%           (higher sP means more zero)
%% Input check
if nargin < 3  sP = []; end

if ~isempty(sP)
if min(sP) < 0 ||  max(sP) > 1 ||  numel(sP) ~= 3 
   error('sP has to be vector of values within [0,1)'); 
end
end

% if dimensions is not order 3
if numel(dims) ~= 3  error('Has to be order 3 tensor');
else                 I = dims(1); % mode 1 size
                     J = dims(2); % mode 2 size
                     K = dims(3); % mode 3 size
end

% I,J,K has to be integer
if ~(I == round(I)) ||  ~(J == round(J)) ||  ~(K == round(K)) 
   error('I,J,K has to be integer'); 
end

if r<0 || ~(r == round(r))  % rank has to positive integer
   error('rank has to be positive integer'); 
end
%% Main
U = rand(I,r);
V = rand(J,r);
W = rand(K,r);

if ~isempty(sP)
 U = sp(U,sP(1));
 V = sp(V,sP(2));
 W = sp(W,sP(3));
end
end

function X = sp(X,p)
% make X sparse by removing p-percent of elements in X to zero
[m,n]  = size(X);
mn     = m*n;
nz     = floor(mn*p); % number of zero
zid    = randperm(mn,nz)'; % nz unique integers picked randomly from [1,mn]
X(zid) = 0;
end