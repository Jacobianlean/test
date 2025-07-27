function plot3o(varargin)
%% Input handling: Support multiple structs (cell array) OR two separate structs
if isstruct(varargin{1}) && (nargin >= 2 && isstruct(varargin{2}))
    % Old format: Two structs (o1, o2, ...)
    o_cell = {varargin{1}, varargin{2}};
    otherArgs = varargin(3:end);
elseif iscell(varargin{1})
    % New format: Cell array of structs ({o1,o2,..}, ...)
    o_cell = varargin{1};
    otherArgs = varargin(2:end);
else
    error('First input must be struct OR cell array of structs');
end

%% Parse other arguments (plotMode, axfs, algoName, topRow, legendNames)
% Set default values
plotMode = 'fiteration';
axfs = 12;
algoName = [];
topRow = 1;
legendNames = {};

% Determine number of other arguments
numOtherArgs = numel(otherArgs);

% Override defaults with provided arguments
if numOtherArgs >= 1 && ~isempty(otherArgs{1})
    plotMode = otherArgs{1};
end
if numOtherArgs >= 2 && ~isempty(otherArgs{2})
    axfs = otherArgs{2};
end
if numOtherArgs >= 3 && ~isempty(otherArgs{3})
    algoName = otherArgs{3};
end
if numOtherArgs >= 4 && ~isempty(otherArgs{4})
    topRow = otherArgs{4};
end
if numOtherArgs >= 5 && ~isempty(otherArgs{5})
    legendNames = otherArgs{5};
    if ~iscell(legendNames)
        error('legendNames must be a cell array of strings');
    end
end

numAlgos = numel(o_cell); % Number of algorithms

%% Define colors/styles for each algorithm
% Line widths for curves/mean
lw_all  = 0.1;  % Width for individual trial curves
lw_mean = 2.5;  % Width for mean curves

% Create containers for legend handles
legend_handles = gobjects(1, numAlgos); % Create empty array of graphics objects

% Precompute algorithm names for legend
if isempty(legendNames)
    % Generate default legend names
    legendNames = arrayfun(@(x) sprintf('Algorithm %d', x), 1:numAlgos, 'UniformOutput', false);
end

% Ensure we have enough legend names
if numel(legendNames) < numAlgos
    % Add default names for missing entries
    for i = numel(legendNames)+1:numAlgos
        legendNames{i} = sprintf('Algorithm %d', i);
    end
end

%% 主配色方案 - 仅改变第二个算法为紫色
% 使用预设的颜色方案
default_colors = lines(7); % 获取7种不同的标准颜色

all_colors  = cell(1, numAlgos);
mean_colors = cell(1, numAlgos);
lineStyles  = cell(1, numAlgos);

% 定义线型
line_style_options = {'-', '--', ':', '-.'};

for i = 1:numAlgos
    % 应用预设的线型（循环使用）
    style_idx = mod(i-1, numel(line_style_options)) + 1;
    lineStyles{i} = line_style_options{style_idx};
    
    % 应用预设的颜色方案
    if i <= size(default_colors, 1)
        base_color = default_colors(i, :);
    else
        base_color = lines(mod(i, size(default_colors, 1)) + 1);
    end
    
    % 对于第二个算法，替换为紫色方案
    if i == 2
        % 第二个算法 - 紫色方案（深紫色 + 浅紫色）
        mean_colors{2} = [0.5, 0.0, 0.8]; % 深紫色 - RGB [128, 0, 205]
        all_colors{2}  = [0.8, 0.7, 1.0]; % 浅紫色 - RGB [204, 179, 255]
    else
        % 其他算法 - 标准颜色方案
        mean_colors{i} = base_color;
        
        % 创建浅色版本
        all_colors{i} = base_color + 0.7*(1 - base_color);
        all_colors{i}(all_colors{i} > 1) = 1;
    end
end

%% 特殊处理：针对两种算法情况的传统配色
% 如果只有两种算法，使用原始代码的传统配色方案
if numAlgos == 2
    % 算法1：紫色系（原始配色）
    mean_colors{1} = [94,60,153]/256;    % o1_color_code_mean, 深紫色
    all_colors{1}  = [178,171,210]/256;  % o1_color_code_all_trial, 浅紫色
    
    % 算法2：紫色系（深紫色 + 浅紫色）
    mean_colors{2} = [0.5, 0.0, 0.8];    % 深紫色
    all_colors{2}  = [0.8, 0.7, 1.0];    % 浅紫色
    
    % 线型：算法1实线，算法2虚线
    lineStyles{1} = '-';
    lineStyles{2} = '--';
end

%% Plotting
hold off; % Reset hold state
switch plotMode
    case 'fiteration'  % f vs. iteration
        for i = 1:numAlgos
            o = o_cell{i};
            % Plot individual trials (thin lines, no legend entry)
            semilogy(o.f', 'color', all_colors{i}, 'linewidth', lw_all, 'HandleVisibility', 'off');
            hold on;
            % Plot mean curves (thick lines, with legend entry)
            legend_handles(i) = semilogy(o.mf_iter, 'color', mean_colors{i}, ...
                'linestyle', lineStyles{i}, 'linewidth', lw_mean, ...
                'DisplayName', legendNames{i});
        end
        axis tight; grid on;
        ylim([1e-15 inf]); % Auto-scale y-axis

    case 'ftime'  % f vs. time
        T = o_cell{1}.t; % All algos must share time vector
        for i = 1:numAlgos
            o = o_cell{i};
            semilogy(T, o.f_t', 'color', all_colors{i}, 'linewidth', lw_all, 'HandleVisibility', 'off');
            hold on;
            legend_handles(i) = semilogy(T, o.mf_t, 'color', mean_colors{i}, ...
                'linestyle', lineStyles{i}, 'linewidth', lw_mean, ...
                'DisplayName', legendNames{i});
        end
        axis tight; grid on;
        ylim([1e-15 inf]);

    case 'eiteration'  % e vs. iteration
        for i = 1:numAlgos
            o = o_cell{i};
            semilogy(o.e', 'color', all_colors{i}, 'linewidth', lw_all, 'HandleVisibility', 'off');
            hold on;
            legend_handles(i) = semilogy(o.me_iter, 'color', mean_colors{i}, ...
                'linestyle', lineStyles{i}, 'linewidth', lw_mean, ...
                'DisplayName', legendNames{i});
        end
        axis tight; grid on;
        ylim([1e-9, 1]); % Fixed y-range

    case 'etime'  % e vs. time
        T = o_cell{1}.t;
        for i = 1:numAlgos
            o = o_cell{i};
            semilogy(T, o.e_t', 'color', all_colors{i}, 'linewidth', lw_all, 'HandleVisibility', 'off');
            hold on;
            legend_handles(i) = semilogy(T, o.me_t, 'color', mean_colors{i}, ...
                'linestyle', lineStyles{i}, 'linewidth', lw_mean, ...
                'DisplayName', legendNames{i});
        end
        axis tight; grid on;
        ylim([1e-9, 1]);

    otherwise
        error('Invalid plotMode. Choose: fiteration, ftime, eiteration, etime.');
end

%% Formatting
ax = gca;
ax.YTick = 10.^(-15:3:15);
ax.YTickLabel = arrayfun(@(x) sprintf('$10^{%d}$', x), -15:3:15, 'UniformOutput', false);
ax.FontSize = 12;

%if ~isempty(algoName)
%    ylabel(algoName, 'fontsize', axfs, 'interpreter', 'latex');
%end

if topRow == 1
    switch plotMode
        case 'fiteration'
            title('$f(k)$', 'fontsize', axfs, 'interpreter', 'latex');
        case 'ftime'
            title('$f($time$)$', 'fontsize', axfs, 'interpreter', 'latex');
        case 'eiteration'
            title('$e(k) - e_{\min}$', 'fontsize', axfs, 'interpreter', 'latex');
        case 'etime'
            title('$e($time$) - e_{\min}$', 'fontsize', axfs, 'interpreter', 'latex');
    end
end

% Add legend if needed
if numAlgos > 1
    legend(legend_handles, 'FontSize', axfs-2, 'Location', 'best', 'Interpreter', 'none');
    drawnow;
end
end