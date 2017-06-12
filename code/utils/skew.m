function s = skew(Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 29, 2017
%
% The function evaluates the skewness of the n input functions that are
% contained in I_data and returns the corresponding symmetry scores in 
% the vector m
%
%Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
%
%Output:
% - m. vector containing the symmetry score for each function contained in
% I_data (in order)
% m is calculated by decomposing each function into an symmetric and 
% anti-symmetric part and calculating the relative norm of the symmetric
% part.
[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

p = inputParser;

defaultMean = 'mean';
validMean = {'mean','lhalf'};
checkMean = @(x)any(validatestring(x,validMean));
addParameter(p,'mu',defaultMean,checkMean);

parse(p,varargin{:});

mean_type = p.Results.mu;

s = zeros(1,nMisPoints);

for i = 1:nMisPoints
x = Iline_data(:,(2*i)-1);
f = Iline_data(:,2*i);
f_total = sum(f);
p = f / f_total;
switch mean_type
    case 'mean'
        mu = sum(x .* p);
    case 'lhalf'
        mu = max(x)/2;   
end
mu2 = sum(((x - mu).^2).* p);
mu3 = sum(((x - mu).^3).* p);
s(i) = mu3 / (mu2^(3/2));
end

end