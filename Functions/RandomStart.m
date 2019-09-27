
% Breaks the pattern down into cells of size Pitch x Pitch
% Each recieves a random refractive index
% Then the entire pattern is blurred by a gaussian filter
function PatternOut = RandomStart(Nx,Ny,Period,RandParm,SymX,SymY)
    Pitch = RandParm.Pitch;
    RandAverage = RandParm.Average;
    RandSigma = RandParm.Sigma;
    NCellsX = ceil(2*Period(1)/Pitch);
    NCellsY = ceil(2*Period(2)/Pitch);
    GridSize = Period(1)/Nx;

    % Normally distributed index of refractions
    RandomIndices = RandAverage*ones(NCellsX,NCellsY) + RandSigma*randn(NCellsX,NCellsY);
    RandomIndices = EnforceSymmetry(RandomIndices, SymX, SymY);
    
    % Smooth and blur the pattern
    [RandomPattern,~,~] = FineGrid(RandomIndices,Period,[Nx/NCellsX, Ny/NCellsY],0,0);
    DiskFilter = fspecial('disk',1.1*Pitch/GridSize);
    RandomPattern = imfilter(RandomPattern,DiskFilter,'circular');

    % Ensure the pattern is proper
    RandomPattern = EnforceSymmetry(RandomPattern, SymX, SymY);
    RandomPattern(RandomPattern<0) = 0;
    RandomPattern(RandomPattern>1) = 1;

    PatternOut = RandomPattern;
end