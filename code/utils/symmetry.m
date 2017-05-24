function m = symmetry(nMisPoints,Iline_data)
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

m = zeros(1,nMisPoints);

for i = 1:nMisPoints
x = Iline_data(:,i);
f = Iline_data(:,nMisPoints+i);
f_plus = 0.5 * (f + flip(f)); 
f_minus = 0.5 * (f - flip(f)); 
m(i) = norm(f_plus) / (norm(f_plus) + norm(f_minus));
end

end