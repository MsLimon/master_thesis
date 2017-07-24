clc
clear all

 
% dimension of the misalignment space
misalignment_dim = 3;

% Define probability distribution of misalignment space
pd = cell(1,misalignment_dim);
% distribution corresponding to the misalignment on x
pd{1} = makedist('normal','mu',0,'sigma',1.5);
% truncate x distribution (alignment structures only allow the laser to move backwards)
%pd{1} = truncate(pd{1},0,5);
% distribution corresponding to the misalignment on y
pd{2} = makedist('normal','mu',0,'sigma',3);
% truncate y distribution (we have symmetry about the x axis)
%pd{2} = truncate(pd{2},0,9);
% distribution corresponding to the misalignment on alpha
pd{3} = makedist('normal','mu',0,'sigma',1);
% truncate alpha distribution (don't allow values greater than alpha)
%pd{3} = truncate(pd{3},-3,3);
    
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
        
	[samples,me,se] = lhseval(pd,n);
    E(i,:) = [n, me, se];
    i = i+1;
    end
end

%select line width of the plot lines
linewidth = 2;
font_size = 24;
%plot mean deviation
figure
subplot(2,1,1);
plot(E(:,1),E(:,2),'o','Color',[0.4941 0.1843 0.5569]);
%,'LineWidth',linewidth,'MarkerSize', 10
%axis([0,50,-1,1])
xlabel('N'); % x-axis label
ylabel([char(949) '_\mu']); % y-axis label
subplot(2,1,2);
plot(E(:,1),E(:,5),'o','Color',[0.8706 0.4902 0]);
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
%axis([0,50,-1,1])
xlabel('N'); % x-axis label
ylabel([char(949) '_\epsilon']); % y-axis label
%set(gca,'fontsize',font_size,'LineWidth',linewidth);


% %plot mean deviation
% hold on;
% plot(E(:,1),E(:,2),'o');
% plot(E(:,1),E(:,4),'o');
% hold off;
% legend('mean error - LHS','std error - LHS');
% xlabel('number of samples'); % x-axis label
% ylabel('relative error on x distribution'); % y-axis label

% Save plot to vector image .eps
fig = gcf;

% adapt file separator to the operating system
f = filesep;

fig.PaperPositionMode = 'auto';
print('-dpng','-r300', ['.' f 'graphics' f 'error_comparison' f 'error_plotMCnormalX_50iterations'])
print('-depsc','-tiff','-r300', ['.' f 'graphics' f 'error_comparison' f 'error_plotMCnormalX_50iterations'])
close(fig);

% save the data
     fnam='error_results_test_lhs.txt'; % <- your data file
%      hdr={'number of samples','mean error x dist','mean error y dist','std error x dist','std error y dist'};
%      % the engine
%      txt=sprintf('%s\t',hdr{:});
%      txt(end)='';
%      dlmwrite(fnam,txt,'');
%      dlmwrite(fnam,E,'-append');
     dlmwrite(fnam,E);
     %dlmwrite(fnam,E,'-append','delimiter','\t');
