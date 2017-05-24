% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 10, 2017

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

P1 = lensmodel_bayes(0.03,200,10,10,0.5)
%P2 = comsolblackbox(0,200,10)

ModelUtil.disconnect;