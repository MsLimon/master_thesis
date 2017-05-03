% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: April 28, 2017

% Test comsolblackbox function
% 
if isunix == 1
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
else
   addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*

P1 = comsolblackbox(0,200,5)
P2 = comsolblackbox(0,200,10)

ModelUtil.disconnect;

function [P] = comsolblackbox(beta,taperx,yin)
    import com.comsol.model.*
    import com.comsol.model.util.*
    % ModelUtil.showProgress(true); %comment this line out when using the cluster
    % set the names of the input and output files
    infile = 'glass_feedthrough_model.mph';
    logfile = 'logfile_exp2.txt';

    if isunix == 1
    else
        ModelUtil.showProgress(true);
    end
    % save the logfile
    ModelUtil.showProgress([logfile]);
    % load the model
    model = mphload(infile);

    % pass all parameter sets to the COMSOL model, evaluate the power and
    % store it in the results matrix
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
    model.study('std1').run;
    tabl = mphtable(model,'tbl2');
    P = -tabl.data(2);

    ModelUtil.remove('model');
    ModelUtil.clear;    
    
end 
    
