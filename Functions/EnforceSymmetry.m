% Enforces required symmetries in the pattern
% by folding over midline and averaging
function PatternOut = EnforceSymmetry(PatternIn, SymX, SymY)
    PatternOut = PatternIn;
    % Enforce X symmetry
    if SymX
        PatternOut = 0.5*(PatternOut+flipud(PatternOut));
    end
    
    % Enforce Y symmetry
    if SymY
        PatternOut = 0.5*(PatternOut+fliplr(PatternOut));
    end
end
