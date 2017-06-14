function [P,Iline_data] = invertedtaper_mis(beta,taperx,yout,M)
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
    
    % get the intensity line data        
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
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;
    % delete the I_line files
    removefiles = [outpath '*.dat'];
    delete(removefiles);
end 
    