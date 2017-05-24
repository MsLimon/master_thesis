% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 23, 2017 

%load the Iline_data
nMisPoints = 4;
Iline_data = load('intensity_line_multiple.dat');
[n,m] = size(Iline_data);
Iline_data = Iline_data(:);
Iline_data = reshape(Iline_data,[n/nMisPoints,nMisPoints*m]);
% Create figure
figure1 = figure;

% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];

m = zeros(1,nMisPoints);

for i = 1:nMisPoints
x = Iline_data(:,i);
f = Iline_data(:,nMisPoints+i);
f_plus = 0.5 * (f + flip(f)); 
f_minus = 0.5 * (f - flip(f)); 
m(i) = norm(f_plus) / (norm(f_plus) + norm(f_minus));
legendname = sprintf('m=%0.5g',m(i));
plot(x,f,'DisplayName',legendname);
hold on
end
hold off
legend('show')
xlabel('Arc length / um');
ylabel('I / W m^-^2');

 