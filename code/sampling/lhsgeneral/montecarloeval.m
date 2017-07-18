function [samples,meanError,stdError] = montecarloeval(pd,n)



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
% samples = montecarloeval(pd,n);
%
%
% Example 2:
% pd=cell(1,3);
% pd{1} = makedist('Triangular',0,5,10);
% pd{2} = makedist('Normal',-10,1);
% pd{3} = makedist('Uniform',20,40);

% n = 100000;
% samples = montecarloeval(pd,n);
%



l=length(pd);                                                               % number of variables       
                                                       
x=rand(n,l);                                                                % generate random samples (MATLAB Function, see MATLAB documentation for more information)
samples=zeros(n,l);                                                         % preallocation for the matrix
predefined_mean = zeros(1,l);                                               % preallocation for the matrix
predefined_std = zeros(1,l);                                                % preallocation for the matrix
actual_mean = zeros(1,l);                                                   % preallocation for the matrix
actual_std = zeros(1,l);                                                    % preallocation for the matrix
for i=1:l
    prob=x(:,i);
    samples(:,i) = icdf(pd{i},prob);                                        % map random samples to values using inverse cumulative distribution functions
    predefined_mean(:,i) = pd{1,i}.mu;                                     % Calculate standard deviation and mean of the distribution 
    predefined_std(:,i) = pd{1,i}.sigma;
    actual_mean(:,i) = mean(samples(:,i));
    actual_std(:,i) = std(samples(:,i));
end

meanError = actual_mean;
stdError = abs(predefined_std - actual_std)./predefined_std;        
end
