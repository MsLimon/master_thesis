clc
clear all

 
pd = cell(1,2);
% distribution corresponding to the misalignment on x
pd{1} = makedist('normal','mu',0,'sigma',0.2);
% truncate x distribution (alignment structures only allow the laser to move backwards)
pd{1} = truncate(pd{1},-1,0);
% distribution corresponding to the misalignment on y
pd{2} = makedist('normal','mu',0,'sigma',0.5);
% truncate y distribution (we have symmetry about the x axis)
pd{2} = truncate(pd{2},-2,0);
l=length(pd);
% select number of samples
% n = 125;
% set number of iteration per sample number
iterations = 50;
% set number of values of the number of samples to be evaluated
num_values = 10;
num_samples = linspace(100,1000,num_values);
% preallocate error matrix (num samples, M_error, S_error)
E = zeros(iterations*num_values,1+l*2);
%E = zeros(num_values,1+l*2);
% start iteration counter
i = 1;
for n = num_samples
    for k = 1:iterations
        
	[samples,me,se] = montecarloeval(pd,n);
    E(i,:) = [n, me, se];
    i = i+1;
    end
end

%plot errors
figure
subplot(2,1,1);
plot(E(:,1),E(:,2),'o','Color',[0.4941 0.1843 0.5569]);
%axis([0,50,-1,1])
xlabel('Number of samples'); % x-axis label
ylabel('Relative error'); % y-axis label
title('Relative error of the mean of the samples')
subplot(2,1,2);
plot(E(:,1),E(:,4),'o','Color',[0.8706 0.4902 0]);
%axis([0,50,-1,1])
xlabel('Number of samples'); % x-axis label
ylabel('Relative error'); % y-axis label
title('Relative error of the standad deviation of the samples')

% Save plot to vector image .eps
fig = gcf;

fig.PaperPositionMode = 'auto';
print('-dpng','-r300', 'error_plot_MonteCarloNormalX')
print('-depsc','-tiff','-r300', 'error_plot_MonteCarloNormalX')
close(fig);

% save the data
     fnam='error_results_test.txt'; % <- your data file
%      hdr={'number of samples','mean error x dist','mean error y dist','std error x dist','std error y dist'};
%      % the engine
%      txt=sprintf('%s\t',hdr{:});
%      txt(end)='';
%      dlmwrite(fnam,txt,'');
%      dlmwrite(fnam,E,'-append');
%      %dlmwrite(fnam,E,'-append','delimiter','\t');
dlmwrite(fnam,E);