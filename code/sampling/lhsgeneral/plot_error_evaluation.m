%plot error evaluation results
method = 2;

switch method
    case 1
    E = dlmread('error_results_test_rs.txt');
    case 2
    E = dlmread('error_results_test_lhs.txt');
end
% select figure size
f_width = 1200;
f_height= 1300;
%select line width of the plot lines
linewidth = 2;
font_size = 24;
%plot mean deviation
% create a plot figure
fig1 = figure;

fig1.Position = [0, 0, f_width, f_height];

subplot(2,1,1);
plot(E(:,1),E(:,2),'o','Color',[0.4941 0.1843 0.5569],'LineWidth',linewidth,'MarkerSize', 14);
%,'LineWidth',linewidth,'MarkerSize', 10
%axis([0,50,-1,1])
xlabel('N'); % x-axis label
% ylabel([char(949) '_\mu']); % y-axis label
ylabel('\mu / \mu m'); % y-axis label
ylim([0 0.5]);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
subplot(2,1,2);
plot(E(:,1),E(:,4),'o','Color',[0.8706 0.4902 0],'LineWidth',linewidth,'MarkerSize', 14);
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
%axis([0,50,-1,1])
xlabel('N'); % x-axis label
ylabel([char(949) '_\sigma']); % y-axis label
ylim([0 0.3]);
set(gca,'fontsize',font_size,'LineWidth',linewidth);



% Save plot to vector image .eps
fig = gcf;

% adapt file separator to the operating system
f = filesep;

fig.PaperPositionMode = 'auto';
switch method
    case 1
    picname = 'error_plotRandomX_50iterations'
    case 2
    picname = 'error_plotLatinX_50iterations'
end
print('-dpng','-r300', ['.' f 'graphics' f 'error_comparison' f picname])
print('-depsc','-tiff','-r300', ['.' f 'graphics' f 'error_comparison' f picname])
close(fig);