% TODO - draw arrow for propagation direction
%      - draw axis orientation
%      - set figure size
%      - save image for given size with high quality

% select number of point plots
n = 100;
num_i = 20;
div = n / num_i;
x = linspace(0,5*pi,n);
i = x(1:div:end);
y = sin(x);
zeroes = zeros(1,n);
z0_quiver = zeroes(1:div:end);
z = sin(x);
z_quiver = z(1:div:end);

%Then plot them
figure
hold on
view(3);
plot3(x,zeroes,z)
q=quiver3(i,z0_quiver,z0_quiver,z0_quiver,z0_quiver,z_quiver)
q.MaxHeadSize = 4;
q.AutoScaleFactor = 0.3;
%q.ShowArrowHead = 'off';
plot3(x,y,zeroes)
q2=quiver3(i,z0_quiver,z0_quiver,z0_quiver,z_quiver,z0_quiver)
q2.MaxHeadSize = 4;
q2.AutoScaleFactor = 0.3;
%q2.ShowArrowHead = 'off';
xlabel('x');
ylabel('y');
zlabel('z');
lims= axis;
plot3(lims(1:2),[0 0],[0 0],'k--') % for x-axis
plot3([0 0],lims(3:4),[0 0],'k--')
plot3([0 0],[0 0],lims(5:6),'k--')
ax = gca;
ax.YDir = 'reverse';

hold off