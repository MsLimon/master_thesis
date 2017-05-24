function stop = outputfun(results,state)
%persistent h

stop = false;
switch state
%     case 'initial'
%         h = figure;
    case 'iteration'
        tms = results.IterationTimeTrace;
        iter = numel(tms);
        fig=figure(iter);
        Iline_data = load('../intensity_line_multiple.dat');
        % separate the lines for each misalignment point
        M = dlmread('misalignment_points.txt');
        [nMisPoints,misalignment_dim] = size(M);
        s = symmetry(nMisPoints,Iline_data);
        [n,m] = size(Iline_data);
        Iline_data = Iline_data(:);
        Iline_data = reshape(Iline_data,[n/nMisPoints,nMisPoints*m]);
        filename = sprintf('intensity_line_multiple_%d',iter);
%         filename = sprintf('intensity_line_multiple_%d.dat',iter);
%         dlmwrite(filename,Iline_data);
        hold on
        for i = 1:nMisPoints
            legendname = sprintf('x_{mis}=%0.5g, y_{mis}=%0.5g, alpha=%0.5g, s=%0.5g',M(i,1),M(i,2),M(i,3),s(i));
            plot(Iline_data(:,i),Iline_data(:,i+nMisPoints),'DisplayName',legendname);
%             plot(Iline_data(:,i),Iline_data(:,i+nMisPoints));
        end
        legend('show','Location', 'Best');
        xlabel('Arc length / um');
        ylabel('I / W m^-^2');
        xlim([0 50]);
        ylim([0 3.5e5]);
        hold off
        drawnow
        % save the figure to a png file
        print(fig,filename,'-r300','-dpng')
end