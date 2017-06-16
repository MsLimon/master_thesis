function [objective, constraint] = comsolblackbox(beta,taperx,yin,varargin)
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

    p = inputParser;

    defaultObjective = 'power';
    validObjective = {'power','symmetry','skew','center','rmse','correlation','peak'};
    checkObjective = @(x)any(validatestring(x,validObjective));
    addParameter(p,'objective',defaultObjective,checkObjective);

    parse(p,varargin{:});

    objective_type = p.Results.objective; 
        import com.comsol.model.*
        import com.comsol.model.util.*

        % specify I_lowerBound
        I_lowerBound = 0; %units: mW/mm^2

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        outpath = '/home/fr/fr_fr/fr_mt155/Iline/';
        infile = 'glass_feedthrough_655.mph';
    else
        modelpath = '../';
        outpath = 'C:\Users\IMTEK\Documents\GitHub\master_thesis\code\3 parameters model\bayesian_optimization\results\';
        infile = 'glass_feedthrough.mph';
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([modelpath infile]);
    % set the name for the output intensity line file
    intfile = 'intensity_line.dat';
    % pass geometrical parameters to the COMSOL model
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
    
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl2');
    % extract the power from the accumulated probe table
    P = tabl.data(end); % units: W/m
    % export intensity line
    model.result().export('plot1').set('plotgroup', 'pg5');
    model.result().export('plot1').set('plot', 'lngr1');
    model.result().export('plot1').set('filename',intfile);
    model.result().export('plot1').run();
    % load the data extracted from the model
    Iline_data = load([modelpath intfile]);
    % calculate features
    features = allFeatures(Iline_data); %(symmetry,skew,center,rmse,correlation,peak)
    features(:,2) = abs(features(:,2)); % take the absolute value of skew
    feat_mean = mean(features,1);
    
    switch objective_type
        case 'power'
        % objective is the mean light power
        P_mean = mean(P);
        objective = -P_mean;
        case 'symmetry'
        s_mean = feat_mean(1);
        objective = s_mean;
        case 'skew'
        k_mean = feat_mean(2);
        objective = k_mean;
        case 'center'
        c_mean = feat_mean(3);
        objective = -c_mean;
        case 'rmse'
        r_mean = feat_mean(4);
        objective = r_mean;
        case 'correlation'
        corr_mean = feat_mean(5);
        objective = -corr_mean;
    end
    
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