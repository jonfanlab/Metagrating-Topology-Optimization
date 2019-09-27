% Computes the base pattern gradient from the density and threshold
% filtered gradient
function GradientOut = FilteredGrad2D(GradientIn,PatternIn,Bin,Midpoint,Radius)

% Compute the derivative of the threshold filter
% Threshold filter is a piecewise function centered around the Midpoint
if Bin~=0
    PatternLow = Bin*(exp(-Bin*(1-PatternIn/Midpoint)))+exp(-Bin);
    PatternHigh = exp(-Bin) + Bin*exp(-Bin*(PatternIn-Midpoint)/(1-Midpoint));
else
    PatternLow = ones(size(PatternIn))/(2*Midpoint);
    PatternHigh = ones(size(PatternIn))/(2*(1-Midpoint));
end

% Combine the two pieces of the threshold derivative
PatternLow(PatternIn>Midpoint) = 0;
PatternHigh(PatternIn<=Midpoint) = 0;
PatternDeriv = PatternLow + PatternHigh;

% Apply chain rule
Gradient = PatternDeriv.*GradientIn;

% Chain rule of the DensityFilter is another DensityFilter
GradientOut = DensityFilter2D(Gradient,Radius);
end