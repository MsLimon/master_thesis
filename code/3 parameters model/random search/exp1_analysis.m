% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: April 24, 2017
% 
% Extract and analyze the results of exp1 (random search with misalignment)

%color dictionary
% colors: yellow [1  0.8431 0], green [0.1647 0.3843 0.2745]
% orange [0.8706 0.4902 0], purple [0.4941 0.1843 0.5569]
color_names = {'yellow','purple','orange','green'};
color_code = {1,2,3,4};
rgb_values = {[1  0.8431 0],[0.8000 0.6000 1.0000],[0.8706 0.4902 0],[0.1647 0.3843 0.2745]};
setcolor = containers.Map(color_names,rgb_values);
selectcolor = containers.Map(color_code,color_names);
% to get more colors use the Matlab function: c = uisetcolor([0.6 0.8 1])
 
% Analize random search with misalignment results

% specify results path, output path and file names for the output data
currentPath = pwd;
resultsPath_mis = [currentPath '\results\random_misalignment_3\'];
resultsPath_align = [currentPath '\results\perfectly_aligned\'];
outpath = [currentPath '\results\analysis\'];
outstruct_name = 'exp1_results.mat';

% load the geomety data
G = dlmread([resultsPath_mis 'geometry.txt']);
% get dimesions of geometry data
[nGeomPoints,searchSpace_dim] = size(G);
% load the misalignment data
M = dlmread([resultsPath_mis 'misalignment_points.txt']);
% get dimesions of misalignment data
[nMisPoints,misalignment_dim] = size(M);
% load the results for the perfectly aligned data
R_align = dlmread([resultsPath_align 'exp0_results.txt']);
P_align = R_align(:,end);
R_align_meters = R_align;
R_align_meters(:,[2,3]) =R_align_meters(:,[2,3])*1e-6;
% calculate intensity
I_align = P_align ./ R_align_meters(:,3); %unit: W/m^2
% change units to mW/mm^2
I_align = I_align * 1e-3;
[best_I,bestI_id]=max(I_align);
best_candidate = dlmread([resultsPath_align 'exp0_bestcandidate.txt']);
% initialize a vector to store the mean and std of the results for one
% geometry
statistics_vector = zeros(nGeomPoints,5);
for i=1:nGeomPoints
    current_geometry = G(i,:);
    current_beta = current_geometry(1);  %unit: radians
    current_taperx = current_geometry(2)*1e-6; %unit: meters
    current_yin = current_geometry(3)*1e-6; %unit: meters
    resultsfile = sprintf('results_%d.txt',i);
    R = load([resultsPath_mis resultsfile]);
    R = R(:,[1,2,3,5]);
    % extract the power results and calculate the mean and the average
    P = R(:,end); % units [W/m]
    mean_P = mean(P);
    median_P = median(P);
    std_P =  std(P);
    % calculate intensity
    I = P / current_yin; %unit: W/m^2
    % change units to mW/mm^2
    I = I * 1e-3; %unit: mW/mm^2
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: micrometers
     value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
    if i==1
        plot_vector = [P I value];
    else
        plot_vector = [plot_vector; P I value];
    end
    % add the intensity to the results matrix
    R = [R I];
    mean_I = mean(I);
    std_I =std(I);
    statistics_vector(i,:) = [mean_P std_P mean_I std_I median_P];
    data(i) = struct('index',i,'geometry',current_geometry,'misalignment', M,'results',R,'mean_P',mean_P,'std_P',std_P,'mean_I',mean_I,'std_I',std_I);
    % find id of best candidate
    if current_geometry == best_candidate
        bestP_id = i;
    end
end
numbers = {1,2,3};
xlabelvalues = {'beta / rad','x taper / um','y_i_n / um'};
selectlabel = containers.Map(numbers,xlabelvalues);

% plot the results in power
width = 1700;
height= 900;
hFig1 = figure(1);
set(hFig1, 'Position', [50 0 width height])

for i = 1:searchSpace_dim
subplot(searchSpace_dim,1,i);
hold on;
% fig = gcf;
% set(gca,'FontSize',11);
%plot the results for the experiment with misalignemnt
plot(plot_vector(:,i+2),plot_vector(:,1),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
err = statistics_vector(:,2);
errorbar(G(:,i),statistics_vector(:,1),err,'k+');
%plot the median
plot(G(:,i),statistics_vector(:,end),'b*');
%plot the results for the experiment without misalignemnt
plot(G(:,i),P_align,'vk');
plot(G(bestP_id,i),P_align(bestP_id),'vr');
xlabel(selectlabel(i));
ylabel('P / W m^-^1');
AX =legend('misalignment points','mean value','median value','results without misalignment','best cadidate without misalignment','Location','southeast');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',12)

hold off;
end

% Save plot to vector image .eps
hFig1.PaperPositionMode = 'auto';
filename_Pplot = 'randomSearch_Misalignment_P_medians';
print('-dpng','-r300', [outpath filename_Pplot])
print('-depsc','-tiff','-r300', [outpath filename_Pplot])
%close(hFig1);

% plot the results in intensity
% width = 1700;
% height= 900;
% hFig2 = figure(2);
% set(hFig2, 'Position', [50 0 width height])
% % Create axes
% axes1 = axes('Parent',hFig2);
% hold(axes1,'on');
% 
% 
% for i = 1:searchSpace_dim
% subplot(searchSpace_dim,1,i);
% hold on;
% % fig = gcf;
% % set(gca,'FontSize',11);
% %plot the results for the experiment with misalignemnt
% plot(plot_vector(:,i+2),plot_vector(:,2),'o','Color',setcolor(selectcolor(i)));
% % plot mean and std as error bar (experiment with misalignment)
% err = statistics_vector(:,4);
% errorbar(G(:,i),statistics_vector(:,3),err,'k+');
% %plot the results for the experiment without misalignemnt
% plot(G(:,i),I_align,'vk');
% plot(G(bestI_id,i),I_align(bestI_id),'vr');
% xlabel(selectlabel(i));
% ylabel('I / mW mm^-^2');
% AX =legend('misalignment points','mean value','results without misalignment','best cadidate without misalignment','Location','northeast');
% LEG = findobj(AX,'type','text');
% set(LEG,'FontSize',11)
% 
% hold off;
% end

% % Save plot to vector image .eps
% hFig.PaperPositionMode = 'auto';
% filename_Iplot = 'randomSearch_Misalignment_I';
% print('-dpng','-r300', [outpath filename_Iplot])
% print('-depsc','-tiff','-r300', [outpath filename_Iplot])
% close(hFig);

% %save the results of the experiment in a struct
% save([outpath outstruct_name], 'data');
