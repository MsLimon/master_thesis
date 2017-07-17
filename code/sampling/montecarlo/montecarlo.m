function samples = montecarlo(pd,n)



% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: February 07, 2017
%
%
% This code is developed to generate different realizations of random variables 
% with any probability distribution function using Monte Carlo Sampling 
%
% [samples]= montecarlo(pd,n)
% input arguments:
% - pd is a cell defined by user including the probability distribution of all variables.
%   Each element in pd is an object representing the probability distribution.
%   To generate the objects, use "makedist" (MATLAB Function, see MATLAB documentation for more information)
% - n is the number of realizations
% output:
% - samples: different realizations of the random variables 
%
%
% Example 1:
% pd=cell(1,2);
% pd{1} = makedist('Normal',0,20);
% pd{2} = makedist('Triangular',0,100,150);
% n = 100000;
% samples = montecarlo(pd,n);
%
%
% Example 2:
% pd=cell(1,3);
% pd{1} = makedist('Triangular',0,5,10);
% pd{2} = makedist('Normal',-10,1);
% pd{3} = makedist('Uniform',20,40);

% n = 100000;
% samples = montecarlo(pd,n);
%



l=length(pd);                                                               % number of variables       
                                                       
x=rand(n,l);                                                                % generate random samples (MATLAB Function, see MATLAB documentation for more information)
samples=zeros(n,l);                                                         % preallocation for the matrix

for i=1:l
    prob=x(:,i);
    samples(:,i) = icdf(pd{i},prob);                                        % map random samples to values using inverse cumulative distribution functions
end

          
end



