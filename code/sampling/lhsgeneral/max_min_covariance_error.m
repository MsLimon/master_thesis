% get max and min e_corr
R = zeros(2,2);
for i = 1:2
    method = i;
switch method
    case 1
    E = dlmread('error_results_test_rs.txt');
    case 2
    E = dlmread('error_results_test_lhs.txt');
end

E_100 = E(1:50,:);

variable= 1;

mu_var = E_100(:,variable+1);
e_cov_var = E_100(:,variable+4);

max_ecov = max(e_cov_var);
min_ecov = min(e_cov_var);
R(i,:) = [min_ecov max_ecov];

end
