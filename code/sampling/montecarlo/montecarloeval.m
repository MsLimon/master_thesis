function [samples,meanError,stdError] = montecarloeval(pd,n)



% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: February 10, 2017
%
%
% This code is developed to generate different realizations of random variables 
% with any probability distribution function using Monte Carlo Sampling and to evaluate its error.
%
% [samples, meanError, stdError]= montecarloeval(pd,n)
% input arguments:
% - pd is a cell defined by user including the probability distribution of all variables.
%   Each element in pd is an object representing the probability distribution.
%   To generate the objects, use "makedist" (MATLAB Function, see MATLAB documentation for more information)
% - n is the number of realizations
% output:
% - samples: different realizations of the random variables 
% - meanError: array of lenght l(l = length(pd)). Difference between the mean
% of the distribution pd and the mean of the samples created by the
% algorithm
% - stdError: array of lenght l(l = length(pd)). Difference between the
% standard deviation of the distribution pd and the standard deviation of 
% the samples created by the algorithm
%
%
% Example 1:
% pd=cell(1,2);
% pd{1} = makedist('Normal',0,20);
% pd{2} = makedist('Triangular',0,100,150);
% n = 100000;
% [samples,me,se] = montecarloeval(pd,n);
%
%
% Example 2:
% pd=cell(1,3);
% pd{1} = makedist('Triangular',0,5,10);
% pd{2} = makedist('Normal',-10,1);
% pd{3} = makedist('Uniform',20,40);

% n = 100000;
% [samples,me,se] = montecarloeval(pd,n);
%



l=length(pd);                                                               % number of variables       
                                                       
x=rand(n,l);                                                                % generate random samples (MATLAB Function, see MATLAB documentation for more information)
samples=zeros(n,l);                                                         % preallocation for the matrix containing the samples
predefined_mean = zeros(1,l);                                               % preallocation for the matrix containing the mean of the distribution 
predefined_std = zeros(1,l);                                                % preallocation for the matrix containing the standard deviation of the distribution
actual_mean = zeros(1,l);                                                   % preallocation for the matrix containing the mean of the samples
actual_std = zeros(1,l);                                                    % preallocation for the matrix containing the standard deviation of the samples
for i=1:l
    prob=x(:,i);
    samples(:,i) = icdf(pd{i},prob);                                        % map random samples to values using inverse cumulative distribution functions
    predefined_mean(:,i) = mean(pd{i});                                     % Calculate standard deviation and mean of the distribution            
    predefined_std(:,i) = std(pd{i});
    actual_mean(:,i) = mean(samples(:,i));                                  % Calculate the standard deviation and mean of the samples
    actual_std(:,i) = std(samples(:,i));
end

meanError = abs(predefined_mean - actual_mean);                             % Calculate the error of the mean and standard deviation of the samples.
stdError = abs(predefined_std - actual_std);        
end
