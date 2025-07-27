function A = BCD_blkUpdt( A, Q, P, itermax)
% Perform a block update on block A for BCD and herBCD
% === INPATS ==============================================================
% A        : the block variable 
% Q,P      : coefficients used for updating A
% itermax  : max number of iterarion for this block update
% delta    : stopping criteria for this block update
% algoName : the name of algo used to update A
% === OUTPUTS =============================================================
% A
A  = nnlsHALSupdt_jec(Q,P',A',itermax)';   
end

%%
function V = nnlsHALSupdt_jec(UtU,UtM,V,maxiter)
    % Computes an approximate sol of 
    %           min_{V >= 0} ||M-UV||_F^2 
    % with an exact block-coordinate descent scheme. 
    % === Input ===============================================================
    % M  : m-by-n matrix 
    % U  : m-by-r matrix
    % V  : r-by-n initialization matrix 
    %      default: one non-zero entry per column corresponding to the 
    %      clostest column of U of the corresponding column of M 
    % maxiter: upper bound on the number of iterations (default=500).
    %
    % Remark. M, U and V are not required to be nonnegative. 
    % === Output ==============================================================
    % V  : an r-by-n nonnegative matrix \approx argmin_{V >= 0} ||M-UV||_F^2
    % === Reference ===========================================================
    % N. Gillis and F. Glineur, Accelerated Multiplicative Updates and 
    % Hierarchical ALS Algorithms for Nonnegative Matrix Factorization, 
    % Neural Computation 24 (4): 1085-1105, 2012.
    if nargin <= 3  maxiter = 500; end % default 500 iterations
    
    r = size(UtU,1); 
    
    if nargin <= 2 || isempty(V) 
      V = pinv(UtU)*UtM; % Least Squares
      V = max(V,0); 
      alpha = sum(sum( (UtM).*V ))./sum(sum( (UtU).*(V*V'))); 
      V = alpha*V; 
    end
    
    % Stopping condition depending on evolution of the iterate V : 
    % Stop if ||V^{k}-V^{k+1}||_F <= delta * ||V^{0}-V^{1}||_F 
    % where V^{k} is the kth iterate. 
    delta = 0.1; % inner loop stopping criterion for A-HALS
    eps0  = 0; 
    i     = 1; % iteration counter
    eps   = 1; 
    while eps >= delta*eps0 && i <= maxiter %Maximum number of iterations
    nodelta = 0; 
      for k = 1 : r
        deltaV = max((UtM(k,:)-UtU(k,:)*V)/UtU(k,k),-V(k,:));
        V(k,:) = V(k,:) + deltaV;
        nodelta = nodelta + deltaV*deltaV';%used to compute norm(V0-V,'fro')^2;
        if V(k,:) == 0, V(k,:) = 1e-16*max(V(:)); end % safety procedure
      end
      if (i==1)   eps0 = nodelta; end
      eps = nodelta; 
    i = i + 1; 
    end
end%EOF
