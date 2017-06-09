% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 06, 2017
%
% Resolution refinement study. Parameter is: elements_per_wavelenght

if isunix == 1 % on the cluster
    % add path to utils
    addpath('~/utils');
    % Run script once the server is started or use the command below
    % Start the COMSOL server 
    system_command = sprintf('comsol mphserver </dev/null >mphserver.out 2>mphserver.err -tmpdir %s -autosave off &',MY_TMPDIR);
    system(system_command);
    pause(15);
else % on the local machine (Windows)
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli');
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*
try
if isunix == 1
    outpath = '';
else
    outpath = '.\results\';
    ModelUtil.showProgress(true);
end
%  save the log file
ModelUtil.showProgress('meshResolutionLog.txt');
outstruct_name = 'meshResolutionData.mat';

% set the range of values to be evaluated
elements_min = 1;
elements_max = 10;
% prealocate results matrix R.
elements = (elements_min:elements_max);
R = zeros(length(elements),2);
R(:,1:end-1) = elements;

% number of geomtrical parameter sets (number of random points)
nGeomPoints = 1;
% create random geometrical parameter matrix G. Each row of the matrix 
% contains a set of geometrical parameters (beta, taper_x, y_in)
G = generateGeom(nGeomPoints);
% preallocate data structure
results = struct('geometry',G,'numElements',0,'power',0,'Iline',[]);
% Evaluate the model for the specified resolutions 
i = 1; % initialize loop counter
for iElements = elements_min:elements_max
    [P,Iline_data] = blackbox_mesh_study(G(1),G(2),G(3),iElements);
    R(i,end) = P;
    results(i) = struct('geometry',G,'numElements',iElements,'power',P,'Iline',Iline_data);
    if i==1
        save([outpath outstruct_name], 'results');
    else
        save([outpath outstruct_name], 'results','-append');
    end
    i = i + 1;
end

% save the results to an ASCII-delimited text file
dlmwrite('mesh_study_results.txt',R);
% -------plot results------
% get the power corresponding to the solution with highest resolution
P_accurate = R(end,end);
% subtact the most accurate solution to the results to see if the solutions
% converge to this value
plot(R(:,1),R(:,2)-P_accurate);
xlabel('number of elements per wavelenght');
ylabel('Difference with most accurate solution');
% Save plot to jpeg file
fig = gcf;
set(gca,'FontSize',14);
picname = 'meshResolutionStudy';
saveas(fig,[outpath picname],'jpeg');
print(fig,[outpath picname],'-r300','-dpng')
close(fig);
ModelUtil.clear;
ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end