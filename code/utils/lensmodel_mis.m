function [P,Iline_data] = lensmodel_mis(beta,taperx,yin,D0,w,M)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 09, 2017
%
% Solve comsol model for a set of geometrical parameters 
% Input: 
% - geometrical parameters (beta,taperx,yin,D0,w)
% - matrix M with misaligment points with row vector (x_mis, y_mis, alpha)
% Output: 
% - P is the integral of the light intentsity at the
% output face
% - Iline_data is a matrix containing the data of the intensity line at the
% output facet of the lens. The first column contains the arc lenght of the
% taper (in um) and the second column contains the corresponding intesitty 
% (in W m^-^2)


% is calculated at the outputfacet
    import com.comsol.model.*
    import com.comsol.model.util.*

    if isunix == 1
        % set the name of the input model file
        modelpath = '';
        outpath = '/home/fr/fr_fr/fr_mt155/Iline/';
        %infile = '5parameters_model_sweep.mph'; 
        infile = '5parameters_model_sweep_655.mph';
    else
        modelpath = '../';
        outpath = 'C:\Users\IMTEK\Documents\GitHub\master_thesis\code\model_with_lens\random_search\results\';
        infile = '5parameters_model_sweep.mph';
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
    model.param.set('D0_x', [num2str(D0),'[um]']);
    model.param.set('D0_w', num2str(w), 'weight of the Control point of the Bezier Curve describing the front lens');

    % calculate the coordinates of the tip of the bezier curve
    lens_thickness = bezier_curve(0,D0,0,w,0.5); % control points (P0,P1,P2) at the center t=0.5
    model.param.set('lens_thickness', [num2str(lens_thickness),'[um]']);
    
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
    
    % Save the model
    %mphsave(model,'output.mph');
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
       
end 