% Random search function
% Performs Random search algorithm on the geometrical parameter space
% Input: parameter space, number of parameters, number of iterations,
% number of misalignment samples
% Output: parameters in interval [0,1]

% Random search: get a new set of geometrical parameters (loop)
    % Draw samples: new light position (nested loop)
        % Call solver
        % Update misalignmentResults matrix
    % Update data struct

function data = randomsearch(nIterations,nParameters,nSamples)
best = zeros(1,10);

    for i = 1:nIterations
        % Random search: get a new set of geometrical parameters (loop)
        parameters = rand(1, nParameters);
        for n = 1:nSamples
          % Draw samples: new light position (nested loop). Call DRAWSAMPLE
          % Call solver. TODO: create an random generator number function
          % and use it as solver for testing.
        end  
%     if (Cost(candidate) < Cost(Best))
%         best = candidate
%     end
    end
end

