% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 04, 2017

% Script to test the extraction of the intensity profile at the output
% facet from a comsol model

if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*

[P1,Iline_data] = comsolblackbox(0,200,5);
%[P2] = comsolblackbox(0,200,10)
ModelUtil.disconnect;

% Create figure
figure1 = figure;

% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
plot(Iline_data(:,1),Iline_data(:,2))
xlabel('Arc length / um');
ylabel('I / W m^-^2');

function [P,Iline_data] = comsolblackbox(beta,taperx,yin)
    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        infile = 'glass_feedthrough_model_655_6epw.mph';
    else
        modelpath = '../';
        infile = 'glass_feedthrough_model_intensity_line.mph';
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([modelpath infile]);
    
    % set the name for the output intensity line file
    intensityfile = 'intensity_line.dat';

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
    model.result().export('plot1').set('plotgroup', 'pg3');
    model.result().export('plot1').set('plot', 'lngr1');
    model.result().export('plot1').set('filename',intensityfile);
    model.result().export('plot1').run();
    % load the data extracted from the model
    Iline_data = load([modelpath intensityfile]);
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
    
end 
    