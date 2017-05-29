% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 10, 2017

% Bayesian optimization on geometrical space without misalignment. Parameter space
% is (beta, taper_x, y_in,D0,w)

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
    system_command = sprintf('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver -tmpdir %s -autosave off &',MY_TMPDIR);
    system(system_command);
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = date2sec(0,20,0,0); % date2sec(days,hours,minutes,seconds)
    % set the minimum element size. in the cluster the 655nm wavelenght
    % is used therefore:
    h_max = 1.0917e-1; %unit: micrometers
    pause(10);
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = 500;
    h_max = 2 / 6; %unit: micrometers
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
D0 = optimizableVariable('D0',[h_max,20]); %unit: micrometers
w = optimizableVariable('w',[0.1,5]); % unitless

try
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    % specify logfile name
    logfile = 'logfile_exp6.txt';
    % start logfile
    ModelUtil.showProgress(logfile);
    % create a handle for the objective function
    fun = @(x)lensmodelair(x.beta,x.taperx,x.yin,x.D0,x.w);
    % call bayesian optimization and store the results
    results = bayesopt(fun,[beta,taperx,yin,D0,w],'Verbose',1,...
        'IsObjectiveDeterministic',true,...
        'MaxTime',maxTime,... % set walltime
        'PlotFcn',[],...
        'MaxObjectiveEvaluations',100,...
        'AcquisitionFunctionName','expected-improvement-plus',...
        'OutputFcn',{@saveToFile}) % save intermediate results into a file
    
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end


    