% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: July 16, 2017
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

numFeatures = length(feature_ids);

% preallocation of matrices
% change to 2 for inverse taper model
G_best = zeros(numFeatures,3);
best_delta = zeros(1,numFeatures);
delta_matrix = zeros(3,numFeatures);

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

features_allG = zeros(nGeomPoints,numFeatures);
delta_allG = zeros(1,nGeomPoints);

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
    feat = features(:,k);
    
    max_feat = max(feat,[],1);
    min_feat = min(feat,[],1);
    delta_allG(i) = abs(max_feat-min_feat);
    
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


G_best(k,:) = G(best_feat1_id,:);
% % select only beta and yout
%G_best = G_best(:,[1 3]);

max_delta = max(delta_allG);
min_delta = min(delta_allG);
mean_delta = mean(delta_allG);

delta_matrix(:,k) = [max_delta;min_delta;mean_delta];

best_delta(k) = delta_allG(best_feat1_id);
 end
 
% remove skewness
G_best = G_best([1 2 4 5 6],:);
G_best([2,3],:)=G_best([3,2],:);
dlmwrite('G_best.txt',G_best);


delta_matrix = delta_matrix(:,[1 2 4 5 6]);
delta_matrix(:,[2,3])=delta_matrix(:,[3,2]);
dlmwrite('Delta_matrix.txt',delta_matrix);

best_delta = best_delta(:,[1 2 4 5 6]);
best_delta(:,[2,3])=best_delta(:,[3,2]);
dlmwrite('best_delta.txt',best_delta);

