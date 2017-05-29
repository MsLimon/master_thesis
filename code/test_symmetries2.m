% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 23, 2017 

% add path to utils
addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');

% set to true to change the figure appearance to print the image
print_pic = false;

%load the Iline_data
nMisPoints = 4;
Iline_data = load('intensity_line_multiple.dat');
s = symmetry(nMisPoints,Iline_data,'weights','linear');
k = skew(nMisPoints,Iline_data);
[n,m] = size(Iline_data);
Iline_data = Iline_data(:);
Iline_data = reshape(Iline_data,[n/nMisPoints,nMisPoints*m]);
% Create figure
figure1 = figure;

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

figure1.Position = [100, 100, f_width, f_height];

for i = 1:nMisPoints
x = Iline_data(:,i);
f = Iline_data(:,nMisPoints+i);

legendname = sprintf('s1=%0.5g, s2=%0.5g',s(i),k(i));
plot(x,f,'DisplayName',legendname,'LineWidth',linewidth);
hold on
end
hold off
LEG=legend('show');
xlabel('Arc length / um');
ylabel('I / W m^-^2');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size)

if print_pic == true
    % save the figure to a png file
    print(figure1,'symmetry_measure_L2','-r300','-dpng')
end

 