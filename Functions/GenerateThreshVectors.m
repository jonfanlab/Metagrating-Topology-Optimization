% Interpolate between the start and end edge deviations to create
% and edge deviation value for each iteration
function [ThresholdVectors, NRobustness] = GenerateThreshVectors(OptParm)
    % Extract necessary parameters
    MaxIterations = OptParm.Optimization.Iterations;
    Start = OptParm.Optimization.Robustness.StartDeviation;
    End = OptParm.Optimization.Robustness.EndDeviation;
    Ramp = OptParm.Optimization.Robustness.Ramp;
    NRobustness = length(Start);
    
    % Error if the dimensions don't match
    if NRobustness ~= length(End)
       error('Robustness vectors are not the same length!');
    end
    
    % Generate edge deviation vector
    DeviationVectors = zeros(NRobustness, MaxIterations);
    for ii = 1:NRobustness
       DeviationVectors(ii, 1:Ramp) = linspace(Start(ii), End(ii), Ramp);
       DeviationVectors(ii, (Ramp+1):end) = End(ii);
    end
    
    % Generate corresponding thresholding values
    ThresholdVectors = 0.5*(1-erf(DeviationVectors/OptParm.Optimization.Filter.BlurRadius));
end