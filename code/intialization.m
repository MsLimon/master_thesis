% --- Initialization ---

% * Set parameter initialization *
% * Set parameter boundaries *
% * Preallocate misalignmentResults matrix *

% * Create data struct *

% data is a data struct that contains the following fields:
% GEOMETRICALPARAMETERS is an array containing the values of the
% geometrical parameters that define the taper structure
% MISALIGNMENTRESULTS is a matrix with 7 columns (6 misalignment parameters
% and corresponding light output
% IDEALLIGHTOUTPUT is a float containing the power of the light output for
% the case of a perefectly aligned light source

data = struct('geometricalParameters',{},'misalignmentResults',{}, ...
       'idealLightOutput',{})
