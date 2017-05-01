% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: April 30, 2017

% Create a matlab figure depicting a plane wave

% Create figure
figure1 = figure;

% Create axes with a handle
axes1 = axes('Parent',figure1);
% create a handle for the axis
%axes1 = gca;
hold(axes1,'on');

% reverse the direction of the y dimension
axes1.YDir = 'reverse';
%axes1.XDir = 'reverse';
% remove the default axis
set(gca,'visible','off');
% change viewing angle
view(3);
%view(axes1,[9.70000000000003 27.6]);

% select figure size
f_width = 1000;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];

%plot the plane
[Z,Y] = meshgrid(-5:5:-5:5);
X = zeros(size(Z));
X1 = X - 0.2;
X2 = X - 0.4;
%Z = sin(X) + cos(Y);
surf(X,Y,Z,'Parent',axes1,'FaceColor',[0.313725501298904 0.313725501298904 0.313725501298904],...
    'EdgeColor',[0.24705882370472 0.24705882370472 0.24705882370472])

% plot the axis on the origin
lims= axis;
plot3(lims(1:2),[0 0],[0 0],'k-'); % for x-axis
plot3([0 0],lims(3:4)*2.5,[0 0],'k-');
plot3([0 0],[0 0],lims(5:6)*1.5,'k-');

% plot other planes
surf(X1,Y,Z,'Parent',axes1,...
    'FaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
    'EdgeColor',[0.313725501298904 0.313725501298904 0.313725501298904])
surf(X2,Y,Z,'Parent',axes1,...
    'FaceColor',[0.831372559070587 0.815686285495758 0.7843137383461],...
    'EdgeColor',[0.313725501298904 0.313725501298904 0.313725501298904]) 
% set axis labels 
xlabel('x');
ylabel('y');
zlabel('z');

% set the view
%view(axes1,[39.3 8.4]);
view(axes1,[23.7 7.59999999999998]);
