function [fmin_i,emin_i,fmin_all,emin_all] = getMin(o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16)
% This function takes in multiple struct o, perform
% 1. Extract f and e from o
% 2. Compute fmin_i, emin_i 
% 3. Compute fmin_all, emin_all
% 从多个结构体(可视为多个算法)中获取 fmin_i、emin_i 的全局最小值，得到的是一个20X1的向量（这里在无噪声的情况下就取0向量，所以这个程序都不需要跑）
%% Does subfiel e exists in o ?
if isfield(o1,'e')  hasE = 1;
else                hasE = 0;
end
%% On f
 % Initialize
 fmin_i = inf;   % f_min for each trial i across different algorithms
 fmin_all = inf; % f_min across all trial all algorithms

 % make sure fmin_i is row vector
    if nargin >= 2 fmin_i = min([o1.fmin_i; o2.fmin_i]);  end
    if nargin >= 3 fmin_i = min([fmin_i; o3.fmin_i]); end
    if nargin >= 4 fmin_i = min([fmin_i; o4.fmin_i]); end
    if nargin >= 5 fmin_i = min([fmin_i; o5.fmin_i]); end
    if nargin >= 6 fmin_i = min([fmin_i; o6.fmin_i]); end
    if nargin >= 7 fmin_i = min([fmin_i; o7.fmin_i]); end
    if nargin >=8  fmin_i = min([fmin_i; o8.fmin_i]); end
    if nargin >=9  fmin_i = min([fmin_i; o9.fmin_i]); end
    if nargin >=10 fmin_i = min([fmin_i; o10.fmin_i]); end
    if nargin >=11 fmin_i = min([fmin_i; o11.fmin_i]); end
    if nargin >=12 fmin_i = min([fmin_i; o12.fmin_i]); end
    if nargin >=13 fmin_i = min([fmin_i; o13.fmin_i]); end
    if nargin >=14 fmin_i = min([fmin_i; o14.fmin_i]); end
    if nargin >=15 fmin_i = min([fmin_i; o15.fmin_i]); end
    if nargin >=16 fmin_i = min([fmin_i; o16.fmin_i]); end
    if nargin >=17 error('at most 16 o in getMin');end
fmin_all = min(fmin_i);
%% On e
if hasE == 1
  emin_i = inf;   % e_min for each trial i across different algorithms
  emin_all = inf; % e_min across all trial all algorithms
  
 % make sure emin_i is row vector
    if nargin >= 2 emin_i = min([o1.emin_i; o2.emin_i]);  end
    if nargin >= 3 emin_i = min([emin_i; o3.emin_i]); end
    if nargin >= 4 emin_i = min([emin_i; o4.emin_i]); end
    if nargin >= 5 emin_i = min([emin_i; o5.emin_i]); end
    if nargin >= 6 emin_i = min([emin_i; o6.emin_i]); end
    if nargin >=7 emin_i  = min([emin_i; o7.emin_i]); end
    if nargin >=8 emin_i  = min([emin_i; o8.emin_i]); end
    if nargin >=9 emin_i  = min([emin_i; o9.emin_i]); end
    if nargin >=10 emin_i = min([emin_i; o10.emin_i]); end
    if nargin >=11 emin_i = min([emin_i; o11.emin_i]); end
    if nargin >=12 emin_i = min([emin_i; o12.emin_i]); end
    if nargin >=13 emin_i = min([emin_i; o13.emin_i]); end
    if nargin >=14 emin_i = min([emin_i; o14.emin_i]); end
    if nargin >=15 emin_i = min([emin_i; o15.emin_i]); end
    if nargin >=16 emin_i = min([emin_i; o16.emin_i]); end
    if nargin >=17 error('at most 16 o in getMin'); end
emin_all = min(emin_i);
else
  emin_all = [];
  emin_i = [];
end
end%EOF