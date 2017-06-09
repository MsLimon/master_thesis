% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 01, 2017 

% add path to utils
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');

% set to true to change the figure appearance to print the image
print_pic = true;

%load the Iline_data
nMisPoints = 4;
Iline_data = load('intensity_line_multiple.dat');
weight_type = 'gaussian';
norm_type = 'euclidean';
s = symmetry(nMisPoints,Iline_data,'weights',weight_type,'norm',norm_type);
% figure1 = figure;
% plot(s,'+');
mean_s = mean(s)
median_s = median(s)
% s = symmetry(nMisPoints,Iline_data);
mean_type = 'mean';
k = skew(nMisPoints,Iline_data,'mu',mean_type);
mean_k = mean(abs(k))
median_k = median(abs(k))
% figure2 = figure;
% plot(k,'+');
% reshape Iline_data
Iline_data = reshapeI(Iline_data,nMisPoints);
% Create figure
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
x = Iline_data(:,i);
f = Iline_data(:,nMisPoints+i);  %unit: W/m^2
% change units to mW/mm^2
f = f * 1e-3; %unit: mW/mm^2
legendname = sprintf('s2=%0.5g,',k(i));
% legendname = sprintf('s1=%0.5g, s2=%0.5g',s(i),k(i));
plot(x,f,'DisplayName',legendname,'LineWidth',linewidth);
hold on
end
hold off
LEG=legend('show');
xlabel('Arc length / um');
ylabel('I / mW mm^-^2');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size)

if print_pic == true
    % save the figure to a png file
    % the file name
    picname = ['symmetry','_w_',weight_type,'_n_',norm_type,'_m_',mean_type];
    print(figure3,picname,'-r300','-dpng')
end

 