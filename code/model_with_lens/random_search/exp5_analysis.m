% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 13, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

% add path to utils
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');

%color dictionary
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
color_names = {'yellow','purple','orange','green','red'};
color_code = {1,2,3,4,5};
rgb_values = {[1  0.8431 0],[0.6500 0.5600 0.7600],[0.9300 0.6900 0.1300],[0.1647 0.3843 0.2745],[0.6400 0.0800 0.1800]};
setcolor = containers.Map(color_names,rgb_values);
selectcolor = containers.Map(color_code,color_names);
% to get more colors use the Matlab function: c = uisetcolor([0.6 0.8 1])

print_pic_pareto = false;

% specify results path, output path and file names for the output data
currentPath = pwd;
resultsPath_mis = [currentPath '\results\exp5\'];

load([resultsPath_mis 'exp5_results.mat']);
outpath = [currentPath '\results\analysis\'];
% load the geomety data
nGeomPoints = length(data);
G = dlmread([resultsPath_mis 'geometry.txt']);
% get dimesions of geometry data
% G = G(1:nGeomPoints,:);
[nGeomPoints,searchSpace_dim] = size(G);
% load the misalignment data
M = dlmread([resultsPath_mis 'misalignment_points.txt']);
% get dimesions of misalignment data
[nMisPoints,misalignment_dim] = size(M);

% initialize a vector to store the mean and std of the results for one
% geometry
statistics_vector_power = zeros(nGeomPoints,3);
statistics_vector_symmetry = zeros(nGeomPoints,3);
% initialize best power to an empty vector (best geometry)
best_power = 0;
best_power_id = 0;
best_symmetry = 1;
best_symmetry_id = 0;

for i =1:length(data)
    current_geometry = data(i).geometry;
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: micrometers
    current_D0 = current_geometry(4); %unit: micrometers
    current_w = current_geometry(5); %unitless
    R = data(i).results;
    P = R(:,end);
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
    
    value = repmat([current_beta current_taperx current_yin current_D0 current_w],nMisPoints,1);
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
    statistics_vector_power(i,:) = [mean_P std_P median_P];
    
    if mean_P > best_power
            best_power = mean_P;
            best_candidate_P = current_geometry;
            best_power_id = i;
    end
        
    std_lim = 0.1;
    objective = mean_k;
    if objective < best_symmetry && std_s < std_lim
        best_symmetry = objective;
        best_candidate_s = current_geometry;
        best_symmetry_id = i;
    end 
end

numbers = {1,2,3,4,5};
xlabelvalues = {'beta / rad','x taper / um','y_i_n / um','D_0 / um','w'};
selectlabel = containers.Map(numbers,xlabelvalues);

% plot the results in power
width = 1700;
height= 900;
% hFig1 = figure(1);
% set(hFig1, 'Position', [50 0 width height])

for i = 1:searchSpace_dim
% for i = 1
% subplot(searchSpace_dim,1,i);
fig = figure;
set(fig, 'Position', [50 0 width height])

subplot(2,1,1);
hold on;

% set(gca,'FontSize',11);
%plot the results for the experiment with misalignemnt
plot(power_plot_vector(:,i+1),power_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_power(:,2);
errorbar(G(:,i),statistics_vector_power(:,1),err,'k+');
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_power(:,end),'*');

%highlight the best  point
ax.ColorOrderIndex = 6;
plot(G(best_power_id,i),best_power,'v');

xlabel(selectlabel(i));
ylabel('P / W m^-^1');
AX =legend('misalignment points','mean value','median value','best power','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',12)
hold off


% for i = 1
% subplot(searchSpace_dim,1,i);
% fig2 = figure;
    subplot(2,1,2);
hold on
% set(gca,'FontSize',11);
%plot the results for the experiment with misalignemnt
plot(symmetry_plot_vector(:,i+1),symmetry_plot_vector(:,1),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector_symmetry(:,2);
errorbar(G(:,i),statistics_vector_symmetry(:,1),err,'k+');
%plot the median
ax = gca;
ax.ColorOrderIndex = 1;
plot(G(:,i),statistics_vector_symmetry(:,end),'*');

%highlight the best  point
ax.ColorOrderIndex = 6;
plot(G(best_symmetry_id,i),best_symmetry,'v');

xlabel(selectlabel(i));
ylabel('symmetry measure s_1');
AX =legend('misalignment points','mean value','median value','best symmetry','Location','northeastoutside');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',12)

 hold off;
end

% plot the results in power
fig3 = figure;

if print_pic_pareto == true
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
    linewidth = 1.15;
    font_size = 10;
end

fig3.Position = [0, 0, f_width, f_height];

x = -statistics_vector_power(:,1); % power mean
f = statistics_vector_symmetry(:,1); % symmetry mean
plot(x,f,'s','LineWidth',linewidth);
xlabel('power mean');
ylabel('symmetry mean');
    