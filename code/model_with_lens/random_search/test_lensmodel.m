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
    pause(5);
end

mphstart();
import com.comsol.model.*
import com.comsol.model.util.*

[P1,Iline_data] = lensmodel(0,200,20,10,1); %(beta,taperx,yin,D0,w)
%disconnect from the server
ModelUtil.disconnect;

% Create figure
figure1 = figure;

% select figure size
f_width = 700;
f_height = 400;
figure1.Position = [100, 100, f_width, f_height];
plot(Iline_data(:,1),Iline_data(:,2))
xlabel('Arc length / um');
ylabel('I / W m^-^2');
