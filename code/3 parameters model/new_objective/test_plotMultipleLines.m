% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 04, 2017

% Script to test the extraction of the intensity profile at the output
% facet from a comsol model
Iline_data = data(3).Iline;
[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;
% Create figure
fig = figure;

% select figure size
f_width = 700;
f_height = 400;
fig.Position = [100, 100, f_width, f_height];
hold on
for i = 1:nMisPoints
    %legendname = sprintf('x_{mis}=%0.5g, y_{mis}=%0.5g, alpha=%0.5g, s=%0.5g',M(i,1),M(i,2),M(i,3),s(i));
    %plot(Iline_data(:,i),Iline_data(:,i+nMisPoints),'DisplayName',legendname);
    plot(Iline_data(:,(2*i)-1),Iline_data(:,2*i));
end
%legend('show','Location', 'Best');
xlabel('Arc length / um');
ylabel('I / W m^-^2');
hold off

