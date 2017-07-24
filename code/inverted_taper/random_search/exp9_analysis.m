% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: Junly 16, 2017
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
print_pic_p = true;
print_pic_s = true;
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
%feature_labels ={'-output power / W m^-^1','symmetry','skewness','-weighted power / W m^-^1','rmse / W m^-^1','-correlation'};
feature_labels ={'-P','S','skewness','-P_{Gaussian}','rmse','-C'};
select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

%select two different features
feat1_id = 1;
feat2_id= 4;

numFeatures = length(feature_ids);
R_perfect = zeros(nGeomPoints,searchSpace_dim + numFeatures);
R_perfect(:,1:end-numFeatures) = G; 

% gather all objectives in one matrix
features_allG = zeros(nGeomPoints,numFeatures);

for i=1:nGeomPoints
    current_geometry = data(i).geometry;
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yout = current_geometry(3); %unit: meters
    % extract misalignment data
    M = data(i).misalignment;
    % get dimesions of misalignment data
    [nMisPoints,misalignment_dim] = size(M);
    
    % extract the Iline data
    Iline_data = data(i).Iline;
    [n,m] = size(Iline_data);
    num_points = n;
    nMisPoints = m/2;

    features = allFeatures(Iline_data); %(power, symmetry,skew,center,rmse,correlation)
    features(:,3) = abs(features(:,3)); % take the absolute value of skew
    feat_mean = mean(features,1);
    feat_median = median(features,1);
    feat_std = std(features,1);
    features_allG(i,:) = feat_mean;
    
    % extract the data from the perfectly aligned case
    features_perfect = features(1,:); %(power,symmetry,skew,center,rmse,correlation)
    R_perfect(i,end+1-numFeatures:end) = features_perfect;
      
   
     value = repmat([current_beta current_taperx current_yout],nMisPoints,1);
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

% get best geometries for all features (misalignment)
[min_feat,min_feat_id] = min(features_allG,[],1);

numbers = {1,2,3};
parameter_names = {'beta','xtaper','yout'};
xlabelvalues = {'beta / rad','x taper / um','y_o_u_t / um'};
selectlabel = containers.Map(numbers,xlabelvalues);

if print_pic_p == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 2;
    font_size = 24;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end


for i = 1:searchSpace_dim
if i==2
    continue
end
% create a plot figure
fig1 = figure;

fig1.Position = [0, 0, f_width, f_height];    
%subplot(searchSpace_dim,1,i);
hold on;

%plot the results for the experiment with misalignemnt
plot(feat1_plot_vector(:,i+1),feat1_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth,'MarkerSize', 14);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_feat1(:,2);
% errorbar(G(:,i),statistics_vector_feat1(:,1),err,'k+','LineWidth',linewidth,'MarkerSize', 10);
plot(G(:,i),statistics_vector_feat1(:,1),'k+','LineWidth',linewidth,'MarkerSize', 14);
%plot the median
% ax.ColorOrderIndex = 1;
% plot(G(:,i),statistics_vector_feat1(:,end),'*','LineWidth',linewidth);

%plot the results without misalignment
%plot(G(:,i),R_perfect(:,searchSpace_dim+ feat1_id),'s')

%highlight the best power point
ax = gca;
ax.ColorOrderIndex = 7;
plot(G(best_feat1_id,i),best_feat1,'v','LineWidth',linewidth*4,'MarkerSize', 16);

% %highlight the best symmetry point
% ax.ColorOrderIndex = 5;
% plot(G(best_symmetry_id,i),best_power,'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel(feature_labels(feat1_id));
switch feat1_id
    case 2
    ylim([0 1]);
    case 5
    ylim([0 1]); 
    otherwise
    ylim([-1 0]);
end
%AX =legend('misalignment points','mean value','median value','perfectly aligned','best point','Location','northeastoutside');
AX =legend('misalignment points','mean value','best point','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size,'LineWidth',linewidth);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
hold off;

if print_pic_p == true
% Save plot to vector image .eps
fig1.PaperPositionMode = 'auto';
filename_Pplot = ['randomSearch_misalignment_' select_feature(feat1_id) '_' parameter_names{i}];
print(fig1,'-dpng','-r300', [outpath filename_Pplot])
print(fig1,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
end

if print_pic_s == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 2;
    font_size = 24;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

for i = 1:searchSpace_dim
if i==2
    continue
end    
% plot the results
fig2 = figure;

fig2.Position = [0, 0, f_width, f_height];
%subplot(searchSpace_dim,1,i);
hold on;

%plot the results for the experiment with misalignemnt
plot(feat2_plot_vector(:,i+1),feat2_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth,'MarkerSize', 14);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_feat2(:,2);
%errorbar(G(:,i),statistics_vector_feat2(:,1),err,'k+','LineWidth',linewidth,'MarkerSize', 10);
plot(G(:,i),statistics_vector_feat2(:,1),'k+','LineWidth',linewidth,'MarkerSize', 14);
%plot the median
 ax = gca;
% ax.ColorOrderIndex = 1;
% plot(G(:,i),statistics_vector_feat2(:,end),'*','LineWidth',linewidth);

%plot the results without misalignment
% plot(G(:,i),R_perfect(:,searchSpace_dim+ feat2_id),'s')

%highlight the best symmetry point
ax.ColorOrderIndex = 7;
plot(G(best_feat2_id,i),statistics_vector_feat2(best_feat2_id,1),'v','LineWidth',linewidth*4,'MarkerSize', 16);

xlabel(selectlabel(i));
ylabel(feature_labels(feat2_id));
switch feat2_id
    case 2
    ylim([0 1]);
    case 5
    ylim([0 1]); 
    otherwise
    ylim([-1 0]);
end
%AX =legend('misalignment points','mean value','median value','perfectly aligned','best point','Location','northeastoutside');
AX =legend('misalignment points','mean value','best point','Location','northeastoutside');LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size,'LineWidth',linewidth);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
hold off;

if print_pic_s == true
% Save plot to vector image .eps
fig2.PaperPositionMode = 'auto';
filename_Pplot2 = ['randomSearch_misalignment_' select_feature(feat2_id) '_' parameter_names{i}];
savefile = [outpath filename_Pplot2];
print(fig2,savefile,'-dpng','-r300')
print(fig2,[outpath filename_Pplot2],'-depsc','-tiff','-r300')
%close(hFig1);
end

end

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

if print_pic_pareto == true
% Save plot to vector image .eps
fig3.PaperPositionMode = 'auto';
filename_Pplot = [experiment '_pareto_front_' select_feature(feat1_id) '_' select_feature(feat2_id)];
print(fig3,'-dpng','-r300', [outpath filename_Pplot])
print(fig3,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end

fig4 = figure;

if print_pic_surface == true
    % select figure size
    f_width = 1700;
    f_height= 1000;
    %select line width of the plot lines
    linewidth = 2;
    font_size = 24;
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

mesh(xq,yq,vq,'LineWidth',linewidth);
hold on
plot3(beta,y_out,v,'o','LineWidth',linewidth,'MarkerSize', 12);
%highlight the best power point
ax = gca;
ax.ColorOrderIndex = 7;
plot3(G(best_feat1_id,1),G(best_feat1_id,3),best_feat1,'v','LineWidth',linewidth*4,'MarkerSize', 14);
xlabel('beta / rad');
ylabel('y_o_u_t / um');
zlabel(feature_labels(feat1_id));
set(gca,'fontsize',font_size,'LineWidth',linewidth);
switch feat1_id
    case 2
    zlim([0 1]);
    case 5
    zlim([0 1]); 
    otherwise
    zlim([-1 0]);
end
switch feat1_id
    case 1
    view(ax,[211.3 28.4]);
    case 2
    view(ax,[-19.1000000000001 46]);
    case 4
    view(ax,[211.3 28.4]);    
    %view(ax,[-62.3 25.2]);
    case 5
    view(ax,[-38.7 33.2]);
    case 6
    view(ax,[-37.5 30]);
end

if print_pic_surface == true
% Save plot to vector image .eps
fig4.PaperPositionMode = 'auto';
filename_Pplot = [experiment '_interpolated_objective_' select_feature(feat1_id)];
print(fig4,'-dpng','-r300', [outpath filename_Pplot])
print(fig4,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end

