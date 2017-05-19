%function [P,Iline_data] = lensmodelair(beta,taperx,yin,D0,w)
function [objective] = lensmodelair(beta,taperx,yin,D0,w)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 08, 2017
%
% Solve comsol model for a set of geometrical parameters 
% Input: 
% - geometrical parameters (beta,taperx,yin,D0,w)
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
        infile = '5parameters_model_with_air_655.mph'; % TODO - change file
    else
        modelpath = '../';
        infile = '5parameters_model_with_air.mph';
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
    model.param.set('D0_x', [num2str(D0),'[um]']);
    model.param.set('D0_w', num2str(w), 'weight of the Control point of the Bezier Curve describing the front lens');

    
    % calculate the coordinates of the tip of the bezier curve
    lens_thickness = bezier_curve(0,D0,0,w,0.5); % control points (P0,P1,P2) at the center t=0.5
    model.param.set('lens_thickness', [num2str(lens_thickness),'[um]']);
    
    % solve the model
    model.study('std1').run;
    % extract the accumulated probe table
    tabl = mphtable(model,'tbl1');
    % extract the power from the accumulated probe table
    P = tabl.data(:,end); % units: W/m
%     % export the intensity line data
%     model.result().export('plot1').set('plotgroup', 'pg3');
%     model.result().export('plot1').set('plot', 'lngr1');
%     model.result().export('plot1').set('filename', intensityfile);
%     model.result().export('plot1').run();
%     % load the data extracted from the model
%     Iline_data = load([modelpath intensityfile]);
%     
    objective = - P;
    % Save the model
    % mphsave(model,'output.mph');
    % remove the model
    ModelUtil.remove('model');
    ModelUtil.clear;    
       
end 