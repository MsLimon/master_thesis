function stop = outputfun2(results,state)
%persistent h

stop = false;
switch state
%     case 'initial'
%         h = figure;
    case 'iteration'
        if isunix == 1
            filepath = '';
        else
            filepath = '../';
        end
        tms = results.IterationTimeTrace;
        iter = numel(tms);
%         fig=figure(iter);
        % separate the lines for each misalignment point
        M = dlmread('misalignment_points.txt');
        
        % retrieve the Iline data and store in in the matrix Iline_data
        intfile = 'intensity_line.dat';
        % load the data extracted from the model
        Iline_data = load([filepath intfile]);

        structname = 'intensity_line.mat';
        
        if iter==1
            % preallocate the data struct
            data = struct('iter',0,'Iline',[]);
            data(iter) = struct('iter',iter,'Iline',Iline_data);
            save(structname, 'data');
        else
            load(structname);
            data(iter) = struct('iter',iter,'Iline',Iline_data);
            save(structname, 'data','-append');
        end
        
        % delete the I_line files
        removefiles = [filepath '*.dat'];
        delete(removefiles);
end