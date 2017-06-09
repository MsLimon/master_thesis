function [objective] = lensmodel_bayes(beta,taperx,yin,D0,w)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 08, 2017
%
% Solve comsol model for a set of geometrical parameters 
% Input: 
% - geometrical parameters (beta,taperx,yin,D0,w)
% Output: 
% - objective = -P, where P is the integral of the light intentsity at the
% output face
% Important script parameters:
% - infile (in objective function) : name of the file containining the model

% is calculated at the outputfacet
    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        infile = '5parameters_model_655.mph'; % TODO - change file
    else
        modelpath = '../';
        infile = '5parameters_model.mph';
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([modelpath infile]);
    
    % pass geometrical parameters to the COMSOL model
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
    model.param.set('D0_x', [num2str(D0),'[um]']);
    model.param.set('D0_w', num2str(w), 'weight of the Control point of the Bezier Curve describing the front lens');

    
    % calculate the coordinates of the tip of the bezier curve
    lens_thickness = bezier_curve(0,D0,0,w,0.5); % control points (P0,P1,P2) at the center t=0.5
    model.param.set('lens_thickness', [num2str(lens_thickness),'[um]']);
    
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl2');
    % extract the power from the accumulated probe table
    P = tabl.data(end); % units: W/m
     % the objective is the negative power because the algorithm minimizes
    % the objective and we want to maximaze
    objective = - P;
    
    % Save the model
    % mphsave(model,'output.mph');
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
       
end 