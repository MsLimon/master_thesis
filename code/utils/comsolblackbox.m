function [objective, constraint] = comsolblackbox(beta,taperx,yin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 05, 2017
%
% Solve comsol model for a set of geometrical parameters
% Input: geometrical parameters (beta,taperx,yin)
% Output: 
% - objective = -P, where P is the integral of the light intentsity at the
% output face
% - constraint gives a negative number if the average intensity at the
% output facet is more that I_lowerBound (this is used in bayeopt)
% Important script parameters:
% - infile (in objective function) : name of the file containining the model
% - I_lowerBound (in objective function) : intensity lower bound

    import com.comsol.model.*
    import com.comsol.model.util.*
   
    % specify I_lowerBound
    I_lowerBound = 0; %units: mW/mm^2

    if isunix == 1
        % set the name of the input model file
        inpath = '';
        infile = 'glass_feedthrough_655.mph';
    else
        inpath = '../';
        infile = 'glass_feedthrough.mph';
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([inpath infile]);

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