% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 30, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

%color dictionary
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
color_names = {'yellow','purple','orange','green','red'};
color_code = {1,2,3,4,5};
rgb_values = {[1  0.9 0],[0.8000 0.6000 1.0000],[0.9300 0.6900 0.1300],[0.1647 0.3843 0.2745],[0.6400 0.0800 0.1800]};
setcolor = containers.Map(color_names,rgb_values);
selectcolor = containers.Map(color_code,color_names);
% to get more colors use the Matlab function: c = uisetcolor([0.6 0.8 1])

% specify results path, output path and file names for the output data
currentPath = pwd;
resultsPath_mis = [currentPath '\results\'];

load([resultsPath_mis 'exp5_results.mat']);

% load the geomety data
nGeomPoints = length(data);
G = dlmread([resultsPath_mis 'geometry.txt']);
% get dimesions of geometry data
G = G(1:nGeomPoints,:);
[nGeomPoints,searchSpace_dim] = size(G);
% load the misalignment data
M = dlmread([resultsPath_mis 'misalignment_points.txt']);
% get dimesions of misalignment data
[nMisPoints,misalignment_dim] = size(M);

% initialize a vector to store the mean and std of the results for one
% geometry
statistics_vector = zeros(nGeomPoints,3);

% initialize best power to an empty vector (best geometry)
best_power = 0;
best_id = 0;

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
    %Iline_data = data(i).Iline;
    %s = symmetry(Iline_data,'weights','gaussian','norm','euclidean');
    value = repmat([current_beta current_taperx current_yin current_D0 current_w],nMisPoints,1);
    if i==1
        plot_vector = [P value];
    else
        plot_vector = [plot_vector; P value];
    end
    statistics_vector(i,:) = [mean_P std_P median_P];
    if mean_P > best_power
            best_power = mean_P;
            best_candidate = current_geometry;
            best_id = i;
        end 
end

numbers = {1,2,3,4,5};
xlabelvalues = {'beta / rad','x taper / um','y_i_n / um','D_0 / um','w'};
selectlabel = containers.Map(numbers,xlabelvalues);

% plot the results in power
% width = 1700;
% height= 900;
% hFig1 = figure(1);
% set(hFig1, 'Position', [50 0 width height])

for i = 1:searchSpace_dim
% for i = 1
% subplot(searchSpace_dim,1,i);
fig = figure(i);
 hold on;

% set(gca,'FontSize',11);
%plot the results for the experiment with misalignemnt
plot(plot_vector(:,i+1),plot_vector(:,1),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector(:,2);
errorbar(G(:,i),statistics_vector(:,1),err,'k+');
%plot the median
plot(G(:,i),statistics_vector(:,end),'b*');

%highlight the best  point
plot(G(best_id,i),best_power,'vr');

xlabel(selectlabel(i));
ylabel('P / W m^-^1');
AX =legend('misalignment points','mean value','median value','best','Location','southeast');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',12)

 hold off;
end

    