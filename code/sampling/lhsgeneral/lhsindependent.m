function independentSamples = lhsindependent(pd,n)



% Developed by Marta Timon
% Master thesis
% University of Feiburg, Germany
% Last Update: February 03, 2017
%
%
% This code is developed to generate different realizations of uncorrelated random variables 
% with any probability distribution function using Latin Hypercube Sampling (LHS) 
%
%
% [independentSamples]=lhsgeneral(pd,n)
% input arguments:
% - pd is a cell defined by user including the probability distribution of all variables.
%   Each element in pd is an object representing the probability distribution.
%   To generate the objects, use "makedist" (MATLAB Function, see MATLAB documentation for more information)
% - n is the number of realizations
% output:
% - indpendentSamples: different realizations of uncorrelated random variables 

%
%
% Example 1:
% pd=cell(1,2);
% pd{1} = makedist('Normal',0,20);
% pd{2} = makedist('Triangular',0,100,150);
% n = 100000;
% independentSamples = lhsindependent(pd,n);
%
%
% Example 2:
% pd=cell(1,3);
% pd{1} = makedist('Triangular',0,5,10);
% pd{2} = makedist('Normal',-10,1);
% pd{3} = makedist('Uniform',20,40);
% n = 100000;
% independentSamples = lhsindependent(pd,n);
%
%
%




l=length(pd);                                                               % number of variables       

x=lhsdesign(n,l);                                            % generate latin hypercube samples (MATLAB Function, see MATLAB documentation for more information)
independent_samples=zeros(n,l);                                             % preallocation for the matrix
for i=1:l
    prob=x(:,i);
    independent_samples(:,i) = icdf(pd{i},prob);                         % map latin hypercube samples to values using inverse cumulative distribution functions
end

independentSamples = independent_samples;

% fprintf('\n\n')
% predefined_mean
% fprintf('\n\n')
% actual_mean
% fprintf('\n\n')
% predefined_std
% fprintf('\n\n')
% actual_std






