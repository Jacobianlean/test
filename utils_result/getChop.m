function o2 = getChop(o)
% This function take in struct "o" and perform
% 1. Extract f_min e_min (for each entry, "per experiment trials")
% 2. Chop f,t,e to the same length 
% 3. Replace o.f, o.e, o.t to the chopped version
% 4. Extract fmin_i emin_i
% IF no a subfield e in o, all process on e is not carried out
% 给定一个包含多次实验数据的结构体数组，每个结构体里包含了 f、t、e 等字段(若有 e 字段)，该函数会对这些数据进行统一截断，以确保每个实验都在相同的长度上进行比较。
% 输出一个新的结构 o2，其中包含了截断后的 f、t、e，以及对应的最小值 fmin_i、emin_i 等信息。
%% Input handling
num_trials = size(o,2); % number of struct (number of experimental trials)
%% Does subfiel e exists in o ?
if isfield(o,'e')  hasE = 1;
else               hasE = 0;
end
%% Main
 % get the length of each entry 
 for i = 1 : num_trials
     length_f(i) = numel(find(o(i).f));
     length_t(i) = numel(find(o(i).t));
     if hasE == 1
        length_e(i) = numel(find(o(i).e));
     end
 end
 % get the  min length
 length_f_min = min(length_f);
 length_t_min = min(length_t);
 length_all_min = min([length_f_min length_t_min]);
 if hasE == 1
  length_e_min = min(length_e);
  length_all_min = min([length_all_min length_e_min]);
 end
 % truncate all entry to the min length
 for i = 1 : num_trials
    f(i,:)    = o(i).f(1:length_all_min);
    %f(i,:)    = o(i).f(1:length_f_min);
    fmin_i(i) = min(f(i,:));
    t(i,:)    = o(i).t(1:length_all_min);
    if hasE == 1
      e(i,:)    = o(i).e(1:length_all_min);
      %e(i,:)    = o(i).e(1:length_e_min);
      emin_i(i) = min(e(i,:));
    end
 end
%% Output handling    
o2.f      = f;
o2.t      = t;
o2.fmin_i = fmin_i;
if hasE == 1
 o2.e      = e;
 o2.emin_i = emin_i;
end
end % EOF
%{

function o2 = getChop(o)
% 使用 padding 代替截断的新版本
num_trials = size(o, 2); % number of struct (number of experimental trials)

%% Does subfield e exists in o?
if isfield(o, 'e')  
    hasE = 1;
else               
    hasE = 0;
end

%% 获取所有试验的最大长度
length_f = zeros(1, num_trials);
length_t = zeros(1, num_trials);
if hasE
    length_e = zeros(1, num_trials);
end

for i = 1:num_trials
    length_f(i) = length(o(i).f);
    length_t(i) = length(o(i).t);
    if hasE == 1
        length_e(i) = length(o(i).e);
    end
end

% 确定最大长度
max_length_f = max(length_f);
max_length_t = max(length_t);
max_length = max(max_length_f, max_length_t);

if hasE == 1
    max_length_e = max(length_e);
    max_length = max(max_length, max_length_e);
end

%% 填充所有数组到相同长度
f = nan(num_trials, max_length); % 使用 NaN 初始化
t = nan(num_trials, max_length); % 使用 NaN 初始化
if hasE
    e = nan(num_trials, max_length); % 使用 NaN 初始化
end

fmin_i = nan(1, num_trials);
emin_i = nan(1, num_trials);

for i = 1:num_trials
    % 处理f
    actual_length_f = length(o(i).f);
    if actual_length_f > 0
        f(i, 1:actual_length_f) = o(i).f;
        % 填充剩余部分
        if actual_length_f < max_length
            f(i, actual_length_f+1:end) = o(i).f(end);
        end
        
        % 记录最小值（仅基于原始数据）
        fmin_i(i) = min(o(i).f);
    end
    
    % 处理t
    actual_length_t = length(o(i).t);
    if actual_length_t > 0
        t(i, 1:actual_length_t) = o(i).t;
        
        % 填充剩余部分 - 保持相同的时间间隔
        if actual_length_t < max_length && actual_length_t > 1
            % 计算平均时间步长
            time_steps = diff(o(i).t);
            avg_time_step = mean(time_steps);
            
            % 填充剩余时间点
            last_time = o(i).t(end);
            padding_length = max_length - actual_length_t;
            padding_times = last_time + avg_time_step * (1:padding_length);
            t(i, actual_length_t+1:end) = padding_times;
        elseif actual_length_t < max_length && actual_length_t == 1
            % 如果只有一个时间点，使用默认步长
            padding_length = max_length - actual_length_t;
            padding_times = o(i).t(1) + 0.001 * (1:padding_length);
            t(i, actual_length_t+1:end) = padding_times;
        end
    end
    
    % 处理e
    if hasE == 1
        actual_length_e = length(o(i).e);
        if actual_length_e > 0
            e(i, 1:actual_length_e) = o(i).e;
            % 填充剩余部分
            if actual_length_e < max_length
                e(i, actual_length_e+1:end) = o(i).e(end);
            end
            
            % 记录最小值（仅基于原始数据）
            emin_i(i) = min(o(i).e);
        end
    end
end

%% 输出处理    
o2.f = f;
o2.t = t;
o2.fmin_i = fmin_i;

if hasE == 1
    o2.e = e;
    o2.emin_i = emin_i;
end
end
%}