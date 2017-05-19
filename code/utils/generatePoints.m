function M = generatePoints(n)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 05, 2017
%
% Sample n misalignment points using Latin Hypercube sampling
% Input: number of sampling points
% Output: is the matrix M with row vector (x_mis, y_mis, alpha)

% dimension of the misalignment space
    misalignment_dim = 3;
    % number of misalignment points
    nMisPoints = n;
    
    % Define probability distribution of misalignment space
    pd = cell(1,misalignment_dim);
    % distribution corresponding to the misalignment on x
    pd{1} = makedist('normal','mu',0,'sigma',1.5);
    % truncate x distribution (alignment structures only allow the laser to move backwards)
    pd{1} = truncate(pd{1},0,5);
    % distribution corresponding to the misalignment on y
    pd{2} = makedist('normal','mu',0,'sigma',3);
    % truncate y distribution (we have symmetry about the x axis)
    pd{2} = truncate(pd{2},0,9);
    % distribution corresponding to the misalignment on alpha
    pd{3} = makedist('normal','mu',0,'sigma',1);
    % truncate alpha distribution (don't allow values greater than alpha)
    pd{3} = truncate(pd{3},-3,3);
    
    % % generate misalignment samples
    M = lhsindependent(pd,nMisPoints);
end