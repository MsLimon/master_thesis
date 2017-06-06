% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 04, 2017

% Plot the intensity profile of the simulation outcome of a tapered waveguide
% for 10 different misalignments

% dependencies : utils folder

if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli');
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli');
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*

% generate misalignment points
nMisPoints = 4;
M = generatePoints(nMisPoints);

% call the comsolblackbox_mis function
[P1,Iline_data1] = test_comsol(0.06,60,20,M);
[P2,Iline_data2] = test_comsol(0,60,5,M);
ModelUtil.disconnect;

% separate the lines for each misalignment point
[n,m] = size(Iline_data1);
Iline_data1 = Iline_data1(:);
Iline_data1 = reshape(Iline_data1,[n/nMisPoints,nMisPoints*m]);

% Create figure
figure1 = figure(1);
hold on
% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
for i = 1:nMisPoints
    legendname = sprintf('x_{mis}=%0.5g, y_{mis}=%0.5g, alpha=%0.5g, P =%0.5g',M(i,1),M(i,2),M(i,3),P1(i));
    plot(Iline_data1(:,i),Iline_data1(:,i+nMisPoints),'DisplayName',legendname);
end
legend('show','Location', 'Best');
xlabel('Arc length / um');
ylabel('I / W m^-^2');
hold off

% separate the lines for each misalignment point
[n,m] = size(Iline_data2);
Iline_data2 = Iline_data2(:);
Iline_data2 = reshape(Iline_data2,[n/nMisPoints,nMisPoints*m]);

% Create figure
figure1 = figure(2);
hold on
% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
for i = 1:nMisPoints
    legendname = sprintf('x_{mis}=%0.5g, y_{mis}=%0.5g, alpha=%0.5g, P =%0.5g',M(i,1),M(i,2),M(i,3),P2(i));
    plot(Iline_data2(:,i),Iline_data2(:,i+nMisPoints),'DisplayName',legendname);
end
legend('show','Location', 'Best');
xlabel('Arc length / um');
ylabel('I / W m^-^2');
hold off

