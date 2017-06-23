function G = generateGeom(nGeomPoints,varargin)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: June 06, 2017
%
% Input:
% - nGeomPoints. number of geometric parameters to be generated
%
% Options:
% - model: specify model as a name-value pair. Valid options are 'simple',
% 'lens'. Simple model is set as default.
%
% Output:
% - G geometry parameter values. If model is set to simple then G = [beta
% taperx yin], if model is set to lens then G = [beta taperx yin D0 w]

% use input parses to introduce model options
p = inputParser;
% default model type is simple (model with 3 parameters)
defaultModel = 'simple';
validModel = {'simple','lens'};
checkModel = @(x)any(validatestring(x,validModel));
addParameter(p,'model',defaultModel,checkModel);

parse(p,varargin{:});

model_type = p.Results.model;

% generate random geoemtric parameters uniformly distributed
% dimension of search space(beta, taper_x, y_in)
switch model_type
    case 'simple' 
        searchSpace_dim = 3;
    case 'lens'
        searchSpace_dim = 5;
end

if isunix == 1
    % set the minimum element size. in the cluster the 655nm wavelenght
    % is used therefore:
    h_max = 1.0917e-1; %unit: micrometers % TODO - change it if you are using 5 elements per wavelenght
    % TODO - change this!! (find a solution so that it is not hardcored. Can you retrieve parameter values from comsol?)
else
    h_max = 2 / 6; %unit: micrometers
end

% create random geometrical parameter matrix G. Each row of the matrix 
% contains a set of geometrical parameters (beta, taper_x, y_in)
G = rand(nGeomPoints,searchSpace_dim);
% set bounds for the geometrical parameters
beta_min = 0;
beta_max = 0.0651; %unit: radians
taperx_min = 200; %unit: micrometers
taperx_max = 230; % '' ''
yin_min = 0.5; % '' ''
yin_max = 10; % '' ''

% change limits of the geometrical parameter matrix G
G(:,1) = (beta_max - beta_min).*G(:,1)+ beta_min;
%G(:,2) = (taperx_max - taperx_min).*G(:,2)+ taperx_min;
G(:,2) = repmat(taperx_min,[nGeomPoints,1]); % fix taperx
G(:,3) = (yin_max - yin_min).*G(:,3)+ yin_min;

switch model_type 
    case 'simple' 
    case 'lens'
    D0_min = h_max; %unit: micrometers
    D0_max = 10; %unit: micrometers
    w_min = 0.1; % unitless
    w_max = 5; % unitless

    G(:,4) = (D0_max - D0_min).*G(:,4)+ D0_min;
    G(:,5) = (w_max - w_min).*G(:,5)+ w_min;
end
end