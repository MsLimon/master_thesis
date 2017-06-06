function [P,Iline_data] = comsolblackbox2(beta,taperx,yin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 08, 2017
%
% Solve comsol model for a set of geometrical parameters
% Input: geometrical parameters (beta,taperx,yin)
% Output: 
% - P, where P is the integral of the light intentsity at the
% output face
% - Iline_data is a matrix containing the data of the intensity line at the
% output facet of the lens. The first column contains the arc lenght of the
% taper (in um) and the second column contains the corresponding intesitty 
% (in W m^-^2)

    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        infile = 'glass_feedthrough_655.mph';
    else
        modelpath = '../';
        infile = 'glass_feedthrough.mph';
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