function o2 = getResult(o, fmin_i, emin_i, timemax, mMode)
% This function takes in a o struct, fmin_i, emin_i, timemax, mMode
% 将截断后或更新后的数据进行基准化(即减去 f 最小值 fmin_i、e 最小值 emin_i)，并根据时间或迭代进行插值，从而得到一致采样点下的 f、e。
% mMode   : mean = 0, default median = 1
% It extract  f, e, fmin, emin, t, and output a new o struct with sub-fields
%   f          f(iteration) - fmin
%   e          e(iteration) - emin
%   mf_iter    mean of f(iteration)
%   me_iter    mean of e(iteration)
%   ft         f(time) - fmin, time synchroznied by linear iterpolation
%   et         e(time) - emin, time synchronized by linear iterpolation
%   T          time stamps
%   mf_t       mean of f(time)
%   me_t       mean of e(time)
% If the subfiel e does not exist in struct o then no operation on e.
%% Input hanlding
if nargin < 5  mMode = 1; end
%% Does subfiel e exists in o ?
if isfield(o,'e')  hasE = 1;
else               hasE = 0;
end
%% Get curve subtracted from fmin emin
% on f
% Make sure fmin_i and emin_i is column vector
if size(fmin_i,2) > size(fmin_i,1) fmin_i = fmin_i'; end
% subtract all f in o from fmin_i for each trial
f = bsxfun(@minus,o.f,fmin_i);

% on e
if hasE == 1
% Make sure fmin_i and emin_i is column vector
if size(emin_i,2) > size(emin_i,1) emin_i = emin_i'; end
% subtract all e in o from emin_i for each trial
e = bsxfun(@minus,o.e,emin_i);
end
%% Get mean curve (on iteration), median is prefered
if mMode == 1 % median (default)
 mf_iter = median(f);
 if hasE == 1
   me_iter = median(e);
 end
elseif mMode == 0 % mean
  mf_iter = mean(f);
 if hasE == 1
   me_iter = mean(e);
 end
end
%% Get Liner Interpolation on time
% on f
[ft,T] = multiLinInterp(f,o.t,timemax);
% on e
 if hasE == 1
   et = multiLinInterp(e,o.t,timemax);
 end
%% Get mean curve (on time), median is prefered
if mMode == 1 % median
 mf_t = median(ft);
 if hasE == 1
   me_t = median(et);
 end
elseif mMode == 0 % mean
 mf_t = mean(ft);
 if hasE == 1
   me_t = mean(et);
 end
end
%% Ouput handling
o2.f       = f;
o2.mf_iter = mf_iter;
o2.t       = T;
o2.f_t     = ft;
o2.mf_t    = mf_t;
if hasE == 1
    o2.e       = e;
    o2.me_iter = me_iter;
    o2.e_t     = et;
    o2.me_t    = me_t;
end
end %EOF

%% call liner iterpolation
%{
function [F,T] = multiLinInterp(f,t,timemax)
%文章的处理方式
N = min(size(f));
if N ~= min(size(t)) || max(size(f)) ~= max(size(t))
 error('Inputs need to have same sizes'); 
end

for i = 1 : N
 [F(i,:),T] = linInterp(f(i,:),t(i,:),timemax);
end
end%EOF

% Lin interp
function [F,T] = linInterp(f,t,Tmax)
% Change (f,t) to (F,T), where f(t) has different uneven time index t
%                        while F(T) has fix interval between elements
% Tmax is the max time
% the interval is 0 : stepsize : Tmax, stepsize determined by Tmax

% turn f,t into row vectors
if size(f,1)>size(f,2)  f = f'; end
if size(t,1)>size(t,2)  t = t'; end

f =[f(1) f];
t =[0    t];

if Tmax <= 2
  stepsize = 0.001;   %调整这个使得画图能够显示出来时间的变化曲线
else
  stepsize = 0.5;
end

numTimepioint = floor(Tmax/stepsize);

for k = 1 : numTimepioint
 tk = k*stepsize; % We want to compute value of error at time tk
 % Find in which interval of t tk belongs 
 ilow = max( find(t < tk) ); 
 ihig = min( find(t >= tk) ); 
 % Do linear extrapolation: tk in [t(ilow),t(ihig)] 
 if t(ilow) == t(ihig)  error('vector t should be strictly increasing');end
 % convex combination
 F(k) = ( (t(ihig)-tk)*f(ilow) + (tk-t(ilow))*f(ihig)) / (t(ihig) - t(ilow));  
 T(k) = tk;
end
end
%}

function [F, T] = linInterp(f, t, Tmax, fixed_time_points)
% 确保行向量 - 但需要处理多列情况
f = f(:)';
t = t(:)';

% 添加初始点(0, f(1))
f = [f(1), f];
t = [0, t];

% 确定插值时间点
if nargin < 4
    stepsize = 0.001;
    T = 0:stepsize:Tmax;
else
    T = fixed_time_points;
end

% 提前找到最后一个有效时间点
last_valid_time = min(max(t), Tmax);
last_valid_idx = find(t <= last_valid_time, 1, 'last');

% 初始化结果向量
F = nan(size(T)); % 使用 nan 初始化可以避免维度问题

% 确保所有值都是标量
for k = 1 : length(T)
    tk = T(k);
    
    % 处理超出原始时间范围的情况
    if tk > t(last_valid_idx)
        F(k) = f(last_valid_idx);
        continue;
    end
    
    % 查找包含时间点的区间
    ilow = max(1, sum(t <= tk)); % 确保至少为1
    ihig = min(length(t), find(t >= tk, 1)); % 确保不超出范围
    
    % 边界情况处理
    if ilow == ihig
        % 如果恰好处于一个点上
        F(k) = f(ilow);
    else
        % 确保索引有效
        if ilow >= 1 && ilow <= length(f) && ihig >= 1 && ihig <= length(f)
            % 计算权重并确保结果是标量
            weight = (tk - t(ilow)) / (t(ihig) - t(ilow));
            
            % 标量计算确保维度匹配
            F(k) = (1 - weight) * f(ilow) + weight * f(ihig);
        else
            % 如果索引超出范围，使用最近的有效值
            F(k) = f(min(max(1, ilow), length(f)));
        end
    end
end
end

function [F, T] = multiLinInterp(f, t, timemax)
% 修改后：处理多维输入，确保每行独立处理
N = size(f, 1); % 试验次数
stepsize = 0.1;
T = 0:stepsize:timemax;
F = nan(N, length(T)); % 使用 nan 初始化的矩阵

for i = 1 : N
    % 确保处理单个试验的数据
    f_trial = f(i, :);
    t_trial = t(i, :);
    
    % 去除 NaN 值
    valid_f = ~isnan(f_trial);
    valid_t = ~isnan(t_trial);
    valid_indices = valid_f & valid_t;
    
    f_trial = f_trial(valid_indices);
    t_trial = t_trial(valid_indices);
    
    % 确保时间序列单调递增
    if any(diff(t_trial) <= 0)
        % 如果时间序列不单调，排序并去重
        [t_trial, sort_idx] = unique(t_trial, 'sorted');
        f_trial = f_trial(sort_idx);
    end
    
    % 如果试验数据有效才进行插值
    if ~isempty(f_trial) && ~isempty(t_trial)
        [F(i, :), ~] = linInterp(f_trial, t_trial, timemax, T);
    else
        % 如果数据无效，使用NaN填充
        F(i, :) = nan(1, length(T));
    end
end
end

