% set to true to change the figure appearance to print the image
print_pic = false;

fig = figure;

if print_pic == true
    % select figure size
    f_width = 1400;
    f_height = 700;
    %select line width of the plot lines
    linewidth = 2;
    font_size = 24;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end

fig.Position = [100, 100, f_width, f_height];

n = length(results);
for i = 1:n
    if i==8
    I =results(i).Iline;
    dispname = sprintf('%d',i);
    % change units to mW/mm^2
    I(:,2) = I(:,2) * 1e-3; %unit: mW/mm^2
    plot(I(:,1),I(:,2),'Color',[0.7300, 0.2700, 0.6300],'DisplayName',dispname,'LineWidth',linewidth);
    else
    I =results(i).Iline;
    dispname = sprintf('%d',i);
        % change units to mW/mm^2
    I(:,2) = I(:,2) * 1e-3; %unit: mW/mm^2
    plot(I(:,1),I(:,2),'DisplayName',dispname,'LineWidth',linewidth);
    hold on;
    end
end
hold off;
%legend('show');

LEG=legend('show','Location','northeast');
v = get(LEG,'title');
set(v,'string','N');
xlabel('Output facet length / um');
ylabel('I / mW mm^-^2');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size,'LineWidth',linewidth);

% save the results to an ASCII-delimited text file
R = dlmread('mesh_study_results.txt');
% -------plot results------
% get the power corresponding to the solution with highest resolution
P_accurate = R(end,end);
% subtact the most accurate solution to the results to see if the solutions
% select figure size
f_width = 1400;
f_height = 700;
%select line width of the plot lines
linewidth = 2;
font_size = 24;
% converge to this value
plot(R(:,1),(R(:,2)-P_accurate)/P_accurate,'LineWidth',linewidth);
xlabel('N');
ylabel('Relative error');
% Save plot to jpeg file

fig = gcf;
fig.Position = [100, 100, f_width, f_height];
set(gca,'FontSize',font_size,'LineWidth',linewidth);

picname = 'meshResolutionStudy';
%saveas(fig,[outpath picname],'jpeg');
print(fig, picname,'-r300','-dpng')


if print_pic == true
    % save the figure to a png file
    % the file name
    picname = ['mesh_resolution_Iline'];
    print(fig,picname,'-r300','-dpng')
end
