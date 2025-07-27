function [T,Utrue,Vtrue,Wtrue,Ttrue] = genData(dims,r,sigma,sP,condition)
% === INPUTS ==============================================================
% dims        [I,J,K]        size of tensor
% r                          factorization rank
% sigma                      noie level [0 to inf)
% sP          [sP1 sP2 sP3]  sparsity percentage, default 0
%                            higher means more zero, lower means less zero
%                            0 : all entries of the matrices are nonzero
%                            1 : all entries of the matrices are zero
% condition   defaul 0       1,2,3 : perform special oepration on matrix
% === OUTPUT ==============================================================        
% T           (noisy) observed tensor, always non-negative
% Utrue       ground truth mode-1 matrix
% Vtrue       ground truth mode-2 matrix
% Wtrue       ground truth mode-3 matrix
% Ttrue       Ttrue = (Utrue * Vtrue * Wtrue)Gtrue
%% Input hanlding
if nargin<5 condition = 0; end
if nargin<4 sP =[]; condition = 0; end
%% Main
% Generate ground truth factors under sparsity sP
[Utrue,Vtrue,Wtrue] = randGen(dims,r,sP); 

% More difficult with poor conditionning
if condition == 1       Utrue(:,1) = 0.99*Utrue(:,2) + 0.01*Utrue(:,1); 
elseif condition == 2   Utrue(:,1) = 0.99*Utrue(:,2) + 0.01*Utrue(:,1); 
                        Vtrue(:,1) = 0.99*Vtrue(:,2) + 0.01*Vtrue(:,1); 
elseif condition == 3   Utrue(:,1) = 0.99*Utrue(:,2) + 0.01*Utrue(:,1); 
                        Vtrue(:,1) = 0.99*Vtrue(:,2) + 0.01*Vtrue(:,1); 
                        Wtrue(:,1) = 0.99*Wtrue(:,2) + 0.01*Wtrue(:,1); 
end

% Create clean data tensor from Utrue Vtrue Wtrue
 Ttrue = tensorForm(dims,Utrue,Vtrue,Wtrue);
% Add noise
T    = addNoise(Ttrue, sigma);
end % EOF

function Y = addNoise(X, sigma)
Y = max(0,  X + sigma * randn(size(X)) );
end