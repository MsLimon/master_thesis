% Initialization script

% * Parameter initialization *

% + Fixed parameters + --> obtain from COMSOL model

% + Parameters to optimize +

% In order to set the vector of parameters to be optimized (geometrical
% parameters), we first need to define the set of parameters that define
% the bezier curve that describes the lateral side of the tapered
% waveguide. However, it must be noted that not all parameters of the
% bezier curves are parameters to be explored during optimization (some of
% them are fixed or depend on other parameters). Therefore,
% we create two new variables:
% bezierCurveParameters is a cell array/dictionary that contains the
% parameters that define the piecewise bezier curve.

bezierCurveParameters = containers.Map({'A0x', 'A0y', 'A1x', 'A1y', ...
            'wA1', 'A2x', 'A2y', 'B1x', 'B1y', 'wB1', 'B2x', 'B2y'}, ...
            num2cell(zeros(1,12)));
c = bezierCurveParameters;

% In a similar way, we define the rest of the geometrical parameters as:

otherGeometricalParameters = containers.Map({'slabX', 'slabY', 'taperX',...
                                           'tip', 'claddingThickness'}, ...
                                           num2cell(zeros(1,5)));
g = otherGeometricalParameters;

% About cell data type: function cell2mat converts cells to arrays. e.g.
% cell2mat(g.values) gives a vector that contains the parameter values
% function num2cell does the inverse. Converts an array to a cell.

% Therefore, the geometrical parameter set in vector form is:

parameters = [g('slabX'), g('slabY'), g('taperX'), g('tip'), ...
g('claddingThickness'), c('A1x'), c('wA1'), c('A2y'), c('B1x'), c('wB1')];


% TODO: define the dependent/fixed bezier parameters as a function of the
% otherGeometrialParameters

% * Set parameter boundaries * --> check COMSOL model

% TODO: Think of the way to perform the random search and adapt data
% structures accordingly (do we need to create a setParameter function?)
% How are the parameters going to be obtained?

% TODO: learn how to iterate over non-numeric values
% IDEA: try to use a vectorized form of random number generator instead.

% * Preallocate misalignmentMatrix *

% misalignmentMatrix is a nx7 matrix. Where n is the number of misalignment
% samples and each row of the matrix is a vector that contains a
% misalignment position (6 parameters, rotation + translation) and its
% corresponding light output.

% Set number of misalignment samples 
nSamples = 10;
% Set dimension of misalignment space
misalignmentDim = 6;

misalignmentMatrix = zeros(nSamples,misalignmentDim + 1);

% * Create empty data struct *

% data is a struct that contains the following fields:
% GEOMETRICALPARAMETERS is an array containing the values of the
% geometrical parameters that define the taper structure
% MISALIGNMENTRESULTS is a nx7 matrix. Where n is the number of 
% misalignment samples and each row of the
% matrix is a vector that contains a misalignment position (6 parameters, 
% rotation + translation) and its corresponding light output.
% IDEALLIGHTOUTPUT is a float containing the power of the light output for
% the case of a perefectly aligned light source

data = struct('geometricalParameters',{},'misalignmentResults',{}, ...
       'idealLightOutput',{});
   
% TODO: Check how to input data in structs
