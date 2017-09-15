function [pareto_front,fig] = pareto_plot(x,f,limvec,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 15, 2017
%
% plot pareto front for a two-objective vector optimization
% 
%TODO: write input and output

fig = figure;

% get options print pic
p = inputParser;

defaultPrint = 'false';
validPrint = {'false','true'};
checkPrint = @(x)any(validatestring(x,validPrint));
addParameter(p,'print',defaultPrint,checkPrint);

parse(p,varargin{:});

print_pic_value = p.Results.print;

switch print_pic_value
    case 'true'
        print_pic = true;
    case 'false'
        print_pic = false;
end        
if print_pic == true
    % select figure size
    f_width = 1300;
    f_height= 700;
    %select line width of the plot lines
    linewidth = 2;
    font_size = 26;
else
    % select figure size
    f_width = 700;
    f_height = 400;
    %select line width of the plot lines
    linewidth = 1;
    font_size = 10;
end
fig.Position = [100, 100, f_width, f_height];
plot(x,f,'s','LineWidth',linewidth,'MarkerSize', 12,'DisplayName','regular solutions','MarkerSize', 14);
hold on
%limvec = 0.07:0.0005:0.1;
% TODO - automatically find the contraint boundaries (look for min of each
% function(mean and std) and get the corresponding std)
num_limvec = length(limvec);
pareto_front = zeros(num_limvec,3);
for i=1:num_limvec
    lim = limvec(i);
    valid_id = find(x<lim);
    valid_f = f(valid_id);
    [f_min,I_min]=min(valid_f);
    min_id = valid_id(I_min);
    x_min = x(min_id);
    pareto_front(i,:) = [min_id x_min f_min];
end
pareto_front = unique(pareto_front,'rows');
pareto_id = (pareto_front(:,1))';
x_pareto = (pareto_front(:,2))';
f_pareto = (pareto_front(:,3))';
num_pareto = length(pareto_id);
for j = 1:num_pareto
    legendname = sprintf('id = %d',pareto_id(j));
    plot(x_pareto(j),f_pareto(j),'*','LineWidth',linewidth,'DisplayName',legendname)
end
LEG=legend('show','Location','northeastoutside');
x_pareto = x(pareto_id);
f_pareto = f(pareto_id);
[f_pareto,I] = sort(f_pareto);
x_pareto = x_pareto(I);
% plot pareto front
plot(x_pareto,f_pareto,'-','LineWidth',linewidth,'DisplayName','pareto front');

set(LEG,'FontSize',font_size);
%set(gca,'fontsize',font_size);
set(gca,'fontsize',font_size,'LineWidth',linewidth);
end