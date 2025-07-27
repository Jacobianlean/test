function plotCode(s)
% This code is used for plotting support
% 辅助绘图的函数库，主要包含对坐标轴刻度、标注、网格等内容的定制。
if strcmp(s, 'fi')
  title('$f$(iteration)','interpreter','latex','fontsize',16);
  xlabel('Iteration($k$)','interpreter','latex','fontsize',16);
    plotCode_ygrid( 4 );
elseif strcmp(s,'ft')
  title('$f$(time)','interpreter','latex','fontsize',16);
  xlabel('Time(sec)','interpreter','latex','fontsize',16);
    plotCode_ygrid( 4 );
  
elseif strcmp(s,'ei')
  title('$e$(iteration)','interpreter','latex','fontsize',16);
  xlabel('Iteration($k$)','interpreter','latex','fontsize',16);
    plotCode_ygrid( 3 );
elseif strcmp(s,'et')
  title('$e$(time)','interpreter','latex','fontsize',16);
  xlabel('Time(sec)','interpreter','latex','fontsize',16) ;
   plotCode_ygrid( 3 );
else
  error('Wrong input');
end
end% EOF

function plotCode_ygrid( num )
grid on, 
axis tight,
ax = gca; 
if num == 3
 ax.YTick = [1e-12, 1e-9, 1e-6, 1e-3, 1, 1e3, 1e6, 1e9, 1e12]; 
 ax.YTickLabel = {'$10^{-12}$','$10^{-9}$','$10^{-6}$','$10^{-3}$','$10^{0}$','$10^{3}$','$10^{6}$','$10^{9}$','$10^{12}$'};   
elseif num == 4
 ax.YTick = [1e-12, 1e-8, 1e-4, 1, 1e4, 1e8, 1e12]; 
 ax.YTickLabel = {'$10^{-12}$','$10^{-8}$','$10^{-4}$','$10^{0}$','$10^{4}$','$10^{8}$','$10^{12}$'}; 
end
ax.FontSize   = 16;
end