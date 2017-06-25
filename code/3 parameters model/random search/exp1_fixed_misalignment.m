Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 25, 2017
% 
% Study stability of misalignment points. Parameter space
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
    logfile = 'logfile_fixedMis.txt';
    outstruct_name = 'fixedMis_results.mat';
    reuse_geometry = true;
    reuse_misalignment = false;
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
   
   % repeat the experiment for numValues different misalignment matrix
   numValues = 5;
   nMisPoints = 60;
    
    for j = 1:numValues
        % set the name of the file containing the misalignment points
        misFilename = sprintf('misalignment_points_%d.txt',j);
        % set the name of the struct containing the results
        outstruct_name = sprintf('misalignment_%d_results.mat',j);
        if reuse_misalignment == true
            M = dlmread([outpath misFilename]);
            [nMisPoints,misalignment_dim] = size(M);
        else
            % % generate misalignment samples
            M = generatePoints(nMisPoints);
            [nMisPoints,misalignment_dim] = size(M);
            % save misalignment matrix
            dlmwrite([outpath misFilename], M);
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
