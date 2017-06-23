% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 15, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

% add path to utils
if ispc == true
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
elseif ismac == true
addpath('/Users/lime/master_thesis/code/utils');
end
%color dictionary
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
color_names = {'yellow','purple','orange','green'};
color_code = {1,2,3,4};
rgb_values = {[1  0.8431 0],[0.6600 0.3100 0.6600],[0.8706 0.4902 0],[0.1647 0.3843 0.2745]};
setcolor = containers.Map(color_names,rgb_values);
selectcolor = containers.Map(color_code,color_names);
% to get more colors use the Matlab function: c = uisetcolor([0.6 0.8 1])
 
% Analize random search with misalignment results

% adapt file separator to the operating system
f = filesep;

% specify results path, output path and file names for the output data
currentPath = pwd;
experiment = 'exp9';
resultsPath_mis = [currentPath  f 'results' f experiment f];
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath f 'results' f 'analysis' f experiment f];
outstruct_name = [experiment '_analysis.mat'];
print_pic_p = false;
print_pic_s = false;
print_pic_pareto = false;

% load results data
load([resultsPath_mis resultsfile]);

% load geometry
G = dlmread([resultsPath_mis 'geometry.txt']);
[nGeomPoints,searchSpace_dim] = size(G);

statistics_vector_power = zeros(nGeomPoints,3);
statistics_vector_symmetry = zeros(nGeomPoints,3);
% initialize best power to an empty vector (best geometry)
best_power = 0;
best_power_id = 0;
best_symmetry = 1;
best_symmetry_id = 0;

for i=1:nGeomPoints
    current_geometry = data(i).geometry;
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: meters
    % extract the power results and calculate the mean and the average
    R = data(i).results;
    M = data(i).misalignment;
    % get dimesions of misalignment data
    [nMisPoints,misalignment_dim] = size(M);
    
    P = R(:,end); % units [W/m]
    mean_P = mean(P);
    median_P = median(P);
    std_P =  std(P);
    
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
    k = skew(Iline_data,'mu','mean');
    mean_k = mean(abs(k));
    median_k = median(abs(k));
    std_k = std(k);
 
     value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
    if i==1
        power_plot_vector = [P value];
        symmetry_plot_vector = [s value];
    else
        power_plot_vector = [power_plot_vector; P value];
        symmetry_plot_vector = [symmetry_plot_vector; s value];
    end
    power_stats = [mean_P std_P median_P];
    statistics_vector_power(i,:) = power_stats;
    statistics_vector_symmetry(i,:) = [mean_s std_s median_s];
    
    if mean_P > best_power
        best_power = mean_P;
        best_candidate_P = current_geometry;
        best_power_id = i;
    end 
    std_lim = 0.1;
    objective = mean_s;
    if objective < best_symmetry && std_s < std_lim
        best_symmetry = objective;
        best_candidate_s = current_geometry;
        best_symmetry_id = i;
    end 
end

numbers = {1,2,3};
xlabelvalues = {'beta / rad','x taper / um','y_i_n / um'};
selectlabel = containers.Map(numbers,xlabelvalues);

% plot the results in power
fig1 = figure;

if print_pic_p == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 1.15;
    font_size = 16;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

fig1.Position = [0, 0, f_width, f_height];


for i = 1:searchSpace_dim
subplot(searchSpace_dim,1,i);
hold on;

%plot the results for the experiment with misalignemnt
plot(power_plot_vector(:,i+1),power_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_power(:,2);
errorbar(G(:,i),statistics_vector_power(:,1),err,'k+','LineWidth',linewidth);
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_power(:,end),'*','LineWidth',linewidth);

%highlight the best power point
ax.ColorOrderIndex = 7;
plot(G(best_power_id,i),best_power,'v','LineWidth',linewidth);

% %highlight the best symmetry point
% ax.ColorOrderIndex = 5;
% plot(G(best_symmetry_id,i),best_power,'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel('P / W m^-^1');
AX =legend('misalignment points','mean value','median value','best power','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size);
hold off;
end
% plot the results
fig2 = figure;

if print_pic_s == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 1.15;
    font_size = 16;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

fig2.Position = [0, 0, f_width, f_height];
for i = 1:searchSpace_dim
subplot(searchSpace_dim,1,i);
hold on;

%plot the results for the experiment with misalignemnt
plot(symmetry_plot_vector(:,i+1),symmetry_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_symmetry(:,2);
errorbar(G(:,i),statistics_vector_symmetry(:,1),err,'k+','LineWidth',linewidth);
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_symmetry(:,end),'*','LineWidth',linewidth);

%highlight the best symmetry point
ax.ColorOrderIndex = 7;
plot(G(best_symmetry_id,i),statistics_vector_symmetry(best_symmetry_id,1),'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel('s1');
AX =legend('misalignment points','mean value','median value','best symmetry','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size);
hold off;
end

% % plot the results in power
% fig3 = figure;
% 
% if print_pic_pareto == true
%     % select figure size
%     f_width = 1700;
%     f_height= 1000;
%     %select line width of the plot lines
%     linewidth = 1.5;
%     font_size = 16;
% else
%     % select figure size
%     f_width = 700;
%     f_height = 400;
%     %select line width of the plot lines
%     linewidth = 1;
%     font_size = 10;
% end
% 
% fig3.Position = [0, 0, f_width, f_height];

x = -statistics_vector_power(:,1); % power mean
f = statistics_vector_symmetry(:,1); % symmetry mean

std_lim = -1.6:-0.0005:-1.9;
% TODO - automatically find the contraint boundaries (look for min of each
% function(mean and std) and get the corresponding std)
[pareto_front,fig3] = pareto_plot(x,f,std_lim,'print','true');
%plot(x,f,'s')
xlabel('power mean');
ylabel('symmetry mean');

if print_pic_p == true
% Save plot to vector image .eps
fig1.PaperPositionMode = 'auto';
filename_Pplot = 'randomSearch_misalignment_power';
print(fig1,'-dpng','-r300', [outpath filename_Pplot])
print(fig1,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
if print_pic_s == true
% Save plot to vector image .eps
fig2.PaperPositionMode = 'auto';
filename_Pplot2 = 'randomSearch_misalignment_symmetry';
savefile = [outpath filename_Pplot2];
print(fig2,savefile,'-dpng','-r300')
print(fig2,[outpath filename_Pplot2],'-depsc','-tiff','-r300')
%close(hFig1);
end
if print_pic_pareto == true
% Save plot to vector image .eps
fig3.PaperPositionMode = 'auto';
filename_Pplot = [experiment '_pareto_front'];
print(fig3,'-dpng','-r300', [outpath filename_Pplot])
print(fig3,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
% %save the results of the experiment in a struct
% save([outpath outstruct_name], 'analysis');
