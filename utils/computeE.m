function [e_mean e_all] = computeE(Us,Vs,Ws,Uref,Vref,Wref)
% Compute factor fitting error between A and A_ref
% This code only work order 3 tensor 
% === INPUTS ==============================================================
% Us,Vs,Ws           mode-1,mode-2,mode-3 matrices 
%                    note Us is I x r x numM
% Uref, Vref, Wref   reference for mode-1,mode-2,mode-3 matrices
% === OUTPUTS =============================================================
% e_mean             a matrix [e_Ui e_Vi e_Wi] in i-th row
% e_all              a vector, mean([e_Ui e_Vi e_Wi] in i-th element
%% Input check
numU = size(Us,3); % number of slice in U
numV = size(Vs,3); % number of slice in V
numW = size(Ws,3); % number of slice in W
if ( numU ~= numV) || (numU ~= numW) || ( numV ~= numW ) 
 error('U,V,W need to have same number of frontal slices');
end
%%
for i = 1 : numU
 e_Ui      = errc(Us(:,:,i),Uref); % relative error between Us_i and Uref
 e_Vi      = errc(Vs(:,:,i),Vref); % relative error between Vs_i and Vref
 e_Wi      = errc(Ws(:,:,i),Wref); % relative error between Ws_i and Wref
 e_all(i,:)= [e_Ui e_Vi e_Wi];     % a vector store all e
 e_mean(i) = mean(e_all(i,:));     % mean of e_all_i
end
end

function  err = errc(A_hat,A)
% Correction of sign and permutation ambiguity of CP model.
% Inputs: A_hat,...   : estimated factors without correction;
%         A,...       : true factors
% External functions: munkres.m  (Hungarian algorithm)
%------------------------------Normalization------------------------------%
A_hat = col_norm(A_hat);
A     = col_norm(A);
%-------------------------Permutation correction--------------------------%
% Matrix with negative correlations between the columns
P_cost=-abs(A'*A_hat);
% Permutation indexes given by the Hungarian algorithm
[perm,~]=munkres(P_cost);
% Permutation of the columns + selection
A_cor = A_hat(:,perm);
% Error computation
err   = norm(A_cor-A,'fro')/norm(A,'fro');
end

function M = col_norm(M) % normalize each column by its L2 norm 
[m,n] = size(M);
norms = sqrt(sum(M.^2));
for r = 1:n
 if norms(r)>0
   M(:,r) = M(:,r)/norms(r);
 end
end
end

