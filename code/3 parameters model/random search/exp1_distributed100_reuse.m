% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: April 22, 2017
% 
% Random search with misalignment. The script creates a comsol model with
% random geometry and a fixed set of misalignment points
% 
% How it works:
% 
% In COMSOL model (GUI mode) 
% --------------------------
% 
% In Matlab
% ---------
% - Change path dependencies to run the server
% - Set  the path and filename of the Comsol model of the taper
% - Run the script (start COMSOL server before running the script if it is
% not possible to start the server within the script)
% 
% Results
% -------
%

% clear all 
% clc
if isunix == 1
    % Important: adjust path of the COMSOL43/mli directory if necessary
    addpath('~/Comsol/comsol52a/multiphysics/mli')

    % Run script once the server is started or use the command below
    % Start the COMSOL server 
    system('~/Comsol/comsol52a/multiphysics/bin/comsol mphserver &');
else
    addpath('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\mli')
    % connect MATLAB and COMSOL server
    system('C:\Program Files\COMSOL\COMSOL52a\Multiphysics\bin\win64\comsolmphserver.exe &');
    i = 1;
end

% connect MATLAB and COMSOL server
mphstart();
try
    % import comsol
    import com.comsol.model.*
    import com.comsol.model.util.*

    % remove previous models in case it exist
    ModelUtil.remove('model');
    
    % set the names of the input and output files
    infile = 'glass_feedthrough_model_batch_655_6epw.mph';
    outfile = sprintf('random_misalignment_sweep_%d',i);
    reuse_geometry = false;
    reuse_misalignment = true;
%     logfile = sprintf('logfile_%d',i);
    if isunix == 1
       outpath = './';
    else
        outpath = './results/';
        ModelUtil.showProgress(true);
    end
    % save the logfile
%     ModelUtil.showProgress([outpath logfile]);
    % load the model
    model = mphload(infile);
    % dimension of search space(beta, taper_x, y_in)
    searchSpace_dim = 3;
    % number of geomtrical parameter sets (number of random points)
    nGeomPoints = 1;
    % dimension of the misalignment space
    misalignment_dim = 3;
    % number of misalignment points
    nMisPoints = 100;
    % make the random generator different every time that matlab starts
    rng('shuffle');
    % create random geometrical parameter matrix G. Each row of the matrix 
    % contains a set of geometrical parameters: (beta, taper_x, y_in)
    if reuse_geometry == true
        G = dlmread([outpath 'geometry.txt']);
        current_geometry = G(i,:);
    else
        G = rand(nGeomPoints,searchSpace_dim);
        % set bounds for the geometrical parameters
        beta_min = 0;
        beta_max = 0.0652; %unit: radians
        taperx_min = 200; %unit: micrometers
        taperx_max = 230; % '' ''
        yin_min = 5; % '' ''
        yin_max = 20; % '' ''
        % change limits of the geometrical parameter matrix G
        G(1) = (beta_max - beta_min).*G(1)+ beta_min;
        G(2) = (taperx_max - taperx_min).*G(2)+ taperx_min;
        G(3) = (yin_max - yin_min).*G(3)+ yin_min;
                
        % save geometry in a file
        if i == 1
            dlmwrite([outpath 'geometry.txt'], G);
        else
            dlmwrite([outpath 'geometry.txt'],G,'-append');
        end

        current_geometry = G;
    end

    if reuse_misalignment == true
        M = dlmread([outpath 'misalignment_points.txt']);
    else
        if i ==1
            % Define probability distribution of misalignment space
            pd = cell(1,misalignment_dim);
            % distribution corresponding to the misalignment on x
            pd{1} = makedist('normal','mu',0,'sigma',1.5);
            % truncate x distribution (alignment structures only allow the laser to move backwards)
            pd{1} = truncate(pd{1},0,5);
            % distribution corresponding to the misalignment on y
            pd{2} = makedist('normal','mu',0,'sigma',3);
            % truncate y distribution (we have symmetry about the x axis)
            pd{2} = truncate(pd{2},0,9);
            % distribution corresponding to the misalignment on alpha
            pd{3} = makedist('normal','mu',0,'sigma',1);
            % truncate alpha distribution (don't allow values greater than alpha)
            pd{3} = truncate(pd{2},-3,3);

            % generate misalignment samples
            M = lhsindependent(pd,nMisPoints);
            % save misalignment matrix
            dlmwrite([outpath 'misalignment_points.txt'], M);
        else
            M = dlmread([outpath 'misalignment_points.txt']);
        end
    end
    
    % pass the geometrical parameters to COMSOL
    model.param.set('beta', [num2str(current_geometry(1)),'[rad]'],...
        'Angle of later facet');
    model.param.set('taper_x', [num2str(current_geometry(2)),'[um]'],...
        'Length of the taper in propagation direction');
    model.param.set('y_in', [num2str(current_geometry(3)),'[um]'],...
        'Taper height on the input facet');
    % pass misalignment parameters to the COMSOL model as a batch sweep
    model.study('std1').feature('param').set('plistarr', {sprintf('%f ' ,...
        M(:,1)),sprintf('%f ' , M(:,2)),sprintf('%f ' , M(:,3))});
    model.study('std1').feature('param').set('pname', {'x_mis' 'y_mis' 'alpha'});
    model.study('std1').feature('param').set('punit', {'um' 'um' 'deg'});



    % Save the model
    disp('saving outfile');
    mphsave(model,[outpath outfile]);
    
    ModelUtil.clear;
    ModelUtil.disconnect;
catch exception
    error_msg = getReport(exception)
    ModelUtil.clear;
    ModelUtil.disconnect; 
end
