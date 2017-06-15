% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 12, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

% Analize random search with misalignment results

% add path to utils
if ispc == true
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
elseif ismac == true
addpath('/Users/lime/master_thesis/code/utils');
end

% adapt file separator to the operating system
f = filesep;

% specify results path, output path and file names for the output data
currentPath = pwd;
resultsPath_mis = [currentPath f 'results' f 'exp1' f'];
resultsfile = 'exp1_results.mat';
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath f 'results' f 'analysis' f];
outstruct_name = 'exp1_analysis.mat';
print_pic = false;

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
    current_yin = current_geometry(3); %unit: meters
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
 
     value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
    if i==1
        symmetry_plot_vector = [s value];
    else
        symmetry_plot_vector = [symmetry_plot_vector; s value];
    end
    statistics_vector_symmetry(i,:) = [mean_s std_s median_s];
end

x = statistics_vector_symmetry(:,2); % symmetry std
f = statistics_vector_symmetry(:,1); % symmetry mean

std_lim = 0.07:0.0005:0.1;
% TODO - automatically find the contraint boundaries (look for min of each
% function(mean and std) and get the corresponding std)
[pareto_front,fig] = pareto_plot(x,f,std_lim);
xlabel('std of s1');
ylabel('mean s1');

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
