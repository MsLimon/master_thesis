% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 04, 2017

% Script to test the extraction of the intensity profile at the output
% facet from a comsol model
j = 3;
Iline_data = data(j).Iline;
M = data(j).misalignment;
[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;
% Create figure
fig = figure;

% select figure size
f_width = 900;
f_height = 600;
fig.Position = [100, 100, f_width, f_height];
%select line width of the plot lines
linewidth = 2;
font_size = 24;
set(gca,'fontsize',font_size,'LineWidth',linewidth);
hold on
for i = 1:30:nMisPoints
    legendname = sprintf('x_{mis}=%0.3g, y_{mis}=%0.3g, alpha=%0.3g',M(i,1),M(i,2),M(i,3));
    %plot(Iline_data(:,i),Iline_data(:,i+nMisPoints),'DisplayName',legendname);
    plot(Iline_data(:,(2*i)-1),Iline_data(:,2*i),'LineWidth',linewidth,'DisplayName',legendname);
    %plot(Iline_data(:,(2*i)-1),Iline_data(:,2*i));
end
xlim([0 6]);
% legend('show','Location', 'northeastoutside');
% legend('show','Location', 'Best');
xlabel('Output facet length / um');
ylabel('I / W m^-^2');
hold off

% adapt file separator to the operating system
f = filesep;

fig.PaperPositionMode = 'auto';

picname = 'intensity_profiles'

print('-dpng','-r300', ['.'  f picname])
print('-depsc','-tiff','-r300', ['.' f picname])
close(fig);

