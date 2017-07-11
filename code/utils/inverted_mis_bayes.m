function[objective] = inverted_mis_bayes(beta,taperx,yout,M,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 24, 2017
%
% Solve comsol model for a set of geometrical parameters and a number of
% misaligment points
% Input: 
% - geometrical parameters (beta,taperx,yout)
% - matrix M with misaligment points with row vector (x_mis, y_mis, alpha)
% Options:
% -objective: choose the objective function
% Output: 
% - P is the average of the integral of the light intentsity at the
% output facet

    p = inputParser;

    defaultObjective = 'power';
    validObjective = {'power','symmetry','skew','center','rmse','correlation'};
    checkObjective = @(x)any(validatestring(x,validObjective));
    addParameter(p,'objective',defaultObjective,checkObjective);

    parse(p,varargin{:});

    objective_type = p.Results.objective; 


    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        outpath = '/home/fr/fr_fr/fr_mt155/Iline/';
        infile = 'inverted_taper_sweep_655.mph';
    else
        modelpath = '../';
        outpath = 'C:\Users\IMTEK\Documents\GitHub\master_thesis\code\inverted_taper\random_search\results\';
        infile = 'inverted_taper_sweep.mph'; 
        ModelUtil.showProgress(true);
    end
    % load the model
    model = mphload([modelpath infile]);
    % set the name for the output intensity line file
    intfile = 'intensity_line.dat';
    
    % pass geometrical parameters to the COMSOL model
    model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
    model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
    model.param.set('y_out', [num2str(yout),'[um]'], 'Taper height on the output facet');
    % pass misalignment parameters to the COMSOL model as a parametric sweep
    model.study('std1').feature('param').set('plistarr', {sprintf('%f ' ,...
        M(:,1)),sprintf('%f ' , M(:,2)),sprintf('%f ' , M(:,3))});
    model.study('std1').feature('param').set('pname', {'x_mis' 'y_mis' 'alpha'});
    model.study('std1').feature('param').set('punit', {'um' 'um' 'deg'});

    % create line plot
    model.result.export('plot1').set('filename', [outpath intfile]);
    model.batch('p1').feature('ex1').set('paramfilename', 'index');
    model.batch('p1').feature('ex1').set('seq', 'plot1');
    model.batch('p1').feature('ex1').set('openfile', 'none');
    model.batch('p1').feature('ex1').run();
    
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl1');
    % extract the power from the accumulated probe table
    P = tabl.data(:,end); % units: W/m
    
    % retrieve the Iline data and store in in the matrix Iline_data
    flst = dir([outpath '*.dat']);
    [nMisPoints,misalignment_dim] = size(M);
    for i=1:nMisPoints
        filename = flst(i).name;
        path = flst(i).folder;
        if isunix == 1
            % load the data extracted from the model
            Iline = load([path '/' filename]);
        else
            Iline = load([path '\' filename]);
        end
        [n,m] = size(Iline);
        if i == 1
            Iline_data = zeros(n,m*nMisPoints);
            Iline_data(:,(m*i)-1:m*i) = Iline;
        else
            Iline_data(:,(m*i)-1:m*i) = Iline;
        end
    end
 
    features = allFeatures(Iline_data); %(symmetry,skew,center,rmse,correlation)
    features(:,2) = abs(features(:,2)); % take the absolute value of skew
    feat_mean = mean(features,1);
 
    switch objective_type
        case 'power'
        %objective is the mean light power
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
        objective = c_mean;
        case 'rmse'
        r_mean = feat_mean(4);
        objective = r_mean;
        case 'correlation'
        corr_mean = feat_mean(5);
        objective = corr_mean;    
    end

    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
       
end 
    