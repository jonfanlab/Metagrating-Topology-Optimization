% Enforces required symmetries in the pattern
% by folding over midline and averaging
function PatternOut = EnforceSymmetry(PatternIn, SymX, SymY)
    PatternOut = PatternIn;
    % Enforce X symmetry
    if SymX
        PatternOut = 0.5*(PatternIn+flipud(PatternIn));
    end
    
    % Enforce Y symmetry
    if SymY
        PatternOut = 0.5*(PatternIn+fliplr(PatternIn));
    end
end