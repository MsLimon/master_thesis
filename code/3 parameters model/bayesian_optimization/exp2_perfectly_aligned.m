% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 08, 2017

% Bayesian optimization on geometrical space without misalignment. Parameter space
% is (beta, taper_x, y_in)

% Important script parameters:
% - maxTime : specify walltime for the termination condition of the optimizer 

% dependencies : utils folder

% TODO - save the generated plots

if isunix == 1
    % add path to utils
    addpath('~/utils');
    system_command = sprintf('comsol mphserver -tmpdir %s -autosave off &',MY_TMPDIR);
    system(system_command);
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = date2sec(0,12,0,0); % date2sec(days,hours,minutes,seconds)
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
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
beta = optimizableVariable('beta',[0,0.0652]); %unit: radians
taperx = optimizableVariable('taperx',[200,230]); %unit: micrometers
yin = optimizableVariable('yin',[5,20]); %unit: micrometers

import com.comsol.model.*
import com.comsol.model.util.*
    
try
    % specify logfile name
    logfile = 'logfile_exp2.txt';
    % start logfile
    ModelUtil.showProgress(logfile);
    % create a handle for the objective function
    fun = @(x)comsolblackbox(x.beta,x.taperx,x.yin,'objective','power');
    % call bayesian optimization and store the results
    results = bayesopt(fun,[beta,taperx,yin],'Verbose',1,...
        'IsObjectiveDeterministic',true,...
        'NumCoupledConstraints',2,...
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


    