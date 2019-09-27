% Defines the values of B, the binarization rate, at each iteration
% Plot BVector to see the progression of binarization
function BVector = GenerateBVector(MaxIterations, BinParm)
    % Extract parameters
    BMin = BinParm.Min;
    BMax = BinParm.Max;
    BStart = BinParm.IterationStart;
    BHold = BinParm.IterationHold;
    
    BMid = BMax/20;
    
    BVector = zeros(1,MaxIterations);
    
    Bmult1 = (BMid/BMin)^(1/floor((round(MaxIterations/2)-BStart)/BHold));
    Bmult2 = (BMax/BMid)^(1/floor((round(MaxIterations/2))/BHold));
    
    % The binarization speed is a piecewise function
    BVector((BStart+1):round(MaxIterations/2)) = BMin*Bmult1.^(floor((1:(round(MaxIterations/2)-BStart))/BHold));
    BVector((round(MaxIterations/2)+1):end) = BMid*Bmult2.^(floor((1:(MaxIterations-round(MaxIterations/2)))/BHold));
end