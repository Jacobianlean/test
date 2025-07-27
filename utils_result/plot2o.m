function plot2o(o1,o2,plotMode,axfs,algoName,topRow)
% Compre o1 and o2 by plotting all curves and mean on iteration / time
% 对比 o1 和 o2 两个结构体的结果(比如不同算法或实验)，绘制多种形式的对数坐标曲线(例如 f vs. iteration、f vs. time、e vs. iteration、e vs. time)。
% o1 : struct with 
%         f 
%         e
%        mf_iter
%        me_iter
%       f_t
%       e_t
%         t
%      mf_t
%      me_t
% o2 : struct same as o1 for different algorithm
%     important note : o1.t and o2.t has to be the same
% plotMode : 'fiteration' (default) or 'ftime', 'eiteration', 'etime'
% axfs     : axis font size, default 15
% algoName : title for the plot
% topRow   : is it the top row? default 1 on, show title
%% Input handling
if nargin < 6 topRow = 1; end
if nargin < 5 topRow = 1; algoName = []; end
if nargin < 4 topRow = 1; algoName = []; axfs = 12; end
if nargin < 3 topRow = 1; algoName = []; axfs = 12; plotMode = 'fiteration'; end
%% Plotting specifications

% o1 color code for plot
o1_cc_m = [94,60,153]/256;    % o1_color_code_mean,      dark purple
Lw1     = 2.5;
o1_cc_a = [178,171,210]/256;  % o1_color_code_all_trial, light purple
lw1     = 0.1;

% o2 color code for plot
o2_cc_m = [230,97,1]/256;     % o2_color_code_mean,      orange
Lw2     = 2.5;
o2_cc_a = [253,184,99]/256;   % o2_color_code_all,       light orange
lw2     = 1.35;
o2_msyl = ':';                % o2 plot line style

mks = 0.1; % markersize
switch plotMode
%% x-axis is iteration, y-axis is f
case 'fiteration'
semilogy(o1.f'     ,'color',o1_cc_a,'linewidth',lw1),hold on, % plot all curves
semilogy(o2.f'     ,o2_msyl,'color',o2_cc_a,'linewidth',lw2),hold on, % plot all curves
semilogy(o1.mf_iter,'color',o1_cc_m,'linewidth',Lw1),hold on % plot mean curves
semilogy(o2.mf_iter,o2_msyl,'color',o2_cc_m,'linewidth',Lw2),hold on % plot mean curves
%{
num_point    = size(o1.mf_iter,2);
o1marker_loc = max(1,[floor(0.3*num_point) floor(0.6*num_point) floor(0.9*num_point)]);
num_point    = size(o2.mf_iter,2);
o2marker_loc = max(1,[floor(0.08*num_point) floor(0.2*num_point) floor(0.5*num_point) floor(0.7*num_point)]); 
semilogy(o1marker_loc, o1.mf_iter(o1marker_loc),'s','color',o1_cc_m,'markersize',mks,'MarkerFaceColor',o1_cc_m),hold on % mean marker
semilogy(o2marker_loc, o2.mf_iter(o2marker_loc),'d','color',o2_cc_m,'markersize',mks,'MarkerFaceColor',o2_cc_m),hold on % mean marker
%}
axis tight,grid on
ylim([-inf inf]) % <----------------------------
%% x-axis is time, y-axis is f
case 'ftime'  
T = o1.t;
semilogy(T,o1.f_t','color',o1_cc_a,'linewidth',lw1),hold on,  % plot all curves
semilogy(T,o2.f_t',o2_msyl,'color',o2_cc_a,'linewidth',lw2),hold on,  % plot all curves
semilogy(T,o1.mf_t,'color',o1_cc_m,'linewidth',Lw1),hold on  % plot mean curves
semilogy(T,o2.mf_t,o2_msyl,'color',o2_cc_m,'linewidth',Lw2),hold on  % plot mean curves
%{
num_point    = size(T,2);
o1marker_loc = max(1,[floor(0.3*num_point) floor(0.6*num_point) floor(0.9*num_point)]);
num_point    = size(T,2);
o2marker_loc = max(1,[floor(0.08*num_point) floor(0.2*num_point) floor(0.5*num_point) floor(0.7*num_point)]);
semilogy(T(o1marker_loc), o1.mf_t(o1marker_loc),'s','color',o1_cc_m,'markersize',mks,'MarkerFaceColor',o1_cc_m),hold on % mean marker
semilogy(T(o2marker_loc), o2.mf_t(o2marker_loc),'d','color',o2_cc_m,'markersize',mks,'MarkerFaceColor',o2_cc_m),hold on % mean marker
%}
axis tight,grid on
ylim([-inf inf]) % <----------------------------
%% % x-axis is iteration, y-axis is e
case 'eiteration'   
semilogy(o1.e','color',o1_cc_a,'linewidth',lw1),hold on, % plot all curves
semilogy(o2.e',o2_msyl,'color',o2_cc_a,'linewidth',lw2),hold on, % plot all curves
semilogy(o1.me_iter,'color',o1_cc_m,'linewidth',Lw1),hold on % plot mean curves
semilogy(o2.me_iter,o2_msyl,'color',o2_cc_m,'linewidth',Lw2),hold on % plot mean curves
%{
num_point = size(o1.me_iter,2);
o1marker_loc = max(1,[floor(0.3*num_point) floor(0.6*num_point) floor(0.9*num_point)]);
num_point = size(o2.me_iter,2);
o2marker_loc = max(1,[floor(0.08*num_point) floor(0.2*num_point) floor(0.5*num_point) floor(0.7*num_point)]);
semilogy(o1marker_loc, o1.me_iter(o1marker_loc),'s','color',o1_cc_m,'markersize',mks,'MarkerFaceColor',o1_cc_m),hold on % mean marker
semilogy(o2marker_loc, o2.me_iter(o2marker_loc),'d','color',o2_cc_m,'markersize',mks,'MarkerFaceColor',o2_cc_m),hold on % mean marker
%}
axis tight,grid on,
ylim([1e-9 1])  % <----------------------------
%% x-axis is time, y-axis is e
case 'etime'
T = o1.t;
semilogy(T,o1.e_t','color',o1_cc_a,'linewidth',lw1),hold on,  % plot all curves
semilogy(T,o2.e_t',o2_msyl,'color',o2_cc_a,'linewidth',lw2),hold on,  % plot all curves
semilogy(T,o1.me_t,'color',o1_cc_m,'linewidth',Lw1),hold on  % plot mean curves
semilogy(T,o2.me_t,o2_msyl,'color',o2_cc_m,'linewidth',Lw2),hold on  % plot mean curves
%{
num_point    = size(T,2);
o1marker_loc = max(1,[floor(0.3*num_point) floor(0.6*num_point) floor(0.9*num_point)]);
num_point    = size(T,2);
o2marker_loc = max(1,[floor(0.08*num_point) floor(0.2*num_point) floor(0.5*num_point) floor(0.7*num_point)]);
semilogy(T(o1marker_loc), o1.me_t(o1marker_loc),'s','color',o1_cc_m,'markersize',mks,'MarkerFaceColor',o1_cc_m),hold on % mean markers
semilogy(T(o2marker_loc), o2.me_t(o2marker_loc),'d','color',o2_cc_m,'markersize',mks,'MarkerFaceColor',o2_cc_m),hold on % mean markers
%}
axis tight,grid on,
ylim([1e-9 1])  % <----------------------------
%%
otherwise error('plotMode should be ''fiteration'', ''ftime'', ''eiteration'' or ''etime''.');
end % end switch
%% y labels
if ~isempty(algoName)
 ylabel(algoName,'fontsize',axfs,'interpreter','latex');
end
%% Grid
ax = gca;
ax.YTick      = [1e-15,1e-12,1e-9,1e-6,1e-3,1,1e3,1e6,1e9,1e12,1e15];
ax.YTickLabel = {'$10^{-15}$','$10^{-12}$','$10^{-9}$','$10^{-6}$','$10^{-3}$','$10^{0}$','$10^{3}$','$10^{6}$','$10^{9}$','$10^{12}$','$10^{15}$'};
ax,FontSize   = 12;
%% Title
if topRow == 1
switch plotMode
 case 'fiteration'
  title('$f(k)-f_{min}$','fontsize',axfs,'interpreter','latex');
 case 'ftime'
  title('$f($time$)-f_{min}$','fontsize',axfs,'interpreter','latex');
 case 'eiteration'
  title('$e(k)-e_{min}$','fontsize',axfs,'interpreter','latex');
 case 'etime'
  title('$e($time$)-e_{min}$','fontsize',axfs,'interpreter','latex');
 otherwise
end
end
end %EOF