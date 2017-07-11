function r = central_corr(Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 15, 2017
%
% central_corr calculates the correlation coffiecient (lag=0) between every 
% intensity line and the reference line. The reference line can be the mean
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
nMisPoints = m/2;

p = inputParser;

defaultReference = 'perfect';
validReference = {'perfect','mean'};
checkReference = @(x)any(validatestring(x,validReference));
addParameter(p,'reference',defaultReference,checkReference);

parse(p,varargin{:});

reference_type = p.Results.reference;


%x_reference = Iline_data(:,(2*i)-1);

switch reference_type
    case 'perfect'
    i = 1; % reference is intensity line of perfectly line case
    f_reference = Iline_data(:,2*i)*1e-3;
    case 'mean'
    all_f = Iline_data(:,2:2:m);
    mean_f = mean(all_f,2)*1e-3;
    f_reference = mean_f;
end

r = zeros(1,nMisPoints);

for j = 2:nMisPoints
    %x2 = Iline_data(:,(2*j)-1);
    f2 = Iline_data(:,2*j)*1e-3;
    r(j) = xcorr(f_reference,f2,0);
end
end