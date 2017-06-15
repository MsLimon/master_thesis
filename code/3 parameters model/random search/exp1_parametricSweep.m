% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 06, 2017
% 
% Random search on geometrical space with misalignment. Parameter space
% is (beta, taper_x, y_in)
% 
% How it works:
% - Change path dependencies to run comsol server
% - Set the path and filename of the .mat file containing the data struct 
% results
% - Run the script (start COMSOL server before running the script if it is
% not possible to start the server within the script)
% 
% Results
% -------
% Results are stored in the struct "data" and saved on a .mat file
% The struct contains the following fields:
% - 'geometry' = current_geometry: vector containing the values of the parameters that
% define the geometry that is being evaluated -> (beta, taper_x, y_in)
% - 'misalignment' = M : Misalignment matrix. Contains the values of the misalignment 
% parameters that are evaluated for the current_geometry 
% Each row is a set of parameters -> (x_mis, y_mis, alpha)
% - 'results' = R: Results matrix. Each row contains a set of misalignment parameters
% (the same set contained in M) and the resulting power output (P) that is
% obtained when solving the model ->(x_mis, y_mis, alpha, P)
% - 'Iline'= Iline_data : matrix containing the intensity profile at the
% output facet

if isunix == 1 % on the cluster
    % add path to utils
    addpath('./utils');
    % Start the COMSOL server 
    system_command = sprintf('comsol mphserver </dev/null >mphserver.out 2>mphserver.err -nn %d -nnhost 1 -np %d -f %s -tmpdir %s -autosave off &',NN,NP,PBS_HOSTFILE,MY_TMPDIR);
    system(system_command);
    pause(15);
else % on the local machine (Windows)
    % add path to utils
    addpath('C:\Users\IMTEK\Documents\GitHub\master_thesis\code\utils');
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli');
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
end

% connect MATLAB and COMSOL server
mphstart();
import com.comsol.model.*
import com.comsol.model.util.*
try
    % set the paths and filenames
    logfile = 'logfile_exp1.txt';
    outstruct_name = 'exp1_results.mat';
    reuse_geometry = true;
    reuse_misalignment = true;
    if isunix == 1
        outpath = '';
    else
        outpath = './results/';
        ModelUtil.showProgress(true);
    end
    % save the logfile
    ModelUtil.showProgress([outpath logfile]);
    % make the random generator different every time that matlab starts
    rng('shuffle');
    % save the current random generator settings in s:
    % s = rng;
    
    if reuse_geometry == true
        G = dlmread([outpath 'geometry.txt']);
        [nGeomPoints,searchSpace_dim] = size(G);
    else
        % number of geomtrical parameter sets (number of random points)
        nGeomPoints = 2;
        G = generateGeom(nGeomPoints,'model','simple');
        [nGeomPoints,searchSpace_dim] = size(G);
        % save the generated geometry
        dlmwrite([outpath 'geometry.txt'], G);
    end
    
    if reuse_misalignment == true
        M = dlmread([outpath 'misalignment_points.txt']);
        [nMisPoints,misalignment_dim] = size(M);
    else
        % dimension of the misalignment space
        misalignment_dim = 3;
        % number of misalignment points
        nMisPoints = 2;
        % % generate misalignment samples
        M = generatePoints(nMisPoints);
        % save misalignment matrix
        dlmwrite([outpath 'misalignment_points.txt'], M);
    end

    % preallocate results matrix R. Each row of R contain a set of
    % misalignment parameters and the power obtained when running the model with
    % those parameters
    R = zeros(nMisPoints,misalignment_dim+1);
    R(:,1:end-1) = M;   

    for i = 1:nGeomPoints
        if i==1
            % preallocate the data struct
            data = struct('geometry',[],'misalignment',M,'results',R,'Iline',[]);
        else
        end
        % pass geometrical parameters to the COMSOL model
        current_geometry = G(i,:);
        % solve the model for the given geometry and misalignment points
        [P,Iline_data] = comsolblackbox_mis(G(i,1),G(i,2),G(i,3),M); %(beta,taperx,yin,M);
        % store the extracted values in the results matrix
        R(:,end) = P;
        % create a struct to store the data
        data(i) = struct('geometry',current_geometry,'misalignment', M,'results',R,'Iline',Iline_data);
        if i==1
            save([outpath outstruct_name], 'data');
        else
            save([outpath outstruct_name], 'data','-append');
        end
    end
    
    % To load the data structure from a .mat file use the command
    % load(struct_name);
    ModelUtil.clear;
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end
