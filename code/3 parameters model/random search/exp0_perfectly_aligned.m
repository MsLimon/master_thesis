% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 29, 2017
% 
% Random search on geometrical space without misalignment. Parameter space
% is (beta, taper_x, y_in)
% 
% How it works:
% 
% 
% In Matlab
% ---------
% - Change path dependencies to run the server
% - Set  the path and filename of the Comsol model of the taper
% - Set  the path and filename of the files containing the results
% - Run the script (start COMSOL server before running the script if it is
% not possible to start the server within the script)
% 
% Results
% -------
% Results are stored in the matrix R and save to a file.
% Results are also stored in the struct "data" and saved on a .mat file
% The struct contains the following fields:
% - 'geometry' = current_geometry: vector containing the values of the parameters that
% define the geometry that is being evaluated -> (beta, taper_x, y_in)
% - 'results' = P:  power output (P) that is
% obtained when solving the model 
% - 'Iline'= Iline_data : matrix containing the intensity profile at the
% output facet


clear all 
clc

if isunix == 1
    % add path to utils
    addpath('~/utils');
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')
    % Run script once the server is started or use the command below
    % Start the COMSOL server (for Windows only. This command should be changed
    % when running the script in a different OS)
    % system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
    system_command = sprintf('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver -tmpdir %s -autosave off &',MY_TMPDIR);
    system(system_command);
    pause(15);
else
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');

end

mphstart();
try
    import com.comsol.model.*
    import com.comsol.model.util.*

    % set the names of the input and output files
    logfile = 'logfile_exp0.txt';
    resultsfile = 'exp0_results.txt';
    outstruct_name = 'exp0_results.mat';
    bestcandidatefile = 'exp0_bestcandidate.txt';
    if isunix == 1
       outpath = './';
    else
        outpath = './results/';
        ModelUtil.showProgress(true);
    end
    % save the logfile
    ModelUtil.showProgress([outpath logfile]);
       
    % make the random generator different every time that matlab starts
    rng('shuffle');
    % save the current random generator settings in s:
    %s = rng;
    reuse_geometry = false;
   
    if reuse_geometry == true
        % load geometry
        G = dlmread([outpath 'geometry.txt']);
        [nGeomPoints,searchSpace_dim] = size(G);
    else
        % dimension of search space(beta, taper_x, y_in)
        searchSpace_dim = 3;
        % number of geomtrical parameter sets (number of random points)
        nGeomPoints = 1;
        % create random geometrical parameter matrix G. Each row of the matrix 
        % contains a set of geometrical parameters: beta, taper_x, y_in
        G = rand(nGeomPoints,searchSpace_dim);
        % set bounds for the geometrical parameters
        beta_min = 0;
        beta_max = 0.0652; %unit: radians
        taperx_min = 200; %unit: micrometers
        taperx_max = 230; % '' ''
        yin_min = 5; % '' ''
        yin_max = 20; % '' ''
        % change limits of the geometrical parameter matrix G
        G(:,1) = (beta_max - beta_min).*G(:,1)+ beta_min;
        G(:,2) = (taperx_max - taperx_min).*G(:,2)+ taperx_min;
        G(:,3) = (yin_max - yin_min).*G(:,3)+ yin_min;
        
        % save the explored geometry
        dlmwrite([outpath 'geometry.txt'], G);
    end
    % prealocate results matrix R. Each row of R contain a set of
    % geometrical parameters and the power obtained when running the model with
    % those parameters
    R = zeros(nGeomPoints,searchSpace_dim+1);
    R(:,1:end-1) = G;
    % initialize best power to an empty vector (best geometry)
    best_power = 0;
    % pass all parameter sets to the COMSOL model, evaluate the power and
    % store it in the results matrix
    
    % preallocate the data struct
    data = struct('geometry',[],'results',0,'Iline',[]);
    
    for i = 1:nGeomPoints
        current_geometry = G(i,:);
      [P,Iline_data] = comsolblackbox2(G(i,1),G(i,2),G(i,3)); %(beta,taperx,yin,D0,w)
        R(i,end) = P;
        if P > best_power
            best_power = P;
            best_candidate = current_geometry;
        end 
        data(i) = struct('geometry',current_geometry,'results',P,'Iline',Iline_data);
    end
    % Save the results
    dlmwrite([outpath resultsfile],R);
    dlmwrite([outpath bestcandidatefile],best_candidate);
    save([outpath outstruct_name], 'data');
    % to append more points use:
    % dlmwrite('myFile.txt',N,'-append',...
    % 'delimiter',' ','roffset',1);
    ModelUtil.clear;
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end