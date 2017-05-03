% select number of point to plot
n = 100;
% select the number of arrows (number of points of x with arrows)
num_i = 20;
% magic trick to select the num_i points on x
div = n / num_i;
% create the x and i points to be plotted
x = linspace(0,3*pi,n);
i = x(1:div:end);
% write the function to be plotted
y = sin(x);
z = sin(x);
% take the only num_i points of x
z_quiver = z(1:div:end);
% create vector with zeros to plot the functions in one plane
zeroes = zeros(1,n);
% create a vector with num_i zeros (to plot the arrows)
z0_quiver = zeroes(1:div:end);

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% select figure size
f_width = 1000;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
% set autoscale for the arrows
autoscale = 0.495;

% create a handle for the axis
ax = gca;
% reverse the direction of the y dimension
ax.YDir = 'reverse';
% remove the default axis
set(gca,'visible','off');

hold on

%select line width for the arrows (the function is 0.7 times that value)
linewidth = 1.7;
% change viewing angle
view(axes1,[9.70000000000003 27.6]);

%plot the stuff

%plot electric field
color_ef= 1;
ax.ColorOrderIndex = color_ef;
plot3(x,zeroes,z,'-.','LineWidth',linewidth*0.7);
ax.ColorOrderIndex = color_ef;
q=quiver3(i,z0_quiver,z0_quiver,z0_quiver,z0_quiver,z_quiver,'LineWidth',linewidth);
q.MaxHeadSize = 0.2;
q.AutoScaleFactor = autoscale;
%q.ShowArrowHead = 'off';

%plot magnetic field
color_mf = 7;
ax.ColorOrderIndex = color_mf;
plot3(x,y,zeroes,'-.','LineWidth',linewidth*0.7);
ax.ColorOrderIndex = color_mf;
q2=quiver3(i,z0_quiver,z0_quiver,z0_quiver,z_quiver,z0_quiver,'LineWidth',linewidth);
q2.MaxHeadSize = 0.2;
q2.AutoScaleFactor = autoscale;
%q2.ShowArrowHead = 'off';

% set axis labels (this is actually useless)
xlabel('x');
ylabel('y');
zlabel('z');

% plot the axis on the origin
lims= axis;
plot3(lims(1:2),[0 0],[0 0],'k--'); % for x-axis
plot3([0 0],lims(3:4),[0 0],'k--');
plot3([0 0],[0 0],lims(5:6),'k--');

% plot the propagation vector
arrow_autoscale = 0.5;
arrow_lenght = 4;
q3=quiver3(x(end)+0.1,0,0,arrow_lenght,0,0,'k','LineWidth',linewidth);
q3.MaxHeadSize = 0.7;
q3.AutoScaleFactor = 0.6*arrow_autoscale;

% plot the axis indicator
% select the origin of the axis indicator
x_coord = x(end)+3;
y_coord = -0.2;
z_coord = 0;
% x axis
q4=quiver3(x_coord,y_coord,z_coord,arrow_lenght,0,0,'k','LineWidth',linewidth);
q4.MaxHeadSize = 3*arrow_autoscale;
q4.AutoScaleFactor = 0.3;
% y axis
ax.ColorOrderIndex = color_mf;
q5=quiver3(x_coord,y_coord,z_coord,0,arrow_lenght,0,'LineWidth',linewidth);
q5.MaxHeadSize = 5*arrow_autoscale;
q5.AutoScaleFactor = 0.25;
% z axis
ax.ColorOrderIndex = color_ef;
q6=quiver3(x_coord,y_coord,z_coord,0,0,arrow_lenght,'LineWidth',linewidth);
q6.MaxHeadSize = 3*arrow_autoscale;
q6.AutoScaleFactor = 0.17;
hold off
% save the figure to a png file
print(figure1,'1Dtransverse_wave','-r200','-dpng')
print(figure1,'1Dtransverse_wave','-depsc','-tiff','-r300')