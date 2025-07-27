function [U,V,W,out] = HalpernBCD(Y,r,opt)
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
%  .stepmethod   : 'common','anchor','fromapp','fromBB'(default)
%  .modify       : 'y1','y2','n'(default)
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
[U_old,V_old,W_old,timemax,itermax,inneritermax,stepmethod,modify,projchoose,epsilon,isStore,Ustore,Vstore,Wstore]=ini(opt,r);
U0=max(U_old,0);
V0=max(V_old,0);
W0=max(W_old,0);
U_oldproj=U0;
V_oldproj=V0;
W_oldproj=W0;
% u,v,w是没经过投影的，proj是投影之后的
%% Algorithm initialization
 % get norm_squared and mode-1,2,3 unfolding of Y, and Tucker info 
 [normY2,Y_mode,isTucker,G_mode,Gvec] = dim_norm_mode(Y);
 % Allocate space for cost value, compute initial cost
 f  = zeros(1,itermax); 
 %compute initial f
 if isTucker == 0      f0 = objfun(1,normY2,W0,U0,V0,Y_mode{3}); 
 elseif isTucker == 1  f0 = objfunTucker(1,normY2,W0,U0,V0,Y,Gvec); 
 end
 f_hat = f; % allocate space for the restart criterion (*~*)
 % *** This algo uses restarts 
 
% algorithm solver
if isfield(opt,'algoName') 
    algoName = opt.algoName;
    if strcmp(algoName,'ADMM') 
        UtU=U_oldproj'*U_oldproj; VtV=V_oldproj'*V_oldproj; WtW=W_oldproj'*W_oldproj; Utild=U_oldproj; Vtild=V_oldproj; Wtild=W_oldproj;
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
     Qu = (V_oldproj'*V_oldproj).*(W_oldproj'*W_oldproj);
     if isTucker == 0
        Pu = Y_mode{1}*kr(V_oldproj,W_oldproj); % 1 full size MTTKRP, costly 
     elseif isTucker == 1
        Pu = Y{1}*(G_mode{1}*kr(Y{2}'*V_oldproj,Y{3}'*W_oldproj)); % 1 smaller MTTKRP
     end
     % Perform the block update
     if strcmp(algoName,'ADMM')
       [U_new,Utild,UtU] = nnlsadmm(Pu',U_oldproj,Utild,Qu,UtU,inneritermax,inner_delta); 
     else
        U_new = BCD_blkUpdt( U_oldproj, Qu, Pu, inneritermax, inner_delta, algoName );
     end
     % 这里加halpern迭代步长
     [beta,U_newproj]=halpernstep(i,U0,U_old,U_oldproj,U_new,stepmethod,modify,projchoose);
     %用Halpern做外推时用的是投影之后的上一步刚做完BCD之后的U_newproj!!!
     U = (1-beta)*U_newproj + beta*U0; % Extrapolation
     U_newproj = max(0,U);  %if projMode(1) == 1   end % Projection 
    %% *** On V ***
     % Compute parameters for update
     Qv = (U_newproj'*U_newproj).*(W_oldproj'*W_oldproj); 
     if isTucker == 0
        Pv = Y_mode{2}*kr(U_newproj,W_oldproj); % 1 full size MTTKRP, costly
     elseif isTucker == 1
        Pv = Y{2}*(G_mode{2}*kr(Y{1}'*U_newproj,Y{3}'*W_oldproj)); % 1 smaller MTTKRP
     end
      % Perform the block update
     if strcmp(algoName,'ADMM')
       [V_new,Vtild,VtV] = nnlsadmm(Pv',V_oldproj,Vtild,Qv,VtV,inneritermax,inner_delta);
     else
        V_new = BCD_blkUpdt( V_oldproj, Qv, Pv, inneritermax, inner_delta, algoName );
     end
     [beta,V_newproj]=halpernstep(i,V0,V_old,V_oldproj,V_new,stepmethod,modify,projchoose);
     V = (1-beta)*V_newproj + beta*V0; % Extrapolation
     V_newproj = max(0,V);  %if projMode(1) == 1   end % Projection 
    %% *** On W ***
     % Compute parameters for update
     Qw = (U_newproj'*U_newproj).*(V_newproj'*V_newproj); 
     if isTucker == 0
       Pw = Y_mode{3}*kr(U_newproj,V_newproj); % 1 full size MTTKRP, costly 
     elseif isTucker == 1
       Pw = Y{3}*(G_mode{3}*kr(Y{1}'*U_newproj,Y{2}'*V_newproj)); % 1 smaller MTTKRP
     end
     % Perform the block update
     if strcmp(algoName,'ADMM')
       [W_new,Wtild,WtW] = nnlsadmm(Pw',W_oldproj,Wtild,Qw,WtW,inneritermax,inner_delta);
     else
        W_new = BCD_blkUpdt( W_oldproj, Qw, Pw, inneritermax, inner_delta, algoName ); 
     end
     [beta,W_newproj]=halpernstep(i,W0,W_old,W_oldproj,W_new,stepmethod,modify,projchoose);
     W = (1-beta)*W_newproj + beta*W0; % Extrapolation
     W_newproj = max(0,W);  %if projMode(1) == 1   end % Projection 
    %% Error computations
    if isTucker == 0
     f_hat(i)    = objfun(2,normY2,W_newproj,Pw,Qw); % f_hat, time included
     [f(i), t_f] = objfun(1,normY2,W_newproj,U_newproj,V_newproj,Y_mode{3}); % f, time to be reduced
    elseif isTucker == 1
     f_hat(i)    = objfunTucker(2,normY2,W_newproj,Pw,Qw); % f_hat, time included
     [f(i), t_f] = objfunTucker(1,normY2,W_newproj,U_newproj,V_newproj,Y,Gvec); % f, time to be reduced 
    end
    time_f = time_f  + t_f;
    a1=norm(U_newproj-U_oldproj,'fro')/norm(U_newproj,'fro');
    a2=norm(V_newproj-V_oldproj,'fro')/norm(V_newproj,'fro');
    a3=norm(W_newproj-W_oldproj,'fro')/norm(W_newproj,'fro');
    
    %% 增加停机准则判断（这里如果不想比较收敛速率的话可以不要）
    if i>1&&max([abs(f(end)-f(end-1))/f(end),a1,a2,a3])<epsilon&&t_now>0.08 %可以重新设定为一个参数
        break;
    end
    
    % 这里的extrapolation系数是计算得到的，无法做restart?
    U_old = U_new;     V_old = V_new;    W_old = W_new;
    U_oldproj = U_newproj;     V_oldproj = V_newproj;    W_oldproj = W_newproj;
    
    t(i)  = toc(time_start) - time_f; % time, including time to compute err
    t_now = t(i); 
    %% Store, break check and iteration ++
    if isStore == 1 Ustore(:,:,i)=U_oldproj; Vstore(:,:,i)=V_oldproj; Wstore(:,:,i)=W_oldproj;end %Store intermediate U V W
    % 停机准则修正
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
                                %if ~exist('rs') out.rs = rs;end %restart stamp
% Intermediate U,V,W
if isStore == 1
  Ustore(:,:,l+1:end) = []; Vstore(:,:,l+1:end) = []; Wstore(:,:,l+1:end) = []; 
  out.Ustore = Ustore;      out.Vstore = Vstore;      out.Wstore = Wstore;
end
fprintf('HalpernBCD done! \n'); 
end%EOF