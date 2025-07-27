function plot3o_allModes_real(varargin)
%% Input handling
if isstruct(varargin{1}) && (nargin >= 2 && isstruct(varargin{2}))
    o_cell = {varargin{1}, varargin{2}};
    otherArgs = varargin(3:end);
elseif iscell(varargin{1})
    o_cell = varargin{1};
    otherArgs = varargin(2:end);
else
    error('First input must be struct OR cell array of structs');
end

%% Parse other arguments
axfs = 14;  % 字体大小
legendNames = {};

numOtherArgs = numel(otherArgs);

if numOtherArgs >= 1 && ~isempty(otherArgs{1})
    axfs = otherArgs{1};
end
if numOtherArgs >= 2 && ~isempty(otherArgs{2})
    % 忽略algoName参数
end
if numOtherArgs >= 3 && ~isempty(otherArgs{3})
    legendNames = otherArgs{3};
    if ~iscell(legendNames)
        error('legendNames must be a cell array of strings');
    end
end

numAlgos = numel(o_cell);

%% Define colors/styles
lw_all  = 0.5;  % 所有曲线的线条宽度
lw_mean = 3.0;  % 平均曲线的线条宽度

if isempty(legendNames)
    % 使用默认名称
    legendNames = {'Algorithm 1', 'Algorithm 2'};
    if numAlgos > 2
        for i = 3:numAlgos
            legendNames{i} = sprintf('Algorithm %d', i);
        end
    end
end

if numel(legendNames) < numAlgos
    for i = numel(legendNames)+1:numAlgos
        legendNames{i} = sprintf('Algorithm %d', i);
    end
end

%% Color and style setup
all_colors  = cell(1, numAlgos);
mean_colors = cell(1, numAlgos);
lineStyles  = cell(1, numAlgos);

% 根据图片中的颜色
for i = 1:min(numAlgos, 2)
    if i == 1
        % 紫色
        mean_colors{1} = [0.5, 0.0, 0.8];    % 主紫色
        all_colors{1}  = [0.8, 0.7, 1.0];    % 浅紫色
        lineStyles{1} = '-';
    else
        % 橙色
        mean_colors{2} = [0.92, 0.47, 0.20]; % 橙色
        all_colors{2}  = [1.0, 0.8, 0.6];    % 浅橙色
        lineStyles{2} = '-';
    end
end

% 如果有更多算法使用默认颜色
if numAlgos > 2
    default_colors = lines(7);
    for i = 3:numAlgos
        style_idx = mod(i-1, 4) + 1;
        base_color = default_colors(i-2, :);
        mean_colors{i} = base_color;
        all_colors{i} = base_color + 0.7*(1 - base_color);
        all_colors{i}(all_colors{i} > 1) = 1;
        line_style_options = {'-', '--', ':', '-.'};
        lineStyles{i} = line_style_options{style_idx};
    end
end

%% 创建画布和布局
figure('Position', [100, 100, 800, 400]);
set(gcf, 'Color', 'w'); % 白色背景

% 创建4个坐标轴 - 缩小列间距
gap = 0.02; % 列间距控制参数（非常小的值）
left_main = 0.10; % 左列起始位置
right_main = left_main + 0.38 + gap; % 右列起始位置（尽可能靠近左列）

ax1 = axes('Position', [left_main,  0.15, 0.38, 0.75]); % 左上 - f vs iteration
ax2 = axes('Position', [right_main, 0.15, 0.38, 0.75]); % 右上 - f vs time

%% 绘制函数值图形 (第一行)
% f vs iteration
for algo_idx = 1:numAlgos
    o = o_cell{algo_idx};
    plot(ax1, o.f', 'color', all_colors{algo_idx}, 'linewidth', lw_all, 'HandleVisibility', 'off');
    hold(ax1, 'on');
    plot(ax1, o.mf_iter, 'color', mean_colors{algo_idx}, 'linestyle', lineStyles{algo_idx},...
         'linewidth', lw_mean, 'DisplayName', legendNames{algo_idx});
end
set(ax1, 'YScale', 'log');
grid(ax1, 'on');
ylim(ax1, [1e3, 1e15]); 
xlim(ax1, 'tight');
set(ax1, 'YTick', 10.^(3:3:15)); % 设置Y刻度
% 使用LaTeX格式的刻度标签
set(ax1, 'YTickLabel', arrayfun(@(x) sprintf('$10^{%d}$', x), 3:3:15, 'UniformOutput', false));
xlabel(ax1, 'Iteration', 'fontsize', axfs); 
title(ax1, '$f(k)-f_{\min}$', 'fontsize', axfs, 'interpreter', 'latex');

% f vs time
for algo_idx = 1:numAlgos
    o = o_cell{algo_idx};
    T = o_cell{1}.t; % 假设所有算法的时间向量相同
    plot(ax2, T, o.f_t', 'color', all_colors{algo_idx}, 'linewidth', lw_all, 'HandleVisibility', 'off');
    hold(ax2, 'on');
    plot(ax2, T, o.mf_t, 'color', mean_colors{algo_idx}, 'linestyle', lineStyles{algo_idx},...
         'linewidth', lw_mean, 'DisplayName', legendNames{algo_idx});
end
set(ax2, 'YScale', 'log');
grid(ax2, 'on');
ylim(ax2, [1e3, 1e15]); 
xlim(ax2, 'tight');
% 保持Y轴刻度但隐藏刻度标签
set(ax2, 'YTick', 10.^(3:3:15)); 
set(ax2, 'YTickLabel', []);
xlabel(ax2, 'Time (s)', 'fontsize', axfs); 
title(ax2, '$f($time$)-f_{\min}$', 'fontsize', axfs, 'interpreter', 'latex');

% 链接第一行的Y轴确保缩放一致
linkaxes([ax1, ax2], 'y');


%% 添加图例
if numAlgos > 0
    % 创建图例
    leg = legend(ax2, legendNames(1:max(numAlgos, 2)), ...
                'FontSize', axfs-2, ...
                'Location', 'southwest', ...
                'Interpreter', 'latex');
    
    % 微调图例位置
    leg_pos = leg.Position;
    leg.Position = [leg_pos(1) + 0.05, leg_pos(2), leg_pos(3), leg_pos(4)];
end

%% 设置统一的坐标轴风格
for ax = [ax1, ax2]
    ax.FontSize = axfs;
    ax.TickLabelInterpreter = 'latex';
    ax.LineWidth = 1.2; % 较细的轴线
    ax.XColor = [0.2 0.2 0.2]; % 更暗的轴线颜色
    ax.YColor = [0.2 0.2 0.2];
end
end