%load data to be plotted
E = dlmread('error_results_test.txt');

%plot mean deviation
figure
subplot(2,1,1);
plot(E(:,1),E(:,2),'o');
%axis([0,50,-1,1])
xlabel('Number of samples'); % x-axis label
ylabel('Relative error'); % y-axis label
title('Relative error of the mean of the samples (x distribution)')
%set(gca,'FontSize',14);
subplot(2,1,2);
plot(E(:,1),E(:,3),'o');
%axis([0,50,-1,1])
xlabel('Number of samples'); % x-axis label
ylabel('Relative error'); % y-axis label
title('Relative error of the mean of the samples (y distribution)')
%set(gca,'FontSize',14);

% Save plot to vector image .eps
fig = gcf;

fig.PaperPositionMode = 'auto';
print('-dpng','-r300', 'error_plot')
close(fig);