% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 01, 2017 

% add path to utils
if ispc == true
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
elseif ismac == true
addpath('/Users/lime/master_thesis/code/utils');
end

% set to true to change the figure appearance to print the image
plot_all = true;
print_pic = false;

%load the Iline_data

data_i= 23;
exp_num = 1;
Iline_data = data(data_i).Iline;
[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

weight_type = 'gaussian';
norm_type = 'euclidean';
s = symmetry(Iline_data,'weights',weight_type,'norm',norm_type);
% figure1 = figure;
% plot(s,'+');
mean_s = mean(s);
median_s = median(s);
% s = symmetry(nMisPoints,Iline_data);
mean_type = 'mean';
k = skew(Iline_data,'mu',mean_type);
mean_k = mean(abs(k));
median_k = median(abs(k));

%calculate the weighted integral from the Iline_data
c = centered(Iline_data,'alpha',2.5);

% calculate similarity
error = rmse(Iline_data);
similarity = centralCorr(Iline_data);
%features = allFeatures(Iline_data);

% extract two different Ilines i and j and plot them
i = 1; % perfectly aligned data
j = 22;
x1 = Iline_data(:,(2*i)-1); 
f1 = Iline_data(:,2*i)*1e-3; 
x2 = Iline_data(:,(2*j)-1);
f2 = Iline_data(:,2*j)*1e-3;

C = normxcorr2(f1,f2);
midrow = C(ceil(end/2), :);

diff = (f2-f1);
RMSE = sqrt((1/num_points)*sum((diff).^2));
f1f2 = [f1;f2];
max_f = max(f1f2);
min_f = min(f1f2);
NRMSE = RMSE/(max_f - min_f);

figure1 = figure;

plot(x1,f1);
hold on
plot(x2,f2);
hold off
xlabel('Output facet length / um');
ylabel('I / mW mm^-^2');


if plot_all == true
figure3 = figure;

if print_pic == true
    % select figure size
    f_width = 1400;
    f_height = 700;
    %select line width of the plot lines
    linewidth = 1.5;
    font_size = 14;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

figure3.Position = [100, 100, f_width, f_height];

for i = 1:nMisPoints
x = Iline_data(:,(2*i)-1);
f = Iline_data(:,2*i);  %unit: W/m^2
% change units to mW/mm^2
f = f * 1e-3; %unit: mW/mm^2
legendname = sprintf('s2=%0.5g,',k(i));
% legendname = sprintf('s1=%0.5g, s2=%0.5g',s(i),k(i));
plot(x,f,'DisplayName',legendname,'LineWidth',linewidth);
hold on
end
hold off
% LEG=legend('show');
xlabel('Arc length / um');
ylabel('I / mW mm^-^2');
%xlim([0 50]);
%ylim([0 250]);
% set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size)

if print_pic == true
    % save the figure to a png file
    % the file name
%     picname = ['symmetry','_w_',weight_type,'_n_',norm_type,'_m_',mean_type];
    picname = ['exp',num2str(exp_num),'_iteration_',num2str(data_i)];
    print(figure3,picname,'-r300','-dpng')
end
end
 