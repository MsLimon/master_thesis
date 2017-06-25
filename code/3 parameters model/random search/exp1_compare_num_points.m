% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 14, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)
% TODO - calculate average intensity for all number of points 
% (for some geometry) and compare lines. Calculate difference! (rmse or
% something like this)

% add path to utils
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');

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
currentPath = pwd;
experiments = {'exp1','90_num_points','60_num_points','30_num_points'};
nExperiments = length(experiments);
print_pic = true;

fig = figure;
if print_pic == true
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
fig.Position = [100, 100, f_width, f_height];

for j = 1:nExperiments
experiment = experiments{j};
resultsPath_mis = [currentPath '\results\' experiment '\'];
resultsfile = [experiment '_results.mat'];
% resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath '\results\analysis\' experiment '\'];
outstruct_name = [experiment '_analysis.mat'];


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

hold on
subplot(2,1,1);
x = 1:length(data);
f1 = statistics_vector_power(:,1);
legendname = sprintf('experiment: %s',experiment);
%plot(x,f1,'-','DisplayName',legendname,'LineWidth',linewidth);
err = statistics_vector_power(:,2);
errorbar(x,f1,err,'+','DisplayName',legendname,'LineWidth',linewidth);
xlabel('geometry point number');
ylabel('power mean');
AX = legend('show','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size);
hold on
subplot(2,1,2);
f2 = statistics_vector_symmetry(:,1); % symmetry mean
%plot(x,f2,'-','DisplayName',legendname,'LineWidth',linewidth);
err = statistics_vector_symmetry(:,2);
errorbar(x,f2,err,'+','DisplayName',legendname,'LineWidth',linewidth);

xlabel('geometry point number');
ylabel('symmetry mean');
AX = legend('show','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size);

end

hold off
if print_pic == true
% Save plot to vector image .eps
fig.PaperPositionMode = 'auto';
filename_Pplot = 'num_points_comparison';
print(fig,'-dpng','-r300', filename_Pplot)
print(fig,'-depsc','-tiff','-r300', filename_Pplot)
end