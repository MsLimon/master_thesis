% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: July 09, 2017

% Bayesian optimization on geometrical space with misalignment. Parameter space
% is (beta, y_out)

% Important script parameters:
% - maxTime : specify walltime for the termination condition of the optimizer 

% dependencies : utils folder

if isunix == 1
    % add path to utils
    resultspath = '';
    addpath('~/utils');
    system_command = sprintf('comsol mphserver -tmpdir %s -autosave off &',MY_TMPDIR);
    system(system_command);
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = date2sec(0,12,0,0); % date2sec(days,hours,minutes,seconds)
    
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % add results path
    resultspath = '';
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = 60;
end

mphstart();
% make the random generator different every time that matlab starts.
% This affects the intialization of bayesopt
rng('shuffle');
% save the current random generator settings in s:
%s = rng;

% define the optimization parameters
beta = optimizableVariable('beta',[0,0.0651]); %unit: radians
taperx = 200; %unit: micrometers (fixed)
yout = optimizableVariable('yout',[0.5,10]); %unit: micrometers


import com.comsol.model.*
import com.comsol.model.util.*
try
    % specify logfile name
    logfile = 'logfile_exp10.txt';
    % start logfile
    ModelUtil.showProgress(logfile);
    % create a handle for the objective function
    fun = @(x)invertedtaper(x.beta,taperx,x.yout,'objective','power');
    % call bayesian optimization and store the results
    results = bayesopt(fun,[beta,yout],'Verbose',1,...
        'IsObjectiveDeterministic',true,...
        'NumCoupledConstraints',1,...
        'MaxObjectiveEvaluations',100,...
        'MaxTime',maxTime,... % set walltime
        'PlotFcn',[],...
        'AcquisitionFunctionName','expected-improvement-plus',...
        'OutputFcn',{@saveToFile,@outputfun2}) % save intermediate results into a file
    
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end

% % Collect the data from the bayesian optimization into a table
% % create a table that contains the points of the search space that have
% % been explored in bayesopt
% T =results.XTrace;
% % Create a new column with their corrending objective function values
% T.mean_P = results.ObjectiveTrace;
%     