function P = power_out(Iline_data)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: July 16, 2017
%
% power_out calculates the integral of Iline.
%
% Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
%
% Output:
% - P. vector containing the integral for each function contained 
% in I_data (in order)

[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

P = zeros(1,nMisPoints);

for i = 1:nMisPoints
    x = Iline_data(:,(2*i)-1);
    f = Iline_data(:,2*i);
    num_points = length(f);
    P(i) = trapz(x,f)*1e-6;
end
end