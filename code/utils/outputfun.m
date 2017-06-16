function stop = outputfun(results,state)
%persistent h

stop = false;
switch state
%     case 'initial'
%         h = figure;
    case 'iteration'
        if isunix == 1
            outpath = '/home/fr/fr_fr/fr_mt155/Iline/';
        else
            outpath = 'C:\Users\IMTEK\Documents\GitHub\master_thesis\code\3 parameters model\bayesian_optimization\results\';
        end
        tms = results.IterationTimeTrace;
        iter = numel(tms);
%         fig=figure(iter);
        % separate the lines for each misalignment point
        M = dlmread('misalignment_points.txt');
        
        % retrieve the Iline data and store in in the matrix Iline_data
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
        
%         s = symmetry(Iline_data);
%         s = s';
        structname = 'intensity_line_multiple.mat';
        
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
        
%         hold on
%         for i = 1:nMisPoints
%             legendname = sprintf('x_{mis}=%0.5g, y_{mis}=%0.5g, alpha=%0.5g, s=%0.5g',M(i,1),M(i,2),M(i,3),s(i));
%             plot(Iline_data(:,(2*i)-1),Iline_data(:,2*i),'DisplayName',legendname);
% %             plot(Iline_data(:,i),Iline_data(:,i+nMisPoints));
%         end
%         legend('show','Location', 'Best');
%         xlabel('Arc length / um');
%         ylabel('I / W m^-^2');
%         xlim([0 50]);
%         ylim([0 3.5e5]);
%         hold off
%         drawnow
        % save the figure to a png file
%         print(fig,filename,'-r300','-dpng')
        
        % delete the I_line files
        removefiles = [outpath '*.dat'];
        delete(removefiles);
end