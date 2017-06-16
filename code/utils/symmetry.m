function s = symmetry(Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 30, 2017
%
% The function evaluates the symmetry of the n input functions that are
% contained in I_data and returns the corresponding symmetry scores in 
% the vector m
%
% Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
% Options:
% - weights type: specify weights type as a name-value pair. Valid options
% are 'uniform','linear' and 'gaussian'. Uniform weights is set as
% default. 
% - norm type: specify norm type as a name-value pair. Valid options are
% 'euclidean'(2-norm) and 'manhattan'(1-norm). Euclidean norm is set as
% default
%
% Output:
% - s. vector containing the symmetry score for each function contained in
% I_data (in order)
% s is calculated by decomposing each function into an symmetric and 
% anti-symmetric part and calculating the relative norm of the symmetric
% part.
%--------------------------------------------------------------------------
% Example: 
%s = symmetry(Iline_data,'weights','gaussian','norm','euclidean');

[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

p = inputParser;

defaultWeights = 'uniform';
defaultNorm = 'euclidean';
validWeights = {'uniform','gaussian','linear'};
validNorm = {'euclidean','manhattan'};
checkWeights = @(x)any(validatestring(x,validWeights));
checkNorm =  @(x)any(validatestring(x,validNorm));
addParameter(p,'weights',defaultWeights,checkWeights);
addParameter(p,'norm',defaultNorm,checkNorm);

parse(p,varargin{:});

weight_type = p.Results.weights;
norm_type = p.Results.norm;

switch weight_type
    case 'uniform' 
        w = ones(num_points,1);
    case 'gaussian'
        w = gausswin(num_points);
    case 'linear'
        i = 1:num_points;
        w = flip(i);
        w = w.';
end

switch norm_type
    case 'euclidean'
        p_norm=2;
    case 'manhattan'
        p_norm=1;    
end

s = zeros(1,nMisPoints);

for i = 1:nMisPoints
    x = Iline_data(:,(2*i)-1);
    f = Iline_data(:,2*i);
    f_plus = 0.5 * (f + flip(f)); 
    f_minus = 0.5 * (f - flip(f));
    norm_f_plus = sum((abs(f_plus).^p_norm).*w)^(1/p_norm);
    norm_f_minus = sum((abs(f_minus).^p_norm).*w)^(1/p_norm);
    %s(i) = norm(f_minus) / (norm(f_plus) + norm(f_minus));
    s(i) = norm_f_minus / (norm_f_plus + norm_f_minus);
end

end