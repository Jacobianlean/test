function plot_tau_color(tautimes, algorithm_names)
%%%%分别画关于时间和迭代次数的\tau plot并观察结果
% 输入参数:
% tautime : m x n 矩阵，m种算法在n个问题上的运行时间
% algorithm_names : 字符串元胞数组，长度为m，算法名称
[m, n] = size(tautimes);
% ========== 步骤1: 计算每个问题的基准时间（最短时间） ==========
min_time_per_problem = min(tautimes, [], 1); % 每列最小值
% ========== 步骤2: 计算相对性能比τ ==========
tau_ratios = tautimes ./ min_time_per_problem; % 每个算法在每个问题上的τ值
% ========== 步骤3: 为每个算法生成τ累积分布曲线 ==========
figure('Position', [100, 100, 400, 300]); % 设置画布大小
hold on;
% 定义线条样式和颜色
line_styles = {'-', '--', ':', '-.'};
%line_widths=[0.5,0.8,1.2,1.5,2,2.5];

% ==== 关键修改：增强颜色差异 ==== 
% 创建高度可区分的颜色方案
if m <= 8
    % 使用预设的高对比度色板（最多支持8种颜色）
    distinct_colors = [
        0.47 0.67 0.19;   % 绿
        0.85 0.33 0.10;   % 深橙
        0.93 0.69 0.13;   % 金黄
        0.49 0.18 0.56;   % 紫
        0.00 0.45 0.74;   % 深蓝
        0.77 0.05 0.33;   % 玫红
        0.30 0.75 0.93;   % 浅蓝
        0.64 0.08 0.18;   % 深红
    ];
    colors = distinct_colors(1:m, :);
else
    % 超过8种算法，使用HSV空间均匀分布的颜色
    hues = linspace(0, 1, m);  % 在色环上均匀分布
    hues = hues(randperm(m));   % 随机打乱顺序增加区分度
    saturation = 0.85;          % 高饱和度保持鲜艳
    value = 0.90;               % 高亮度避免过暗
    colors = hsv2rgb([hues(:), saturation*ones(m,1), value*ones(m,1)]);
end
% ============================

max_tau = 0; % 记录最大τ值用于坐标轴范围
for i = 1:m
    % 获取当前算法的τ值并排序
    tau_current = sort(tau_ratios(i, :));
    % 生成累积概率 (0到1之间)
    prob = (1:n) / n;
    % 绘制阶梯图（τ图标准画法）
    tau_extended = [tau_current, 10];
    prob_extended = [prob, 1];
    stairs([0, tau_extended], [0, prob_extended], ...
    'LineWidth', 2.5, ...  % 增加线宽
    'Color', colors(i,:), ...
    'LineStyle', line_styles{mod(i-1,4)+1});
    % 更新最大τ值
    max_tau = max(max_tau, tau_current(end));
end
% ========== 图形美化 ==========
grid on;
xlabel('Performance Ratio $\tau$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Fraction of Problems Solved', 'FontSize', 14);
title('Performance Profiles (τ-Plot)', 'FontSize', 16);
% 设置坐标轴范围
%xlim([1, 5]);
xlim([1,10]);
ylim([0, 1]);

% 修改为自适应分列
if m > 8
    % 计算最佳列数（不超过3列）
    num_columns = min(3, ceil(m/6));
    
    % 创建两列图例（水平排列）
    leg = legend(algorithm_names, ...
                'Location', 'southeast', ...
                'FontSize', 10, ...
                'Interpreter', 'none', ...
                'NumColumns', num_columns); % 关键参数
    
    % 调整图例位置（避免重叠）
    leg_pos = get(leg, 'Position');
    set(leg, 'Position', [0.82, 0.5 - leg_pos(4)/2, leg_pos(3), leg_pos(4)]);
else
    legend(algorithm_names, ...
           'Location', 'southeast', ...
           'FontSize', 10, ...
           'Interpreter', 'none');
end

% 添加垂直网格线增强τ值阅读
%xline([1, 2, 5, 10, 15, 20], '--', 'Color', [0.8 0.8 0.8], 'Alpha', 0.5); 
% 设置背景色提高对比度
set(gca, 'Color', [0.96 0.96 0.96]);
hold off;

% 保存高分辨率图像（可选）
% print('tau_performance_profile.png', '-dpng', '-r300');
end