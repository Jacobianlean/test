function [Zdprime,Z,U] = test_CreateTensor_diff(dims,collinearity,R,l1,l2,l)
%从随机张量构造具有特定的双重线性系数张量的过程,并返回真实的U(cell)，方便后面e_true的计算
rng(l)
% First generate K
K = collinearity*ones(R,R)+(1-collinearity)*eye(R);
% Get C as the Cholesky factor of K
C = chol(K);
U = cell(3,1);%生成张量的因子矩阵
%rng(par)
for n=1:3
% Cenerate a random matrix
M = randn(dims(n),R);%为每个维度生成一个随机矩阵
M=max(M,0);
% Ortho-normalize the columns of M, gives Q
[Q,~] = qr(M,0); 
U{n} = Q*C;%保证生成的列向量具有指定的共线性系数
end
Z = ktensor(U); %用CP分解构成的矩阵直接生成其对应的张量，默认系数为lambda均为1
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
%这里Z是标准的CP分解原张量，Zdprime是加入噪声后的结果
end