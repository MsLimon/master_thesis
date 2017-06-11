n = length(results);
for i = 5:n
    I =results(i).Iline
    dispname = sprintf('number of elements = %d',i);
    plot(I(:,1),I(:,2),'DisplayName',dispname);
    hold on;
end
hold off;
legend('show');