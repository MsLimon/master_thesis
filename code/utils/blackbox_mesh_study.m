function [P,Iline_data] = blackbox_mesh_study(beta,taperx,yin,numElements)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 06, 2017
%
% Solve comsol model for a set of geometrical parameters and a given numer
% of elements per wavelength
% Input: 
% - geometrical parameters (beta,taperx,yin)
% - numElements is the number of elements per wavelength that are used to
% mesh the feedthrough
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
        modelpath = './';
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
    model.param.set('elements_per_wavelenght', num2str(numElements));
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    % model.result.table.tags
    tabl = mphtable(model,'tbl2');
    % extract the power from the accumulated probe table
    P = tabl.data(end); % units: W/m
    % export the intensity line data
    model.result().export('plot1').set('plotgroup', 'pg5');
    model.result().export('plot1').set('plot', 'lngr1');
    model.result().export('plot1').set('filename',intensityfile);
    model.result().export('plot1').run();
    % load the data extracted from the model
    Iline_data = load([modelpath intensityfile]);
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
        
end 