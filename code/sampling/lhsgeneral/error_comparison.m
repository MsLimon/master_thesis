clc
clear all

%color dictionary
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
color_names = {'yellow','green','orange','purple'};
rgb_values = {[1  0.8431 0],[0.1647 0.3843 0.2745],[0.8706 0.4902 0],[0.4941 0.1843 0.5569]};
setcolor = containers.Map(color_names,rgb_values);
% to get more colors use the Matlab function: c = uisetcolor([0.6 0.8 1])

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
    %pd{2} = truncate(pd{2},0,12);
    % distribution corresponding to the misalignment on alpha
    pd{3} = makedist('normal','mu',0,'sigma',1);
    % truncate alpha distribution (don't allow values greater than alpha)
    %pd{3} = truncate(pd{3},-3,3);

l=length(pd);
% select number of samples
% n = 125;
% set number of iteration per sample number
iterations = 50;
% set number of values
num_values = 10;
% start iteration counter
i = 1;
num_samples = linspace(100,1000,num_values);
% preallocate error matrix (num samples, M_error, S_error)
%E = zeros(iterations_per_sample*10,1+l*2);
E_latinHypercube = zeros(num_values,1+l*2);
E_monteCarlo = zeros(num_values,1+l*2);
for n = num_samples
    %for k = 1:iterations
    [samples_mcs,me_mcs,se_mcs] = montecarloeval(pd,n);  
	[samples_lhs,me_lhs,se_lhs] = lhseval(pd,n);
    E_latinHypercube(i,:) = [n, me_lhs, se_lhs];
    E_monteCarlo(i,:) = [n, me_mcs, se_mcs];
    i = i+1;
    %end
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
variable=3;

fig1.Position = [0, 0, f_width, f_height];
%plot mean deviation
subplot(2,1,1);
hold on;
plot(E_latinHypercube(:,1),E_latinHypercube(:,variable+1),'o','Color',setcolor('purple'),'LineWidth',linewidth,'MarkerSize', 14);
plot(E_monteCarlo(:,1),E_monteCarlo(:,2),'v','Color',setcolor('orange'),'LineWidth',linewidth,'MarkerSize', 14);
legend('latin hypercube','random','Location','northeastoutside');
xlabel('N'); % x-axis label
ylabel('\mu / \mu m'); % y-axis label
set(gca,'fontsize',font_size,'LineWidth',linewidth);
%title('Relative error of the mean of the samples')
hold off;
subplot(2,1,2);
hold on;
plot(E_latinHypercube(:,1),E_latinHypercube(:,variable+4),'o','Color',setcolor('purple'),'LineWidth',linewidth,'MarkerSize', 14);
plot(E_monteCarlo(:,1),E_monteCarlo(:,4),'v','Color',setcolor('orange'),'LineWidth',linewidth,'MarkerSize', 14);
legend('latin hypercube','random','Location','northeastoutside');
xlabel('N'); % x-axis label
ylabel([char(949) '_\sigma']); % y-axis label
set(gca,'fontsize',font_size,'LineWidth',linewidth);
%title('Relative error of the standad deviation of the samples')
hold off;

% Save plot to vector image .eps
fig = gcf;

fig.PaperPositionMode = 'auto';
%print('-dpng','-r300', 'error_comparison')
print('-depsc','-tiff','-r300', 'error_comparison_gamma')
close(fig);

% save the data
% Save Monte Carlo data
     fnam='error_results_MonteCarlo.txt'; % <- your data file
     hdr={'number of samples','mean error x dist','mean error y dist','std error x dist','std error y dist'};
     % the engine
     txt=sprintf('%s\t',hdr{:});
     txt(end)='';
     dlmwrite(fnam,txt,'');
     dlmwrite(fnam,E_monteCarlo,'-append');
     %dlmwrite(fnam,E,'-append','delimiter','\t');
% Save Latin Hypercube data
     fnam2='error_results_LatinHypercube.txt'; % <- your data file
     % the engine
     dlmwrite(fnam2,txt,'');
     dlmwrite(fnam2,E_latinHypercube,'-append');
     %dlmwrite(fnam,E,'-append','delimiter','\t');
