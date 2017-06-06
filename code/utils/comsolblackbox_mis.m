function [P,Iline_data] = comsolblackbox_mis(beta,taperx,yin,M)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 05, 2017
%
% Solve comsol model for a set of geometrical parameters and a number of
% misaligment points
% Input: 
% - geometrical parameters (beta,taperx,yin)
% - matrix M with misaligment points with row vector (x_mis, y_mis, alpha)
% Output: 
% - P is the integral of the light intentsity at the
% output face
% - modelpath is the path where the comsol model is stored
% - intensityfile is the filename of the intensity line plot. Intesity line
% - nMisPoints is the number of misalignment points 

% is calculated at the outputfacet
    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
%         infile = 'glass_feedthrough_model_sweep_intensity_line_655.mph'; 
        infile = 'glass_feedthrough_sweep_655.mph';
    else
        modelpath = '../';
%         infile = 'glass_feedthrough_model_sweep_intensity_line.mph';
        infile = 'glass_feedthrough_sweep.mph'; 
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([modelpath infile]);
    % set the name for the output intensity line file
    intensityfile = 'intensity_line_multiple.dat';
    
    % pass geometrical parameters to the COMSOL model
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
    % pass misalignment parameters to the COMSOL model as a parametric sweep
    model.study('std1').feature('param').set('plistarr', {sprintf('%f ' ,...
        M(:,1)),sprintf('%f ' , M(:,2)),sprintf('%f ' , M(:,3))});
    model.study('std1').feature('param').set('pname', {'x_mis' 'y_mis' 'alpha'});
    model.study('std1').feature('param').set('punit', {'um' 'um' 'deg'});

    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl1');
    % extract the power from the accumulated probe table
    P = tabl.data(:,end); % units: W/m
    % export the intensity line data
    model.result().export('plot1').set('plotgroup', 'pg5');
    model.result().export('plot1').set('plot', 'lngr1');
    model.result().export('plot1').set('filename', intensityfile);
    model.result().export('plot1').run();
    % load the data extracted from the model
    Iline_data = load([modelpath intensityfile]);
    
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
       
end 
    