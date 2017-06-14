% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 12, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

% Analize random search with misalignment results

% add path to utils
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');

% specify results path, output path and file names for the output data
currentPath = pwd;
resultsPath_mis = [currentPath '\results\exp5\'];
resultsfile = 'exp5_results.mat';
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath '\results\analysis\'];
outstruct_name = 'exp5_analysis.mat';
print_pic = true;

% load results data
load([resultsPath_mis resultsfile]);

% load geometry
G = dlmread([resultsPath_mis 'geometry.txt']);
[nGeomPoints,searchSpace_dim] = size(G);

statistics_vector_symmetry = zeros(nGeomPoints,3);
% initialize best power to an empty vector (best geometry)

best_symmetry = 1;
best_symmetry_id = 0;

for i=1:nGeomPoints
    current_geometry = data(i).geometry;
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: micrometers
    current_D0 = current_geometry(4); %unit: micrometers
    current_w = current_geometry(5); %unitless
    % extract the power results and calculate the mean and the average
    M = data(i).misalignment;
    % get dimesions of misalignment data
    [nMisPoints,misalignment_dim] = size(M);
        
    % extract the Iline data
    Iline_data = data(i).Iline;
    [n,m] = size(Iline_data);
    num_points = n;
    nMisPoints = m/2;
    
    s = symmetry(Iline_data,'weights','gaussian','norm','euclidean');
    s = s';
    mean_s = mean(s);
    median_s = median(s);
    std_s = std(s);
 
     value = repmat([current_beta current_taperx current_yin current_D0 current_w],nMisPoints,1);
    if i==1
        symmetry_plot_vector = [s value];
    else
        symmetry_plot_vector = [symmetry_plot_vector; s value];
    end
    statistics_vector_symmetry(i,:) = [mean_s std_s median_s];
end

fig = figure;
if print_pic == true
    % select figure size
    f_width = 1400;
    f_height = 700;
    %select line width of the plot lines
    linewidth = 1.5;
    font_size = 14;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end
fig.Position = [100, 100, f_width, f_height];

x = statistics_vector_symmetry(:,2); % symmetry std
f = statistics_vector_symmetry(:,1); % symmetry mean
plot(x,f,'s','LineWidth',linewidth,'DisplayName','regular solutions');

xlabel('std');
ylabel('mean');


hold on
std_lim = 0.08:0.005:0.1;
% TODO - automatically find the contraint boundaries (look for min of each
% function(mean and std) and get the corresponding std)
num_std_lim = length(std_lim);
pareto_front = zeros(num_std_lim,3);
for i=1:num_std_lim
    lim = std_lim(i);
    valid_id = find(x<lim);
    valid_f = f(valid_id);
    [f_min,I_min]=min(valid_f);
    min_id = valid_id(I_min);
    x_min = x (min_id);
    pareto_front(i,:) = [min_id x_min f_min];
end
pareto_front = unique(pareto_front,'rows');
pareto_id = (pareto_front(:,1))';
x_pareto = (pareto_front(:,2))';
f_pareto = (pareto_front(:,3))';
num_pareto = length(pareto_id);
for j = 1:num_pareto
    legendname = sprintf('id = %d',pareto_id(j));
    plot(x_pareto(j),f_pareto(j),'*','LineWidth',linewidth,'DisplayName',legendname)
end
LEG=legend('show');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size);
x_pareto = x(pareto_id);
f_pareto = f(pareto_id);
[f_pareto,I] = sort(f_pareto);
x_pareto = x_pareto(I);
% plot pareto front
plot(x_pareto,f_pareto,'-','LineWidth',linewidth,'DisplayName','pareto front');

if print_pic == true
% Save plot to vector image .eps
fig.PaperPositionMode = 'auto';
filename_Pplot2 = 'exp1_symmetry_pareto_front';
savefile = [outpath filename_Pplot2];
print(fig,savefile,'-dpng','-r300')
print(fig,[outpath filename_Pplot2],'-depsc','-tiff','-r300')
%close(hFig1);
end
% %save the results of the experiment in a struct
% save([outpath outstruct_name], 'analysis');
