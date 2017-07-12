% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 14, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)
% TODO - calculate average intensity for all number of points 
% (for some geometry) and compare lines. Calculate difference! (rmse or
% something like this)

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

% specify results path, output path and file names for the output data
%currentPath =pwd;
currentPath = '/Users/lime/master_thesis/code/3 parameters model/num_points';
experiments = {'exp1','90_num_points','60_num_points','30_num_points'};
experiment_label = {'120','90','60','30'};
nExperiments = length(experiments);
print_pic = true;

fig = figure;
if print_pic == true
    % select figure size
    f_width = 1700;
    f_height= 500;
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
fig.Position = [100, 100, f_width, f_height];

% adapt file separator to the operating system
f = filesep;

for j = 1:nExperiments
experiment = experiments{j};
resultsPath_mis = [currentPath f 'results' f];
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
% outpath = [currentPath f 'results' f 'analysis' f experiment f];
% outstruct_name = [experiment '_analysis.mat'];


% load results data
load([resultsPath_mis resultsfile]);

% load geometry
G = dlmread([resultsPath_mis 'geometry.txt']);
[nGeomPoints,searchSpace_dim] = size(G);

statistics_vector_feat1 = zeros(nGeomPoints,3);
statistics_vector_feat2 = zeros(nGeomPoints,3);

% dictionaries to swap between objective functions
feature_ids = {1,2,3,4,5,6};
feature_names = {'power','symmetry','skew','center','rmse','correlation'};
feature_labels ={'-P / W m^-^1','S','skewness','-P_{Gaussian} / W m^-^1','rmse / W m^-^1','-C'};
select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

numFeatures = length(feature_ids);

%select two different features
feat1_id = 1;
feat2_id= 4;

% initialize best power to an empty vector (best geometry)
best_feat1 = 100;
best_feat1_id = 0;
best_feat2 = 100;
best_feat2_id = 0;

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

end

hold on
% subplot(2,1,1);
x = 1:length(data);
f1 = statistics_vector_feat1(:,1);
legendname = sprintf('%s points',experiment_label{j});
%plot(x,f1,'-','DisplayName',legendname,'LineWidth',linewidth);
err = statistics_vector_feat1(:,2);
errorbar(x,f1,err,'+','DisplayName',legendname,'LineWidth',linewidth);
xlabel('geometry point number');
ylabel(feature_labels(feat1_id));
xlim([0 21])
AX = legend('show','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size,'LineWidth',linewidth);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
% hold on
% subplot(2,1,2);
% f2 = statistics_vector_feat2(:,1); % symmetry mean
% %plot(x,f2,'-','DisplayName',legendname,'LineWidth',linewidth);
% err = statistics_vector_feat2(:,2);
% errorbar(x,f2,err,'+','DisplayName',legendname,'LineWidth',linewidth);
% 
% xlabel('geometry point number');
% ylabel(feature_labels(feat2_id));
% AX = legend('show','Location','northeastoutside');
% LEG = findobj(AX,'type','text');
% set(LEG,'FontSize',font_size,'LineWidth',linewidth);
% set(gca,'fontsize',font_size,'LineWidth',linewidth);

end

hold off
if print_pic == true
    % Save plot to vector image .eps
    picname = ['num_points_comparison'];
    print(fig,picname,'-r300','-dpng')
end