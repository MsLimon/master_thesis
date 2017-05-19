function independentSamples = lhsindependent(pd,n)

% Developed by Marta Timon
% Master thesis
% University of Feiburg, Germany
% Last Update: March 31, 2017
%
%
% "lhsindependent" generates different samples of uncorrelated random 
% variables with any probability distribution function using Latin 
% Hypercube Sampling (LHS) 
%
%
% independentSamples = lhsindependent(pd,n)
% input arguments:
% - pd is a cell defined by user including the probability distribution 
% of all variables.
%   Each element in pd is an object representing the probability 
% distribution.
%   To generate the objects, use "makedist" (MATLAB Function, see MATLAB 
% documentation for more information)
% - n is the number of samples
% output:
% - indpendentSamples: different samples of uncorrelated random variables 
% 
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

% number of variables  
l = length(pd);                                                                    
% generate latin hypercube samples (MATLAB Function, see MATLAB 
% documentation for more information)
x = lhsdesign(n,l);
% preallocate samples matrix
independent_samples = zeros(n,l);                                            
for i = 1:l
    prob = x(:,i);
    % map latin hypercube samples to variable values using inverse 
    % cumulative distribution functions
    independent_samples(:,i) = icdf(pd{i},prob);                            
end

independentSamples = independent_samples;







