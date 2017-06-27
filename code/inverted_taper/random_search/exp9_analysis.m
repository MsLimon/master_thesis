% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 13, 2017
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
resultsPath_mis = [currentPath f 'results' f experiment f];
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath f 'results' f 'analysis' f experiment f];
outstruct_name = [experiment '_analysis.mat'];
print_pic_p = false;
print_pic_s = false;
print_pic_pareto = false;
print_pic_surface = false;

% load results data
load([resultsPath_mis resultsfile]);

% load geometry
G = dlmread([resultsPath_mis 'geometry.txt']);
[nGeomPoints,searchSpace_dim] = size(G);

statistics_vector_feat1 = zeros(nGeomPoints,3);
statistics_vector_feat2 = zeros(nGeomPoints,3);
% initialize best power to an empty vector (best geometry)
best_feat1 = 100;
best_feat1_id = 0;
best_feat2 = 100;
best_feat2_id = 0;

% dictionaries to swap between objective functions
feature_ids = {1,2,3,4,5,6};
feature_names = {'power','symmetry','skew','center','rmse','correlation'};
feature_labels ={'-output power / W m^-^1','symmetry','skewness','-weighted power / W m^-^1','rmse / W m^-^1','-correlation'};
select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

%select two different features
feat1_id = 4;
feat2_id= 2;

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

    features = allFeatures(Iline_data); %(symmetry,skew,center,rmse,correlation)
    features = [-P features]; %(power,symmetry,skew,center,rmse,correlation)
    features(:,3) = abs(features(:,3)); % take the absolute value of skew
    feat_mean = mean(features,1);
    feat_median = median(features,1);
    feat_std = std(features,1);
      
   
     value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
    if i==1
        feat1_plot_vector = [features(:,feat1_id) value];
        feat2_plot_vector = [features(:,feat2_id) value];
    else
        feat1_plot_vector = [feat1_plot_vector;features(:,feat1_id) value];
        feat2_plot_vector = [feat2_plot_vector;features(:,feat2_id) value];
    end
    feat1_stats = [feat_mean(feat1_id) feat_std(feat1_id) feat_median(feat1_id)];
    statistics_vector_feat1(i,:) = feat1_stats;
    statistics_vector_feat2(i,:) = [feat_mean(feat2_id) feat_std(feat2_id) feat_median(feat2_id)];
    
    objective_1 = feat_mean(feat1_id);
    if objective_1 < best_feat1
        best_feat1 = objective_1;
        best_candidate_feat1 = current_geometry;
        best_feat1_id = i;
    end 
    %std_lim = 0.1;
    objective_2 = feat_mean(feat2_id);
    if objective_2 < best_feat2 %&& std_s < std_lim
        best_feat2 = objective_2;
        best_candidate_feat2 = current_geometry;
        best_feat2_id = i;
    end 
end

numbers = {1,2,3};
xlabelvalues = {'beta / rad','x taper / um','y_o_u_t / um'};
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
plot(feat1_plot_vector(:,i+1),feat1_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_feat1(:,2);
errorbar(G(:,i),statistics_vector_feat1(:,1),err,'k+','LineWidth',linewidth);
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_feat1(:,end),'*','LineWidth',linewidth);

%highlight the best power point
ax.ColorOrderIndex = 7;
plot(G(best_feat1_id,i),best_feat1,'v','LineWidth',linewidth);

% %highlight the best symmetry point
% ax.ColorOrderIndex = 5;
% plot(G(best_symmetry_id,i),best_power,'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel(feature_labels(feat1_id));
AX =legend('misalignment points','mean value','median value','best point','Location','northeastoutside');
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
plot(feat2_plot_vector(:,i+1),feat2_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_feat2(:,2);
errorbar(G(:,i),statistics_vector_feat2(:,1),err,'k+','LineWidth',linewidth);
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_feat2(:,end),'*','LineWidth',linewidth);

%highlight the best symmetry point
ax.ColorOrderIndex = 7;
plot(G(best_feat2_id,i),statistics_vector_feat2(best_feat2_id,1),'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel(feature_labels(feat2_id));
AX =legend('misalignment points','mean value','median value','best point','Location','northeastoutside');
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

x = statistics_vector_feat1(:,1); % power mean
f = statistics_vector_feat2(:,1); % symmetry mean

x_max = max(x);
x_min = min(x);
epsilon = (x_max-x_min)/200;
x_max = max(x)+epsilon;
x_min = min(x)+epsilon;
step = -0.05;
num_p = 20;
std_lim = linspace(x_max,x_min,num_p);
% TODO - automatically find the contraint boundaries (look for min of each
% function(mean and std) and get the corresponding std)
[pareto_front,fig3] = pareto_plot(x,f,std_lim,'print','true');

%plot(x,f,'s','LineWidth',linewidth);
xlabel([select_feature(feat1_id) ' mean']);
ylabel([select_feature(feat2_id) ' mean']);
set(gca,'fontsize',font_size);

% plot the results in power
fig4 = figure;

if print_pic_surface == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 1.5;
    font_size = 16;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

fig4.Position = [0, 0, f_width, f_height];

y_out = G(:,3);
beta = G(:,1);
v = x;
max_y = max(y_out);
min_y =min(y_out);
max_beta = max(beta);
min_beta = min(beta);
a = linspace(min_beta,max_beta,50);
b = linspace(min_y,max_y,50);
[xq,yq] = meshgrid(a, b);
vq = griddata(beta,y_out,v,xq,yq);

mesh(xq,yq,vq);
hold on
plot3(beta,y_out,v,'o');
xlabel('beta / rad');
ylabel('y_o_u_t / um');
zlabel(feature_labels(feat1_id));


if print_pic_p == true
% Save plot to vector image .eps
fig1.PaperPositionMode = 'auto';
filename_Pplot = ['randomSearch_misalignment_' select_feature(feat1_id)] ;
print(fig1,'-dpng','-r300', [outpath filename_Pplot])
print(fig1,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
if print_pic_s == true
% Save plot to vector image .eps
fig2.PaperPositionMode = 'auto';
filename_Pplot2 = ['randomSearch_misalignment_' select_feature(feat2_id)];
savefile = [outpath filename_Pplot2];
print(fig2,savefile,'-dpng','-r300')
print(fig2,[outpath filename_Pplot2],'-depsc','-tiff','-r300')
%close(hFig1);
end
if print_pic_pareto == true
% Save plot to vector image .eps
fig3.PaperPositionMode = 'auto';
filename_Pplot = [experiment '_pareto_front_' select_feature(feat1_id) '_' select_feature(feat2_id)];
print(fig3,'-dpng','-r300', [outpath filename_Pplot])
print(fig3,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
% %save the results of the experiment in a struct
% save([outpath outstruct_name], 'analysis');
