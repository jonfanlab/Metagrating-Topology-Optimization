% Linear -> step function as Bin increases
% Midpoint is the midpoint of the function
function PatternOut = ThreshFilter(PatternIn,Bin,Midpoint)
    % The threshold filter is a piecewise function centered around Midpoint
    if Bin~=0
        PattNormLow = 1-PatternIn/Midpoint;
        PatternLow = Midpoint*(exp(-Bin*PattNormLow)-PattNormLow*exp(-Bin));

        PattNormHigh = (PatternIn-Midpoint)/(1-Midpoint);
        PatternHigh = Midpoint + (1-Midpoint)*(1-exp(-Bin*PattNormHigh)+PattNormHigh*exp(-Bin));
        
    % For Bin=0, maps Midpoint to .5 and linearly on either side
    elseif Bin==0
        PatternLow = PatternIn/(2*Midpoint);
        PatternHigh = (PatternIn-1)/(2-2*Midpoint)+1;   
    end
    PatternOut = PatternLow.*(PatternIn<=Midpoint) + PatternHigh.*(PatternIn>Midpoint);
end