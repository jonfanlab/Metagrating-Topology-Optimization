%Gaussian weighted averaging within radius Sigma
function PatternOut = GaussFilter2D(PatternIn,Sigma)
    PatternOut = imgaussfilt(PatternIn, Sigma, 'padding', 'circular');
end