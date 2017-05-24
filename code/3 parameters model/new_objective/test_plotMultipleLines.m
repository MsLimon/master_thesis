% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 04, 2017

% Script to test the extraction of the intensity profile at the output
% facet from a comsol model
num_param_sweeps = 4;
Iline_data = load('../intensity_line_multiple.dat');
[n,m] = size(Iline_data);
Iline_data = Iline_data(:);
Iline_data = reshape(Iline_data,[n/num_param_sweeps,num_param_sweeps*m]);
% Create figure
figure1 = figure;

% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
plot(Iline_data(:,1),Iline_data(:,5),Iline_data(:,2),Iline_data(:,6),Iline_data(:,3),Iline_data(:,7),Iline_data(:,4),Iline_data(:,8))
xlabel('Arc length / um');
ylabel('I / W m^-^2');

