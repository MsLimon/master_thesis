% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 11, 2017
% 
% Extract and analyze the results of ex1 (random search with misalignment).
% Study number of misalignment points

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

% initialize a vector to store the mean and std of the results for one
% geometry
statistics_vector = zeros(nGeomPoints,4);

statistics_vector10 = zeros(nGeomPoints,2); 
statistics_vector20 = zeros(nGeomPoints,2); 
statistics_vector50 = zeros(nGeomPoints,2); 
statistics_vector80 = zeros(nGeomPoints,2);

samples = [10,20,50,80];
trials = size(samples,2);
mean_matrix = zeros(nGeomPoints,trials);
std_matrix = zeros(nGeomPoints,trials);

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
    
   % sample different sample sizes of misalignment points
%     if i ==1
%         [P_sample10, idx10] = datasample(P,10,'Replace',false);
%         [P_sample20, idx20] = datasample(P,20,'Replace',false);
%         [P_sample50, idx50] = datasample(P,50,'Replace',false);
%         [P_sample80, idx80] = datasample(P,80,'Replace',false);
%     else
%         % take the same points for all geometries
%         P_sample10 = P(idx10);
%         P_sample20 = P(idx20);
%         P_sample50 = P(idx50);
%         P_sample80 = P(idx80);
%     end
   
    [P_sample10, idx10] = datasample(P,10,'Replace',false);
    [P_sample20, idx20] = datasample(P,20,'Replace',false);
    [P_sample50, idx50] = datasample(P,50,'Replace',false);
    [P_sample80, idx80] = datasample(P,80,'Replace',false);

    %calculate mean and std of the power outputs
    mean_P = mean(P);
    median_P = median(P);
    std_P =  std(P);
    % do the same for the samples
    mean_Psample10 = mean(P_sample10);
    mean_Psample20 = mean(P_sample20);
    mean_Psample50 = mean(P_sample50);
    mean_Psample80 = mean(P_sample80);
    
    mean_matrix(i,:) = [mean_Psample10 mean_Psample20 mean_Psample50 mean_Psample80];
    
    std_Psample10 = std(P_sample10);
    std_Psample20 = std(P_sample20);
    std_Psample50 = std(P_sample50);
    std_Psample80 = std(P_sample80);
    
    std_matrix(i,:) = [std_Psample10 std_Psample20 std_Psample50 std_Psample80];
    
    % calculate intensity
    I = P / current_yin; %unit: W/m^2
    % change units to mW/mm^2
    I = I * 1e-3; %unit: mW/mm^2
    
    current_taperx = current_geometry(2); %unit: micrometers
    current_yin = current_geometry(3); %unit: micrometers
    % prepare plot vector, repeat the geometry.
    value = repmat([current_beta current_taperx current_yin],nMisPoints,1);
   
    value_sample10 = repmat([current_beta current_taperx current_yin], 10, 1 );
    value_sample20 = repmat([current_beta current_taperx current_yin], 20, 1 );
    value_sample50 = repmat([current_beta current_taperx current_yin], 50, 1 );
    value_sample80 = repmat([current_beta current_taperx current_yin], 80, 1 );
    
    if i==1
        plot_vector = [P I value];
        %create plot vector for the samples
        plot_sample10 = [value_sample10 P_sample10];
        plot_sample20 = [value_sample20 P_sample20];
        plot_sample50 = [value_sample50 P_sample50];
        plot_sample80 = [value_sample80 P_sample80];
    else
        plot_vector = [plot_vector; P I value];
        % add the power output for the 
        plot_sample10 = [plot_sample10; value_sample10 P_sample10];
        plot_sample20 = [plot_sample20; value_sample20 P_sample20];
        plot_sample50 = [plot_sample50; value_sample50 P_sample50];
        plot_sample80 = [plot_sample80; value_sample80 P_sample80];
    end
    % add the intensity to the results matrix
    R = [R I];
    mean_I = mean(I);
    std_I =std(I);
    statistics_vector(i,:) = [mean_P std_P mean_I std_I];
    
    statistics_vector10(i,:) = [mean_Psample10 std_Psample10]; 
    statistics_vector20(i,:) = [mean_Psample20 std_Psample20]; 
    statistics_vector50(i,:) = [mean_Psample50 std_Psample50]; 
    statistics_vector80(i,:) = [mean_Psample80 std_Psample80]; 
end
numbers = {1,2,3};
xlabelvalues = {'beta / rad','x taper / um','y_i_n / um'};
selectlabel = containers.Map(numbers,xlabelvalues);

% plot the results in power
width = 1700;
height= 900;
hFig = figure(1);
set(hFig, 'Position', [50 0 width height])

for i = 1:searchSpace_dim
    
    subplot(searchSpace_dim,trials+1,(i-1)*(trials+1) +1);
    
    hold on;
    %plot the results for the experiment with misalignemnt
    plot(plot_vector(:,i+2),plot_vector(:,1),'o','Color',setcolor(selectcolor(i)));
    % plot mean and std as error bar (experiment with misalignment)
    err = statistics_vector(:,2);
    errorbar(G(:,i),statistics_vector(:,1),err,'kx');
    xlabel(selectlabel(i));
    ylabel('P / W m^-^1');
    AX =legend('misalignment points','mean value','Location','southeast');
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',11)
    hold off;
%     
%         
    subplot(searchSpace_dim,trials+1,(i-1)*(trials+1) +5);
    hold on;
    plot(plot_sample10(:,i),plot_sample10(:,end),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
    err = statistics_vector(:,2);
    errorbar(G(:,i),statistics_vector10(:,1),err,'kx');
    xlabel(selectlabel(i));
    ylabel('P / W m^-^1');
    AX =legend('misalignment points','mean value','Location','southeast');
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',11)
    hold off;


    subplot(searchSpace_dim,trials+1,(i-1)*(trials+1) +4);
    hold on;
    plot(plot_sample20(:,i),plot_sample20(:,end),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
    err = statistics_vector(:,2);
    errorbar(G(:,i),statistics_vector20(:,1),err,'kx');
    xlabel(selectlabel(i));
    ylabel('P / W m^-^1');
    AX =legend('misalignment points','mean value','Location','southeast');
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',11)
    hold off;


    subplot(searchSpace_dim,trials+1,(i-1)*(trials+1) +3);
    hold on;
    plot(plot_sample50(:,i),plot_sample50(:,end),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
    err = statistics_vector(:,2);
    errorbar(G(:,i),statistics_vector50(:,1),err,'kx');
    xlabel(selectlabel(i));
    ylabel('P / W m^-^1');
    AX =legend('misalignment points','mean value','Location','southeast');
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',11)
    hold off;


    subplot(searchSpace_dim,trials+1,(i-1)*(trials+1) +2);
    hold on;
    plot(plot_sample80(:,i),plot_sample80(:,end),'o','Color',setcolor(selectcolor(i)));
% plot mean and std as error bar (experiment with misalignment)
    err = statistics_vector(:,2);
    errorbar(G(:,i),statistics_vector80(:,1),err,'kx');
    xlabel(selectlabel(i));
    ylabel('P / W m^-^1');
    AX =legend('misalignment points','mean value','Location','southeast');
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',11)
    hold off;

end

% Save plot to vector image .eps
hFig.PaperPositionMode = 'auto';
filename_Pplot = 'sample_comparison';
print('-dpng','-r300', [outpath filename_Pplot])
print('-depsc','-tiff','-r300', [outpath filename_Pplot])
%close(hFig);


hFig2 = figure(2);

hold on;
for i = 1:nGeomPoints
plot(samples,mean_matrix(i,:)-statistics_vector(i,1),'o');
xlabel('number of samples');
ylabel('mean error / W m^-^1');
axis([0 90 -inf inf]);
end
hold off;

% Save plot to vector image .eps
hFig2.PaperPositionMode = 'auto';
filename_Pplot = 'mean_error';
print('-dpng','-r300', [outpath filename_Pplot])
print('-depsc','-tiff','-r300', [outpath filename_Pplot])
%close(hFig2);

hFig3 = figure(3);

hold on;
for i = 1:nGeomPoints
plot(samples,mean_matrix(i,:));
xlabel('number of samples');
ylabel('mean power / W m^-^1');
axis([0 90 -inf inf]);
end
hold off;

% Save plot to vector image .eps
hFig3.PaperPositionMode = 'auto';
filename_Pplot = 'mean_power';
print('-dpng','-r300', [outpath filename_Pplot])
print('-depsc','-tiff','-r300', [outpath filename_Pplot])
%close(hFig3);


% %save the results of the experiment in a struct
% save([outpath outstruct_name], 'data');
