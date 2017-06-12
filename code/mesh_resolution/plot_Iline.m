% set to true to change the figure appearance to print the image
print_pic = true;

fig = figure;

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

fig.Position = [100, 100, f_width, f_height];

n = length(results);
for i = 5:n
    I =results(i).Iline;
    dispname = sprintf('number of elements = %d',i);
    plot(I(:,1),I(:,2),'DisplayName',dispname,'LineWidth',linewidth);
    hold on;
end
hold off;
legend('show');

LEG=legend('show');
xlabel('Arc length / um');
ylabel('I / mW mm^-^2');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size)

if print_pic == true
    % save the figure to a png file
    % the file name
    picname = ['mesh_resolution_Iline_5678'];
    print(fig,picname,'-r300','-dpng')
end
