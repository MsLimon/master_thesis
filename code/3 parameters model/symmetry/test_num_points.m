% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 01, 2017

% Take a geometry with good symmetry and test how the average symmetry
% changes for different number of misalignment points

% dependencies : utils folder

% TODO - Store the I_line results so you don't have to run it again and you
% can modify the plot!!

% set to true to change the figure appearance to print the image
print_pic = true;

if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli');
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system_command = sprintf('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver </dev/null >mphserver.out 2>mphserver.err -nn %d -nnhost 1 -np %d -f %s -mpiarg -rmk -mpiarg pbs -mpifabrics dapl -tmpdir %s -autosave off &',NN,NP,PBS_HOSTFILE,MY_TMPDIR);
    system(system_command);
    pause(30);
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

% save the logfile
ModelUtil.showProgress('logfile_Iline.txt');
outstruct_name = 'test_num_points.mat';
reuse_misalignment = false;
if isunix == 1
    outpath = '';
else
    outpath = './results/';
    ModelUtil.showProgress(true);
end
% generate misalignment points
values = [4,10,20,40];
n_values = length(values);
mean_s = zeros(1,n_values);
median_s = zeros(1,n_values);
mean_k = zeros(1,n_values);
median_k = zeros(1,n_values);

for i = 1:n_values
    
nMisPoints = values(i);
M = generatePoints(nMisPoints);
[nMisPoints,misalignment_dim] = size(M);
% preallocate results matrix R. Each row of R contain a set of
% misalignment parameters and the power obtained when running the model with
% those parameters, and the symmetry measure associated to the respective
% intensity line. R = [M k s P]
R = zeros(nMisPoints,misalignment_dim+3);
R(:,1:end-3) = M;   

% call the comsolblackbox_mis function
current_geometry = [0.0026231,204.26,18.997];
G = current_geometry;
[P,Iline_data] = comsolblackbox_mis(G(1),G(2),G(3),M);
% store the extracted values in the results matrix
R(:,end) = P;
% evaluate the symmetry
weight_type = 'gaussian';
norm_type = 'euclidean';
s = symmetry(Iline_data,'weights',weight_type,'norm',norm_type);
R(:,end-1) = s;
mean_s(i) = mean(s);
median_s(i) = median(s);
mean_type = 'lhalf';
k = skew(Iline_data,'mu',mean_type);
R(:,end-2) = k;
mean_k(i) = mean(abs(k));
median_k(i) = median(abs(k));
% store the data
data(i) = struct('geometry',current_geometry,'misalignment', M,'results',R,'Iline',Iline_data);
% save the results to a struct
if i==1
    save([outpath outstruct_name], 'data');
else
    save([outpath outstruct_name], 'data','-append');
end

%plot the intensity profiles
% Create figure
figure3 = figure;
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
figure3.Position = [100, 100, f_width, f_height];

% reshape Iline_data
%Iline_data = reshapeI(Iline_data,nMisPoints);

for i = 1:nMisPoints
x = Iline_data(:,(2*i)-1);
f = Iline_data(:,2*i);  %unit: W/m^2
% change units to mW/mm^2
f = f * 1e-3; %unit: mW/mm^2
legendname = sprintf('s1=%0.5g, s2=%0.5g',s(i),k(i));
plot(x,f,'DisplayName',legendname,'LineWidth',linewidth);
hold on
end
hold off
LEG=legend('show');
xlabel('Arc length / um');
ylabel('I / mW mm^-^2');
set(LEG,'FontSize',font_size);
set(gca,'fontsize',font_size)
if print_pic == true
    % save the figure to a png file
    % the file name
    picname = [[outpath 'good_symmetry_nMisPoints_'],num2str(nMisPoints)];
    print(figure3,picname,'-r300','-dpng')
end
end
ModelUtil.disconnect;
