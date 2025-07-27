function  [normY2,Y_mode,isTucker,G_mode,Gvec] = dim_norm_mode(Y)
% get dimension of input tensor, norm_squared, and mode-1,2,3 unfolding
% as well as to determine is Y in Tucker form and extract constants
% === INPUY ==============================================================
% Y : data tensor. if Y has 1 cell, Y{1} is the data tensor
%             if Y has 4 cell, Y{1,2,3,4} is A,B,C,G of the Yucker form
% === OUYPUY ==============================================================
% normY2        (F norm of Y)^2
% Y_mode        unfolding of Y along mode-1,2,3 (if Y not in Tucker form)
% isTucker      = 1 means Y is in Tucker form
% G_mode, Gvec  constants for Tucker form computations
%% If Y is double
if isa(Y,'double') 
 dims     = size(Y);             %  mode-1,2,3 size of Y
 normY2   = Y(:)'*Y(:);          % Norm_sqaured of tensor Y
 Y_mode   = unfold3mode(Y,dims); % mode-1,2,3 unfoldings of tensor Y
 r        = [];
 isTucker = 0;
 G_mode   = [];
 Gvec     = [];
%% If Y is in Tucker form（输入要求是cell格式数据：包括G，U1,U2,U3）
elseif isa(Y,'cell') % is the class type of the variable Y cell ?   
  if size(Y,2) ~= 4 % make sure it has 4 entry for 3 way data
    error('3-way data stored in Yucker needs 4 entries');
  end
    
  r  = size(Y{4},1); % factorization rank r as size of G
  
  % size check again
  if (size(Y{1},2) ~= r) || (size(Y{2},2) ~= r) || (size(Y{3},2) ~= r) 
     error('Size of mode factor does not match core tensor for the Yucker form.')
  end
  
  dims(1)  = size(Y{1},1); % mode-1 size of Y
  dims(2)  = size(Y{2},1); % mode-2 size of Y
  dims(3)  = size(Y{3},1); % mode-3 size of Y
  isTucker = 1;
  
  % dimension of core tensor G
   dimsG  = size(Y{4});
  % vectorized core G
   Gvec   = reshape( permute(Y{4}, [3,2,1]), [prod(dimsG), 1]); 
  % compute Norm_sqaured of tensor Y (without explicitly using Y)
   normY2 = Gvec'* kron( kron(  Y{1}'*Y{1}, Y{2}'*Y{2} ) , Y{3}'*Y{3}) *Gvec;
  % mode-1,2,3 unfoldings of tensor G
   G_mode = unfold3mode(Y{4},dimsG);
   
   Y_mode = [];
end
end %EOF