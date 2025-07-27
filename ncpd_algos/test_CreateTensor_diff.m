function [Zdprime,Z,U] = test_CreateTensor_diff(dims,collinearity,R,l1,l2,l)
% generate the random original tensor
% Input:
% dims          : dimensions of the orginal tensor
% collinearity  : required collinearity
% R             : required CP rank
% l1            : coefficient of homoscedastic noise
% l2            : coefficient of heteroscedastic noise
%------------------------------------------------
% Output:
% Zprime        : the tensor generated without noise
% Z             : the tensor generated with noise
% U             : the real factor matrices
rng(l)
% First generate K
K = collinearity*ones(R,R)+(1-collinearity)*eye(R);
% Get C as the Cholesky factor of K
C = chol(K);
U = cell(3,1);
%rng(par)
for n=1:3
% Cenerate a random matrix
M = randn(dims(n),R);
M=max(M,0);
% Ortho-normalize the columns of M, gives Q
[Q,~] = qr(M,0); 
U{n} = Q*C;
end
Z = ktensor(U); 
Zfull = full(Z);
% Generate two random tensors
N1 = tensor(randn(dims));
N2 = tensor(randn(dims));
nZ = norm(Zfull);
nN1 = norm(N1);
% Modify Z with the two different types of noise
Zprime = Zfull+1/sqrt(100/l1-1)*nZ/nN1*N1;
nZprime = norm(Zprime);
N2Zprime = N2.*Zprime;
nN2Zprime = norm(N2Zprime);
Zdprime = Zprime+1/sqrt(100/l2-1)*nZprime/nN2Zprime*N2Zprime;

end