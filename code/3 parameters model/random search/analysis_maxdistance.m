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

% adapt file separator to the operating system
f = filesep;

% specify results path, output path and file names for the output data
currentPath = pwd;
experiment = 'exp1';
resultsPath_mis = [currentPath f 'results' f experiment f];
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath f 'results' f 'analysis' f experiment f];
outstruct_name = [experiment '_analysis.mat'];

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
%feature_labels ={'-P / W m^-^1','S','skewness','-P_{Gaussian} / W m^-^1','rmse','-C'};
feature_labels ={'-P','S','skewness','-P_{Gaussian}','rmse','-C'};

select_feature = containers.Map(feature_ids,feature_names);
select_feat_label = containers.Map(feature_ids,feature_labels);

numFeatures = length(feature_ids);
% preallocation of matrices
features_allG = zeros(nGeomPoints,numFeatures);
delta_allG = zeros(nGeomPoints,numFeatures);
f_perfect = zeros(nGeomPoints,numFeatures);

for i=1:nGeomPoints
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
    feat_mean = mean(features,1);
    features_allG(i,:) = feat_mean;
    
    % extract the data from the perfectly aligned case
    features_perfect = features(1,:); %(power,symmetry,skew,center,rmse,correlation)
    f_perfect(i,:) = features_perfect;
    
    max_features = max(features,[],1);
    min_features = min(features,[],1);
    delta_allG(i,:) = abs(max_features-min_features);
    
end

% get best geometries for all features (misalignment)
[min_feat,min_feat_id] = min(features_allG,[],1);

% get best geometries for all features (aligned)
[min_feat_perfect,min_feat_id_perfect] = min(f_perfect,[],1);

max_delta = max(delta_allG,[],1);
min_delta = min(delta_allG,[],1);
mean_delta = mean(delta_allG,1);

delta_matrix =[max_delta;min_delta;mean_delta];
delta_matrix = delta_matrix(:,[1 2 4 5 6]);
delta_matrix(:,[2,3])=delta_matrix(:,[3,2]);
dlmwrite('Delta_matrix.txt',delta_matrix);

 best_delta = [zeros(1,numFeatures);zeros(1,numFeatures)];
 for l =1:numFeatures
    best_id = min_feat_id(l);
    if l ==1
        best_id_perfect = min_feat_id_perfect(l);
        best_delta(2,l) = delta_allG(best_id_perfect,l);
    end
    if l ==4
        best_id_perfect = min_feat_id_perfect(l);
        best_delta(2,l) = delta_allG(best_id_perfect,l);
    end
    best_delta(1,l) = delta_allG(best_id,l);
 end

best_delta = best_delta(:,[1 2 4 5 6]);
best_delta(:,[2,3])=best_delta(:,[3,2]);
dlmwrite('best_delta.txt',best_delta);
