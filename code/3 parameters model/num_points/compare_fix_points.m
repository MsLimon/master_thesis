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

% adapt file separator to the operating system
f = filesep;

% specify results path, output path and file names for the output data
currentPath =pwd;
resultsPath_mis = [currentPath f 'results' f 'fix_points' f];
%currentPath = '/Users/lime/master_thesis/code/3 parameters model/num_points';
experiments = {'misalignment_1','misalignment_2','misalignment_3','misalignment_4','misalignment_5'};
experiment_label = {'1','2','3','4','5'};
nExperiments = length(experiments);
print_pic = true;

% load geometry
G = dlmread([resultsPath_mis 'geometry.txt']);
[nGeomPoints,searchSpace_dim] = size(G);

% dictionaries to swap between objective functions
feature_ids = {1,2,3,4,5,6};
feature_names = {'power','symmetry','skew','center','rmse','correlation'};
feature_labels ={'-P ','S','skewness','-P_{Gaussian}','rmse','-C'};
%feature_labels ={'\epsilon_P ','\epsilon_S','skewness','\epsilon_{P_{Gaussian}}','\epsilon_{rmse}','\epsilon_{C}'};
select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

numFeatures = length(feature_ids);

fig2 = figure;
% select figure size
f_width = 1000;
f_height= 500;
%select line width of the plot lines
linewidth = 2;
font_size = 24;
fig2.Position = [100, 100, f_width, f_height];


for k=1:numFeatures
if k==3
    continue
end
% fig = figure;
% if print_pic == true
%     % select figure size
%     f_width = 1700;
%     f_height= 500;
%     %select line width of the plot lines
%     linewidth = 2;
%     font_size = 24;
% else
%     % select figure size
%     f_width = 700;
%     f_height = 400;
%     %select line width of the plot lines
%     linewidth = 1;
%     font_size = 10;
% end
% fig.Position = [100, 100, f_width, f_height];

%select two different features

feat1_id = k;

statistics_vector_ref = zeros(nGeomPoints,3);

mean_matrix =zeros(nGeomPoints,nExperiments);

for j = 1:nExperiments
experiment = experiments{j};
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
% outpath = [currentPath f 'results' f 'analysis' f experiment f];
% outstruct_name = [experiment '_analysis.mat'];

% load results data
load([resultsPath_mis resultsfile]);

statistics_vector_feat1 = zeros(nGeomPoints,3);



for i=1:nGeomPoints
    current_geometry = data(i).geometry;
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: meters
    % extract misalignment data
    M = data(i).misalignment;
    % get dimesions of misalignment data
    [nMisPoints,misalignment_dim] = size(M);
  
    % extract the Iline data
    Iline_data = data(i).Iline;
    [n,m] = size(Iline_data);
    num_points = n;
    nMisPoints = m/2;

    features = allFeatures(Iline_data); %(symmetry,skew,center,rmse,correlation)
    
    features(:,3) = abs(features(:,3)); % take the absolute value of skew
    feat_mean = mean(features,1);
    feat_median = median(features,1);
    feat_std = std(features,1);
   
    feat1_stats = [feat_mean(feat1_id) feat_std(feat1_id) feat_median(feat1_id)];
    statistics_vector_feat1(i,:) = feat1_stats;
    if j==1
        statistics_vector_ref(i,:) = feat1_stats;
    end
    
end

mean_matrix(:,j) = statistics_vector_feat1(:,1);

%plot error bars
% err = statistics_vector_feat1(:,2);
% errorbar(x,f1,err,'+','DisplayName',legendname,'LineWidth',linewidth);

% hold on
% % subplot(2,1,1);
% x = 1:nGeomPoints;
% f1 = statistics_vector_feat1(:,1);
% f2 = statistics_vector_ref(:,1);
% legendname = sprintf('misalignment set %s',experiment_label{j});
% rel_error = (f1-f2)./abs(f2);
% plot(x,f1,'-','DisplayName',legendname,'LineWidth',linewidth);
% 
% % hold on
% % subplot(2,1,2);
% % f2 = statistics_vector_feat2(:,1); % symmetry mean
% % %plot(x,f2,'-','DisplayName',legendname,'LineWidth',linewidth);
% % err = statistics_vector_feat2(:,2);
% % errorbar(x,f2,err,'+','DisplayName',legendname,'LineWidth',linewidth);
% % 
% % xlabel('geometry point number');
% % ylabel(feature_labels(feat2_id));
% % AX = legend('show','Location','northeastoutside');
% % LEG = findobj(AX,'type','text');
% % set(LEG,'FontSize',font_size,'LineWidth',linewidth);
% % set(gca,'fontsize',font_size,'LineWidth',linewidth);
% 
% end
% 
% xlabel('geometry point number');
% ylabel(feature_labels(feat1_id));
% xlim([0 6])
% switch k
%     case 2
%     ylim([0 1]);
%     case 5
%     ylim([0 1]); 
%     otherwise
%     ylim([-1 0]);
end
% AX = legend('show','Location','northeastoutside');
% LEG = findobj(AX,'type','text');
% set(LEG,'FontSize',font_size,'LineWidth',linewidth);
% set(gca,'fontsize',font_size,'LineWidth',linewidth);
% hold off

% if k==1


max_vector= max(mean_matrix,[],2);
min_vector = min(mean_matrix,[],2);

max_error_vector =max_vector - min_vector;
hold on
x = 1:nGeomPoints;
legendname = sprintf('%s',feature_names{k});
plot(x,max_error_vector,'DisplayName',legendname,'LineWidth',linewidth);

xlabel('geometry point number');
%ylabel(['max \Delta_{f}' feature_names(feat1_id)]);
%ylabel('max \Delta_{f}');
ylabel('maximum difference');
%set(gca,'ytick',1:5)
AX = legend('show','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size,'LineWidth',linewidth);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
%legend('on');

% if print_pic == true
%     % Save plot to vector image .eps
% %     picname = ['fix_points_comparison_' feature_names{feat1_id}];
% %     print(fig,picname,'-r300','-dpng')
%     picname2 = ['fix_points_error_' feature_names{feat1_id}];
%     print(fig2,picname2,'-r300','-dpng')
% end
end
if print_pic == true
    % Save plot to vector image .eps
%     picname = ['fix_points_comparison_' feature_names{feat1_id}];
%     print(fig,picname,'-r300','-dpng')
    picname2 = ['fix_points_error_' feature_names{feat1_id}];
    print(fig2,picname2,'-r300','-dpng')
end
