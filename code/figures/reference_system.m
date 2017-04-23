% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% select figure size
f_width =400;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];

% create a handle for the axis
ax = gca;
% reverse the direction of the y dimension
ax.YDir = 'reverse';
% remove the default axis
set(gca,'visible','off');

hold on

% set the line width of the arrows
linewidth = 2.5;
% set the view
view(axes1,[9.70000000000003 27.6]);
% set the origin of the reference system
x_coord = 0;
y_coord = 0;
z_coord = 0;

% set the properties of the arrows
arrow_autoscale = 0.5;
arrow_lenght = 5;

% plot the arrows

% x axis
q4=quiver3(x_coord,y_coord,z_coord,arrow_lenght,0,0,'k','LineWidth',linewidth);
q4.MaxHeadSize = 3*arrow_autoscale;
q4.AutoScaleFactor = 0.3;
% y axis
%q.ShowArrowHead = 'off';
ax.ColorOrderIndex = 4;
q5=quiver3(x_coord,y_coord,z_coord,0,arrow_lenght,0,'LineWidth',linewidth);
q5.MaxHeadSize = 5*arrow_autoscale;
q5.AutoScaleFactor = 0.25;
% z axis
ax.ColorOrderIndex = 1;
q6=quiver3(x_coord,y_coord,z_coord,0,0,arrow_lenght,'LineWidth',linewidth);
q6.MaxHeadSize = 3*arrow_autoscale;
q6.AutoScaleFactor = 0.17;
hold off
% save the figure to a png file
print(figure1,'axis','-r200','-dpng')