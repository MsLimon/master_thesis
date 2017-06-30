function r = rmse(Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 16, 2017
%
% rmse calculates the root mean squared error of every intensity line with
% respect to the reference line. The reference line can be the mean
% intensity ('mean') or the perfectly aligned line ('perfect').
% Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
% Options:
% - reference: specify reference Iline as a name-value pair. Valid options
% are 'perfect' and 'mean'. 'perfect' is set as default.
%
% Output:
% - r. vector containing the rmse for each function contained 
% in I_data (in order)

[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

p = inputParser;

defaultReference = 'mean';
validReference = {'perfect','mean'};
checkReference = @(x)any(validatestring(x,validReference));
addParameter(p,'reference',defaultReference,checkReference);

parse(p,varargin{:});

reference_type = p.Results.reference;

i = 1; % reference is intensity line of perfectly line case

% set min and max values to normalize rmse
all_f = Iline_data(:,2:2:m);
max_f = max(max(all_f));
min_f = 0;
    
switch reference_type
    case 'perfect'
    f_reference = Iline_data(:,2*i)*1e-3;
    case 'mean'    
    mean_f = mean(all_f,2)*1e-3;
    f_reference = mean_f;
end

r = zeros(1,nMisPoints);

for j = 1:nMisPoints
    %x2 = Iline_data(:,(2*j)-1);
    f2 = Iline_data(:,2*j)*1e-3;
    diff = (f2-f_reference);
    RMSE = sqrt((1/num_points)*sum((diff).^2));
    r(j) = RMSE/(max_f - min_f);
end
end