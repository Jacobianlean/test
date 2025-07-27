function plot_tau_color(tautimes, algorithm_names)
% This function is used to plot the step/time τ-plot of algorithms.
% Input:
% tautime : m x n matrix, where m is the number of algorithms, and n is the number of problem instances
% algorithm_names : cell array containing algorithm names

[m, n] = size(tautimes);

% ========== Step 1: Calculate baseline time for each problem (minimum time) ==========
min_time_per_problem = min(tautimes, [], 1); % Minimum value for each column

% ========== Step 2: Calculate relative performance ratio τ ==========
tau_ratios = tautimes ./ min_time_per_problem; % τ value for each algorithm on each problem

% ========== Step 3: Generate τ cumulative distribution curve for each algorithm ==========
figure('Position', [100, 100, 400, 300]); % Set canvas size
hold on;

% Define line styles and colors
line_styles = {'-', '--', ':', '-.'};

% ==== Key modification: Enhance color differentiation ==== 
% Create highly distinguishable color scheme
if m <= 8
    % Use predefined high-contrast palette (supports up to 8 colors)
    distinct_colors = [
        0.47 0.67 0.19;   % Green
        0.85 0.33 0.10;   % Dark orange
        0.93 0.69 0.13;   % Golden yellow
        0.49 0.18 0.56;   % Purple
        0.00 0.45 0.74;   % Dark blue
        0.77 0.05 0.33;   % Rose red
        0.30 0.75 0.93;   % Light blue
        0.64 0.08 0.18;   % Dark red
    ];
    colors = distinct_colors(1:m, :);
else
    % For more than 8 algorithms, use colors uniformly distributed in HSV space
    hues = linspace(0, 1, m);  % Uniform distribution on color wheel
    hues = hues(randperm(m));   % Random permutation to enhance distinction
    saturation = 0.85;         % High saturation maintains vibrancy
    value = 0.90;              % High brightness avoids darkness
    colors = hsv2rgb([hues(:), saturation*ones(m,1), value*ones(m,1)]);
end
% ============================

max_tau = 0; % Record maximum τ value for axis range

for i = 1:m
    % Get and sort τ values for current algorithm
    tau_current = sort(tau_ratios(i, :));
    
    % Generate cumulative probability (between 0 and 1)
    prob = (1:n) / n;
    
    % Plot step plot (standard τ plot method)
    tau_extended = [tau_current, 10];
    prob_extended = [prob, 1];
    
    stairs([0, tau_extended], [0, prob_extended], ...
        'LineWidth', 2.5, ...  % Increase line width
        'Color', colors(i,:), ...
        'LineStyle', line_styles{mod(i-1,4)+1});
    
    % Update maximum τ value
    max_tau = max(max_tau, tau_current(end));
end

% ========== Graph beautification ==========
grid on;
xlabel('Performance Ratio $\tau$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Fraction of Problems Solved', 'FontSize', 14);
title('Performance Profiles (τ-Plot)', 'FontSize', 16);

% Set axis limits
xlim([1, 10]);
ylim([0, 1]);

% Create adaptive multi-column legend
if m > 8
    % Calculate optimal number of columns (max 3 columns)
    num_columns = min(3, ceil(m/6));
    
    % Create multi-column legend
    leg = legend(algorithm_names, ...
                'Location', 'southeast', ...
                'FontSize', 10, ...
                'Interpreter', 'none', ...
                'NumColumns', num_columns); % Key parameter
    
    % Adjust legend position (avoid overlap)
    leg_pos = get(leg, 'Position');
    set(leg, 'Position', [0.82, 0.5 - leg_pos(4)/2, leg_pos(3), leg_pos(4)]);
else
    legend(algorithm_names, ...
           'Location', 'southeast', ...
           'FontSize', 10, ...
           'Interpreter', 'none');
end

% Set background color to improve contrast
set(gca, 'Color', [0.96 0.96 0.96]);
hold off;

% Save high-resolution image (optional)
% print('tau_performance_profile.png', '-dpng', '-r300');
end