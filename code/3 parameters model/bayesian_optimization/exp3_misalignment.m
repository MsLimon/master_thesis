% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 15, 2017

% Bayesian optimization on geometrical space with misalignment. Parameter space
% is (beta, taper_x, y_in)

% Important script parameters:
% - maxTime : specify walltime for the termination condition of the optimizer 

% dependencies : utils folder


if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
%     system_command = sprintf('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver -f %s -tmpdir %s -autosave off &',PBS_HOSTFILE,TMPDIR);
    system_command = sprintf('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver -nn %d -nnhost 1 -np %d -f %s -mpiarg -rmk -mpiarg pbs -mpifabrics dapl -tmpdir %s -autosave off &',NN,NP,PBS_HOSTFILE,MY_TMPDIR);
    system(system_command);
    pause(30);
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = date2sec(0,12,0,0); % date2sec(days,hours,minutes,seconds)
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = 500;
end

mphstart();
% make the random generator different every time that matlab starts.
% This affects the intialization of bayesopt
rng('shuffle');
% save the current random generator settings in s:
%s = rng;

% define the optimization parameters
beta = optimizableVariable('beta',[0,0.0652]); %unit: radians
taperx = optimizableVariable('taperx',[200,230]); %unit: micrometers
yin = optimizableVariable('yin',[5,20]); %unit: micrometers

% dimension of the misalignment space
misalignment_dim = 3;
% number of misalignment points
nMisPoints = 4;
% % generate misalignment samples
M = generatePoints(nMisPoints);
% save misalignment matrix
dlmwrite('misalignment_points.txt', M);

try
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    % specify logfile name
    logfile = 'logfile_exp3.txt';
    % start logfile
    ModelUtil.showProgress(logfile);
    % create a handle for the objective function
    fun = @(x)simplemodel_mis(x.beta,x.taperx,x.yin,M);
    % call bayesian optimization and store the results
    results = bayesopt(fun,[beta,taperx,yin],'Verbose',1,...
        'IsObjectiveDeterministic',true,...
        'MaxTime',maxTime,... % set walltime
        'PlotFcn',[],...
        'AcquisitionFunctionName','expected-improvement-plus',...
        'OutputFcn',{@saveToFile,@outputfun}) % save intermediate results into a file
    
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end

% Collect the data from the bayesian optimization into a table
% create a table that contains the points of the search space that have
% been explored in bayesopt
T =results.XTrace;
% Create a new column with their corrending objective function values
T.mean_P = results.ObjectiveTrace;
    