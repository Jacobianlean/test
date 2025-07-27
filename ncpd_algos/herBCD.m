function [U,V,W,out] = herBCD(Y,r,opt)
% Computes order-3 NCPD via BCD with various solver with HER
% === Inputs ==============================================================
% Y, r           : order-3 data tensor and factorization rank
%                  if Y has 1 cell, then Y{1} is the data tensor
%                  if Y has 4 cell, Y is stored in Tucker form
%                  Y{1,2,3} are mode-factors A,B,C, Y{4} is core tensor G
% opt (algorithm parameters)
%  .timemax      : max run time(sec), default 60
%  .itermax      : max num iterations of outer loop, default 100
%  .inneritermax : max num iteration of inner loop, default 50
%  .U .V .W      : initial mode-1,2,3 NN factors U,V,W <-- must present
%  .isStore      : =1 store intermediate U,V,W of iterations
%                  deafult =0 (off)
%  .algoName     : name of the solver used to solve the sub-minimization
%                  "AHALS" (default), "ADMM", "Nesterov", "PGD", "MU"
% *** HER prarmeters ***
%  .beta         : starting beta, default 0.5
%  .betamax      : starting betamax, default 1
%  .gamma        : gamma, default 1.05
%  .gamma_b      : gamma_b, default 1.01
%  .eta          : eta, default 1.5
%  .projMode     : projection mode on pairting variable, default [1,1,1]
% === Output ==============================================================
% U,V,W          : estimated mode-1,2,3 NN factors
%                  reconstruct data by tensorForm(dims,U,V,W)
% out (algorithm output)
%  .f            : cost in each iteration
%  .t            : timestamp of each iteration
%  .f0           : initial cost value
%  .t0           : time used for initialization
%  .Ustore       : intermediate U of all iteration (if isStore = 1)
%                  same for Vstore, Wstore
%  .beta,betamax : beta, betamax in each iteration
% Note. Computation of factor fitting error is done outside this function
% === Credits ==================== A.Ang @ UMONS,BE, angms.science ========               
% 8/7/2019 First version                  A.Ang
% 25/9/2019 Last update                   A.Ang 
%% Time
time_start = tic; % Mark the time flag of the start of the whole code
time_f     = 0;   % Hold the total amount of time on computing f (note the time on computing f_hat is included)
%% Input handling and initlaizations
if (nargin < 3) opt = []; end
% Input opt handling for function initlaizations
[U,V,W,timemax,itermax,inneritermax,~,~,~,epsilon,isStore,Ustore,Vstore,Wstore]=ini(opt,r);
% Initilization of HER parameters
[beta,betamax,gamma,gamma_b,eta,projMode] = ini_her(opt);
%% Algorithm initialization
 % get norm_squared and mode-1,2,3 unfolding of Y, and Tucker info 
 [normY2,Y_mode,isTucker,G_mode,Gvec] = dim_norm_mode(Y);
 % Allocate space for cost value, compute initial cost
 f  = zeros(1,itermax); 
 %compute initial f
 if isTucker == 0      f0 = objfun(1,normY2,W,U,V,Y_mode{3}); 
 elseif isTucker == 1  f0 = objfunTucker(1,normY2,W,U,V,Y,Gvec); 
 end
 f_hat = f; % allocate space for the restart criterion (*~*)
 % *** This algo uses restarts 
 
% algorithm solver
if isfield(opt,'algoName') 
    algoName = opt.algoName;
    if strcmp(algoName,'ADMM') 
        UtU=U'*U; VtV=V'*V; WtW=W'*W; Utild=U; Vtild=V; Wtild=W;
    end
else
    algoName = 'AHALS'; % default
end
 
t0 = toc(time_start) - time_f; % all the initialization time
if (t0>=timemax) error('Initialization run longer then max runtime, set opt.timemax bigger'); end
t_now = t0;
%% Main Loop
i = 1; % iteration counter for the main loop
inner_delta = 1e-2; % inner loop early stopping critetion
Uhat = U; Vhat = V; What = W;  % HER pairing variables
while i <= itermax && t_now < timemax
    %{
    % Notations for understanding : -- Normal version --
    %    f = 0.5|| Y - U * V * W ||_F^2
    %      = 0.5||Y||_F^2 + 0.5|| U * V * W ||_F^2 - < Y, U * V * W>
    % Then according to subject of U,V,W, we have
    % f(U) = 0.5||Y||_F^2 + 0.5|| U * (V*W) ||_F^2 - < Y_1 kr(V,W), U>
    %      = 0.5||Y||_F^2 + 0.5<QuU, U> - <Pu,U>
    % f(V) = 0.5||Y||_F^2 + 0.5|| V * (U*W) ||_F^2 - < Y_2 kr(U,W), V>
    %      = 0.5||Y||_F^2 + 0.5<QvV, W> - <Pv,V>
    % f(W) = 0.5||Y||_F^2 + 0.5|| W * (U*V) ||_F^2 - < Y_3 kr(U,v), W>
    %      = 0.5||Y||_F^2 + 0.5<QwW, W> - <Pw,W>
    % -- Tucker version with Y = (A*B*C)G --
    %    f = 0.5|| (A*B*C)G - U * V * W ||_F^2;
    %      = 0.5||Y||_F^2 + 0.5|| U * V * W ||_F^2 - < G, A'U * B'V * C'W>
    % Then according to subject of U,V,W, we have
    % f(U) = 0.5||Y||_F^2 + 0.5|| U * (V*W) ||_F^2 - < AG_1 kr(B'V,C'W), U>
    %      = 0.5||Y||_F^2 + 0.5<QuU, U> - <Pu,A'U>
    % f(V) = 0.5||Y||_F^2 + 0.5|| V * (U*W) ||_F^2 - < BG_2 kr(A'U,C'W), V>
    %      = 0.5||Y||_F^2 + 0.5<QvV, W> - <Pv,B'V>
    % f(W) = 0.5||Y||_F^2 + 0.5|| W * (U*V) ||_F^2 - < CG_3 kr(A'U,B'V), W>
    %      = 0.5||Y||_F^2 + 0.5<QwW, W> - <Pw,C'W>
    %}
    %% *** On U ***
     % Compute parameters for update
     Qu = (Vhat'*Vhat).*(What'*What);
     if isTucker == 0
        Pu = Y_mode{1}*kr(Vhat,What); % 1 full size MTTKRP, costly 
     elseif isTucker == 1
        Pu = Y{1}*(G_mode{1}*kr(Y{2}'*Vhat,Y{3}'*What)); % 1 smaller MTTKRP
     end
     U_old = U;  %都是上一步迭代完成的结果
     % Perform the block update
     if strcmp(algoName,'ADMM')
       [U,Utild,UtU] = nnlsadmm(Pu',U,Utild,Qu,UtU,inneritermax,inner_delta); 
     else
        U = BCD_blkUpdt( U, Qu, Pu, inneritermax, inner_delta, algoName ); 
        %U=PALS(U,Qu,Pu,0.01); %lambda=0.01
     end
     Uhat = U + beta*(U-U_old); % Extrapolation  
    if projMode(1) == 1  Uhat = max(0,Uhat); end % Projection 
    %% *** On V ***
     % Compute parameters for update
     Qv = (Uhat'*Uhat).*(What'*What); 
     if isTucker == 0
        Pv = Y_mode{2}*kr(Uhat,What); % 1 full size MTTKRP, costly 
     elseif isTucker == 1
        Pv = Y{2}*(G_mode{2}*kr(Y{1}'*Uhat,Y{3}'*What)); % 1 smaller MTTKRP
     end
     V_old = V;
     % Perform the block update
     if strcmp(algoName,'ADMM')
       [V,Vtild,VtV] = nnlsadmm(Pv',V,Vtild,Qv,VtV,inneritermax,inner_delta);
     else
        V = BCD_blkUpdt( V, Qv, Pv, inneritermax, inner_delta, algoName ); 
        %V=PALS(V,Qv,Pv,0.01);
     end
     Vhat = V + beta*(V - V_old); % exttrapolation
    if projMode(2) == 1  Vhat = max(0,Vhat);  end % Projection 
    %% *** On W ***
     % Compute parameters for update
     Qw = (Uhat'*Uhat).*(Vhat'*Vhat); 
     if isTucker == 0
       Pw = Y_mode{3}*kr(Uhat,Vhat); % 1 full size MTTKRP, costly 
     elseif isTucker == 1
       Pw = Y{3}*(G_mode{3}*kr(Y{1}'*Uhat,Y{2}'*Vhat)); % 1 smaller MTTKRP
     end
     W_old = W;
     % Perform the block update
     if strcmp(algoName,'ADMM')
       [W,Wtild,WtW] = nnlsadmm(Pw',W,Wtild,Qw,WtW,inneritermax,inner_delta);
     else
        W = BCD_blkUpdt( W, Qw, Pw, inneritermax, inner_delta, algoName ); 
        %W=PALS(W,Qw,Pw,0.01);
     end
     What = W + beta*(W - W_old); % exttrapolation
    if projMode(3) == 1  What = max(0,What);  end % Projection 
    %% Error computations and restart ***
    if isTucker == 0
     f_hat(i)    = objfun(2,normY2,W,Pw,Qw); % f_hat, time included   %从两个不同模态做计算error
     [f(i), t_f] = objfun(1,normY2,W,U,V,Y_mode{3}); % f, time to be reduced   
    elseif isTucker == 1
     f_hat(i)    = objfunTucker(2,normY2,W,Pw,Qw); % f_hat, time included
     [f(i), t_f] = objfunTucker(1,normY2,W,U,V,Y,Gvec); % f, time to be reduced 
    end
    time_f = time_f  + t_f;
    a1=norm(Uhat-U_old)/norm(Uhat);
    a2=norm(Vhat-V_old)/norm(Vhat);
    a3=norm(What-W_old)/norm(What);
    
    %% 增加停机准则判断（这里如果不想比较收敛速率的话可以不要）
    if i>1&&max([abs(f(end)-f(end-1))/f(end),a1,a2,a3])<epsilon&&t_now>0.08 %可以重新设定为一个参数
        break;
    end
    
    %%
    if i > 1
     if f_hat(i)> f_hat(i-1) % restart 
        Uhat = U;  Vhat = V;  What = W; 
        betamax = beta;   % update betamax
        betaStore(i) = beta; % store beta
        beta = beta/eta;       % drop beta
     else % keep previous iterate in memory
        U = Uhat;     V = Vhat;    W = What;
        betaStore(i) = beta; % store beta
        beta = min(betamax, beta*gamma); % grow beta 
        betamax = min(1, betamax*gamma_b);       % grow betamax
     end
     betaMaxStore(i) = betamax; % store beta
    end
    t(i)  = toc(time_start) - time_f; % time, including time to compute err
    t_now = t(i); 
    %% Store, break check and iteration ++
    if isStore == 1 Ustore(:,:,i)=U; Vstore(:,:,i)=V; Wstore(:,:,i)=W;end %Store intermediate U V W
    if isnan(f(i))
        warning('f=NaN');
        break; 
    end %Break if hit NaN
    i = i+1; % Iteration ++
end%endWhile
%% output processing
% min length of f and t
l = min([numel(find(f)) numel(find(f_hat)) numel(t)]);
out.f = f(1:l);
out.t = t(1:l);
out.f_hat = f_hat(1:l);
out.f0 = f0;
out.t0 = t0;
out.beta = betaStore; % Stored Beta
out.betamax = betaMaxStore; % Stored Beta Max
                                %if ~exist('rs') out.rs = rs;end %restart stamp
% Intermediate U,V,W
if isStore == 1
  Ustore(:,:,l+1:end) = []; Vstore(:,:,l+1:end) = []; Wstore(:,:,l+1:end) = []; 
  out.Ustore = Ustore;      out.Vstore = Vstore;      out.Wstore = Wstore;
end
fprintf('herBCD done! \n'); 
end%EOF