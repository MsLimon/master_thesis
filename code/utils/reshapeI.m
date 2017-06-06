function Iline_out = reshapeI(Iline_data,nMisPoints)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 01, 2017
%
% Reshape Iline_data
%
%Input:
% - nMisPoints scalar. number of functions contained in I_data
% - I_data is a matrix containing the functions to be evaluates. The first
% column contains x values and the second column corresponds to the
% correspoding intensity values. The number of rows can vary
%Options:
% - Iline_out is a matrix with nMisPoints*2 columns. The first nMisPoints
% columns contain the x values of the I_lines and the last nMisPoints
% columns contain the corresponding intensity values.
[n,m] = size(Iline_data);
Iline_out = Iline_data(:);
Iline_out = reshape(Iline_out,[n/nMisPoints,nMisPoints*m]);
end