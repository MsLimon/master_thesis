function s = symmetry(nMisPoints,Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 23, 2017
%
% The function evaluates the symmetry of the n input functions that are
% contained in I_data and returns the corresponding symmetry scores in 
% the vector m
%
%Input:
% - n scalar. number of functions contained in I_data
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
Iline_data = Iline_data(:);
Iline_data = reshape(Iline_data,[n/nMisPoints,nMisPoints*m]);
num_points = size(Iline_data,1);
% 
p = inputParser;
%weights = ones(num_points,1);
defaultWeights = 'uniform';
validWeights = {'uniform','gaussian','linear'};
checkWeights = @(x)any(validatestring(x,validWeights));
addParameter(p,'weights',defaultWeights,checkWeights);


parse(p,varargin{:});

weight_type = p.Results.weights;

switch weight_type
    case 'uniform' 
        w = ones(num_points,1);
    case 'gaussian'
        w = gausswin(num_points);
    case 'linear'
        i = [1:num_points];
        w = (-i + (num_points+1));
    otherwise
        warning('Unexpected weight type. Default uniform weights used instead')
        w = ones(num_points,1);
end

s = zeros(1,nMisPoints);

for i = 1:nMisPoints
x = Iline_data(:,i);
f = Iline_data(:,nMisPoints+i);
f_plus = 0.5 * (f + flip(f)); 
f_minus = 0.5 * (f - flip(f));
norm_f_plus = sqrt(sum((f_plus.^2).*w)) ;
norm_f_minus = sqrt(sum((f_minus.^2).*w));
%s(i) = norm(f_minus) / (norm(f_plus) + norm(f_minus));
s(i) = norm_f_minus / (norm_f_plus + norm_f_minus);
end

end