function [f,t,f_r]= objfunTucker(mode,normY2,W,U,V,Y,Gvec) 
%                   objfun(mode,normY2,W,P,Q)        %mode2
% Compute objective function and relative data fitting error
% (this function has 2 mode, see === input === )
%
% this function compute the objective function value
%  f = 0.5* || Y - U * V * W ||_F^2;
% where U * V * W is tensor product and Y is an order-3 tensor
%
% and relative data fitting error as 
%  f_r = 2 * f / || Y ||_F^2;
%
% The direct computation is 
%      f = norm( Y_mode{1} - U*kr(V,W)','fro' )^2/2;
% or   f = norm( Y_mode{3} - W*kr(U,V)','fro' )^2/2;
% it is expensive and slow, so do not compute in this way 
%
% The way this code compute as follows 
% f = 0.5* norm( Y - U * V * W )_F^2;
%   = 0.5* norm(Y)_F^2 + 0.5* norm( U * V * W )_F^2 - < Y, U * V * W>
%   = normY2/2         + trace( W*Q*W')             - trace(W'* P)
% where Q = (U'*U).*(V'*V); % a tensor short cut
%       P = Y_mode{3}*kr(U,V); % an costly MTTKRP
% Q, P are alreadt computed in some NCPD algo
% if Q,P are not provided, this code compute them (costly : 1 MTTKRP)
%
% However, the term trace( W*Q*W')  can be further improved to
%    sum(sum( (W'*W) .* Q ) );  
% === Input ===============================================================
% usemode    : 1 means at iteration 1, 2 means after iteration 1
%  for mode 1
%   the code read as "objfun(mode,normY2,W,U,V,Ymode3)"
%    U,V,W   : mode-1,2,3 matrix
%    Ymode3  : 
%    normY2  : the norm of Y squared                   
%  for mode 2
%   the code read as "objfun(mode,normY2,W,P,Q)"
%    normY2  : the norm of Y squared
%    W       : mode-3 matrix
%    P       : Y_mode{3}*kr(U,V)
%    Q       : (U'*U).*(V'*V)
% === Output ==============================================================
% f   : 0.5 * || Y - U*V*W ||_F^2 
% t   : computational time in second
% f_r : || Y - U*V*W ||_F^2 / || Y ||^2;
%% Input handling
if mode == 1
 if (nargin < 6)  error('Not enough input'); end
end
if mode == 2
 if (nargin > 5)  error('Too many input'); end   
end
%% main
if mode ==1 
     t_start = tic;
     Q  = (U'*U).*(V'*V).*(W'*W);
     P  = kr( kr( (Y{1})'*U, (Y{2})'*V ), (Y{3})'*W );
     f  = normY2/2 - Gvec'*sum(P,2) + sum(sum(Q))/2;
     f_r = 2*f/normY2;
     t = toc(t_start);
elseif mode == 2 % ****************************************************
     t_start = tic;
     f   = normY2/2 - W(:)'*U(:) + sum(sum( (W'*W) .* V ))/2;
 %   f   = normY2/2 - trace(W'*U) + sum(sum( (W'*W) .* V ))/2;  % old way, should avoid the trace
     f_r = 2*f/normY2;
     t = toc(t_start);
end
end