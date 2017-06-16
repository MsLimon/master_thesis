function c = centered(Iline_data,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 15, 2017
%
% centered calculates the integral of Iline weighted by a gaussian window.
% This favours the light beams that are central, therefore, it can be used
% as a measure of the centredness of the Iline 
%
% Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
% Options:
% - alpha: alpha is proportional to the reciprocal of the standard deviation. 
% The width of the window is inversely related to the value of alpha. 
% A larger value of alpha produces a narrower window. 
% The value of ? defaults to 2.5
% specify alpha as a name-value pair.
%
% Output:
% - c. vector containing the weighted integral for each function contained 
% in I_data (in order)

[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

p = inputParser;

defaultAlpha = 2.5;
checkAlpha = @(x)isnumeric(x);
addParameter(p,'alpha',defaultAlpha,checkAlpha);

parse(p,varargin{:});

alpha = p.Results.alpha;

c = zeros(1,nMisPoints);

for i = 1:nMisPoints
    x = Iline_data(:,(2*i)-1);
    f = Iline_data(:,2*i);
    num_points = length(f);
    w = gausswin(num_points,alpha); % TODO - plot the gaussian window!
    f = f.*w;
    c(i) = trapz(x,f)*1e-6;
end
end