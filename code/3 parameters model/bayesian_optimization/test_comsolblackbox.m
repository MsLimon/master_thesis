% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: April 28, 2017

% Test comsolblackbox function
% 
if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
else
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*

% dimension of the misalignment space
misalignment_dim = 3;
% number of misalignment points
nMisPoints = 4;
% % generate misalignment samples
M = generatePoints(nMisPoints);

P1 = simplemodel_mis(0,200,15,M)
%P2 = simplemodel_mis(0,200,10,M)

ModelUtil.disconnect;

% function [P] = comsolblackbox(beta,taperx,yin)
%     import com.comsol.model.*
%     import com.comsol.model.util.*
%   
%     if isunix == 1
%         % set the name of the input model file
%         inpath = '';
%         infile = 'glass_feedthrough_model_655_6epw.mph';
%     else
%         inpath = '../';
%         infile = 'glass_feedthrough_model.mph';
%         ModelUtil.showProgress(true);
%     end
%     % load the model
%     model = mphload([inpath infile]);
% 
%     % pass geometrical parameters to the COMSOL model
%     model.param.set('beta', [num2str(beta),'[rad]'], 'Angle of later facet');
%     model.param.set('taper_x', [num2str(taperx),'[um]'], 'Length of the taper in propagation direction');
%     model.param.set('y_in', [num2str(yin),'[um]'], 'Taper height on the input facet');
%     % solve the model
%     model.study('std1').run;
%     % extract the accumulated probe table
%     tabl = mphtable(model,'tbl2');
%     % extract the power from the accumulated probe table
%     P = tabl.data(2); % units: W/m
% 
%     % remove the model
%     ModelUtil.remove('model');
%     ModelUtil.clear;    
%     
% end 
%     
