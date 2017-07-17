% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: Juy 16, 2017
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

% dictionaries to swap between objective functions
feature_ids = {1,2,3,4,5,6};
feature_names = {'power','symmetry','skew','center','rmse','correlation'};
%feature_labels ={'-output power / W m^-^1','symmetry','skewness','-weighted power / W m^-^1','rmse / W m^-^1','-correlation'};
%feature_labels ={'-P / W m^-^1','S','skewness','-P_{Gaussian} / W m^-^1','rmse','-C'};
feature_labels ={'-P','S','skewness','-P_{Gaussian}','rmse','-C'};

select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

for k = 1:6
%select tthe feature
feat_id = k;
if k==3
    continue
end

% adapt file separator to the operating system
f = filesep;

% specify results path, output path and file names for the output data
currentPath = pwd;
experiment = 'exp3';
resultsPath_mis = [currentPath f 'results' f experiment f 'objective_' select_feature(feat_id) f];
misalignmentPath = [currentPath f 'results' f experiment f];
bayesresfile = 'BayesoptResults.mat';
Ilinefile = 'intensity_line_multiple.mat';
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath f 'results' f 'analysis' f experiment f];
outstruct_name = [experiment '_analysis.mat'];
print_pic_p = true;

% load bayesopt results data
load([resultsPath_mis bayesresfile]);
% load Iline data
load([resultsPath_mis Ilinefile]);

G_table = BayesoptResults.XTrace;
% extract geometry from BayesoptResults
G = table2array(G_table);
[nGeomPoints,searchSpace_dim] = size(G);

% extract misalignment data
M = dlmread([misalignmentPath 'misalignment_points.txt']);
% get dimesions of misalignment data
[nMisPoints,misalignment_dim] = size(M);

numFeatures = length(feature_ids);

statistics_vector_feat1 = zeros(nGeomPoints,3);
% initialize best power to an empty vector (best geometry)
best_feat1 = 100;
best_feat1_id = 0;

for i=1:nGeomPoints
    current_geometry = G(i,:);
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: meters

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
    
    % extract the data from the perfectly aligned case
    features_perfect = features(1,:); %(power,symmetry,skew,center,rmse,correlation)
   
     value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
    if i==1
        feat1_plot_vector = [features(:,feat_id) value];
    else
        feat1_plot_vector = [feat1_plot_vector;features(:,feat_id) value];
    end
    feat1_stats = [feat_mean(feat_id) feat_std(feat_id) feat_median(feat_id)];
    statistics_vector_feat1(i,:) = feat1_stats;
    
    objective_1 = feat_mean(feat_id);
    if objective_1 < best_feat1
        best_feat1 = objective_1;
        best_candidate_feat1 = current_geometry;
        best_feat1_id = i;
    end 
end

numbers = {1,2,3};
parameter_names = {'beta','xtaper','yin'};
xlabelvalues = {'beta / rad','x_{taper} / um','y_{in} / um'};
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
    
% create a plot figure
fig1 = figure;

fig1.Position = [0, 0, f_width, f_height];
%subplot(searchSpace_dim,1,i);
hold on;

%plot the results for the experiment with misalignemnt
plot(feat1_plot_vector(:,i+1),feat1_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)),'LineWidth',linewidth,'MarkerSize', 10);
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_feat1(:,2);
% errorbar(G(:,i),statistics_vector_feat1(:,1),err,'k+','LineWidth',linewidth,'MarkerSize', 10);
plot(G(:,i),statistics_vector_feat1(:,1),'k+','LineWidth',linewidth,'MarkerSize', 10);
%plot the median
 ax = gca;
% ax.ColorOrderIndex = 1;
% plot(G(:,i),statistics_vector_feat1(:,end),'*','LineWidth',linewidth);

%plot the results without misalignment
%plot(G(:,i),R_perfect(:,searchSpace_dim+ feat1_id),'s')

%highlight the best power point
ax.ColorOrderIndex = 7;
plot(G(best_feat1_id,i),best_feat1,'v','LineWidth',linewidth*2,'MarkerSize', 14);

% %highlight the best symmetry point
% ax.ColorOrderIndex = 5;
% plot(G(best_symmetry_id,i),best_power,'v','LineWidth',linewidth);

xlabel(selectlabel(i));
ylabel(feature_labels(feat_id));
switch feat_id
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
filename_Pplot = ['randomSearch_misalignment_' select_feature(feat_id) '_' parameter_names{i}];
print(fig1,'-dpng','-r300', [outpath filename_Pplot])
print(fig1,'-depsc','-tiff','-r300', [outpath filename_Pplot])
end
end
end
