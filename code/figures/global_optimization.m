% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 18, 2017

% Create a matlab figure depicting a surface with several minima 
% surface is z =3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... 
%    - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... 
%    - 1/3*exp(-(x+1).^2 - y.^2)

% Create figure
figure1 = figure;
colormap(autumn);

% Create axes with a handle
axes1 = axes('Parent',figure1);
% create a handle for the axis
%axes1 = gca;
hold(axes1,'on');

% change viewing angle
%view(axes1,[-34.7 31.6]);
view(axes1,[-47.1 12.4]);
xlabel('x');
ylabel('y');
zlabel('f(x,y)');
% remove the default axis
%set(gca,'visible','off');

% select figure size
f_width = 800;
f_height = 700;
figure1.Position = [100, 100, f_width, f_height];


[X,Y,Z] = peaks(25);
CO(:,:,1) = zeros(25); % red
CO(:,:,2) = ones(25).*linspace(0.5,0.6,25); % green
CO(:,:,3) = ones(25).*linspace(0,1,25); % blue
%surf(X,Y,Z,CO)
surf(X,Y,Z)

% save the figure to a png file
print(figure1,'global_optimization3c','-r300','-dpng')
print(figure1,'global_optimization3c','-depsc','-tiff','-r300')