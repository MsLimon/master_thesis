function R = allFeatures(Iline_data)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 16, 2017
%
% Calculate all features and gather them in a matrix
%
% Input:
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
%
% Output:
% - R. matrix containing the all the features for each function contained 
% in I_data (in order). Every column corresponds to a different feature and
% every row corresponds to the features of an intensity profile.
% The order of the features is 
% R = {'symmetry','skew','center','rmse','correlation'}; 

[n,m] = size(Iline_data);
num_points = n;
nMisPoints = m/2;

num_features = 5;
% preallocate results matrix
R = zeros(n,num_features*2);

s = symmetry(Iline_data,'weights','gaussian','norm','euclidean');
s = s';

k = skew(Iline_data,'mu','lhalf');
k = k';

c = centered(Iline_data,'alpha',2.5);
c = c';
c = -c;

r = rmse(Iline_data,'reference','perfect');
r = r';

corr = centralCorr(Iline_data,'reference','perfect');
corr = corr';
corr = -corr;

R = [s k c r corr];

end