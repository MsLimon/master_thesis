% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 03, 2017

% Bayesian optimization on geometrical space without misalignment. Parameter space
% is (beta, taper_x, y_in)

% Important script parameters:
% - maxTime : specify walltime for the termination condition of the optimizer 
% - infile (in objective function) : file containining the model
% - I_lowerBound (in objective function) : intensity lower bound

% TODO - save the generated plots

if isunix == 1
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = date2sec(0,5,0,0); % date2sec(days,hours,minutes,seconds)
else
   addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
    % set termination condition to walltime for bayesopt. in seconds
    maxTime = 100;
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


try
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    % specify logfile name
    logfile = 'logfile_exp2.txt';
    % start logfile
    ModelUtil.showProgress([logfile]);
    % create a handle for the objective function
    fun = @(x)comsolblackbox(x.beta,x.taperx,x.yin);
    % call bayesian optimization and store the results
    results = bayesopt(fun,[beta,taperx,yin],'Verbose',1,...
        'IsObjectiveDeterministic',true,...
        'NumCoupledConstraints',1,...
        'MaxTime',maxTime,... % set walltime
        'AcquisitionFunctionName','expected-improvement-plus',...
        'OutputFcn',{@saveToFile}) % save intermediate results into a file
    
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end

function [objective, constraint] = comsolblackbox(beta,taperx,yin)
    import com.comsol.model.*
    import com.comsol.model.util.*
   
    % specify I_lowerBound
    I_lowerBound = 200; %units: mW/mm^2

    if isunix == 1
        % set the name of the input model file
        infile = 'glass_feedthrough_model_655_6epw.mph';
    else
        infile = 'glass_feedthrough_model.mph';
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload(infile);

    % pass geometrical parameters to the COMSOL model
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl2');
    % extract the power from the accumulated probe table
    P = tabl.data(2); % units: W/m
    % the objective is the negative power because the algorithm minimizes
    % the objective and we want to maximaze
    objective = - P;
    % --calculate the intensity --
    % change the dimensions of yin from microns to meter
    yin_m = yin*1e-6; %units: meters
    % calculate average intensity
    I = P / yin_m; %units: W/m^2
    % change intensity units to mW/mm^2
    I = I * 1e-3; %units: mW/mm^2
    
    % positive values of the contraint means that the constraint is not
    % satisfied. Here the constraint is satisfied if the intensity is
    % greater than I_lowerBound
    
    % set the constraint
    constraint = I_lowerBound - I;
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
    
end 
    