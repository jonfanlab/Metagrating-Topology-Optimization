% Divides the given geometry into rectangles to be used in Reticolo
function GeometryOut = FractureGeom(PatternIn,nLow,nHigh,XGrid,YGrid)

% Acceptable refractive index tolerance in fracturing
Tolerance = .01;

% Extract grid parameters
dX = XGrid(2)-XGrid(1);
dY = YGrid(2)-YGrid(1);
[Nx, Ny] = size(PatternIn);

Geometry = {nLow}; %Define background index

% Define the areas with max refractive index (within tolerance)
% For complex values, tests the real part
PatternHigh = (PatternIn >= (nHigh - Tolerance));

% Define areas with higher than background refractive index
PatternElse = (PatternIn > (nLow + Tolerance));

MaxFractures = 2000;
RectCount = 1;

% Divide given PatternHigh geometry into rectangles
while (sum(PatternHigh(:)) > 0) && (RectCount <= MaxFractures)
    [X1,Y1] = find(PatternHigh==1,1);
    Rect = [X1,X1,Y1,Y1];
    
    % Find largest silicon rectangle from inital point
    Fracturing = 1;
    while Fracturing
        % Attempt to expand rectangle in x direction
        if (Rect(2)<Nx)&&(sum(sum(PatternHigh(Rect(2)+1,Rect(3):Rect(4))))==(Rect(4)-Rect(3)+1))
            Rect(2) = Rect(2) + 1;
        
        % Attempt to expand in y direction
        elseif (Rect(4)<Ny)&&(sum(sum(PatternHigh(Rect(1):Rect(2),Rect(4)+1)))==(Rect(2)-Rect(1)+1))
            Rect(4) = Rect(4) + 1;
        else
            Fracturing = 0;
        end
    end
    
    % Remove pixels of fractured areas
    PatternHigh(Rect(1):Rect(2),Rect(3):Rect(4)) = 0;
    PatternElse(Rect(1):Rect(2),Rect(3):Rect(4)) = 0;
    
    %Record size of the rectangle
    dXGrid = 0.5*(XGrid(Rect(1)) + XGrid(Rect(2))); % Grid point size
    dYGrid = 0.5*(YGrid(Rect(3)) + YGrid(Rect(4))); 
    dXLength= dX*(Rect(2)-Rect(1)+1); % Physical Size
    dYLength = dY*(Rect(4)-Rect(3)+1); 
    
    if isequal(Geometry{end},[dXGrid,dYGrid,dXLength,dYLength,nHigh,1])
        disp('Warning: duplicate structure');
        break;
    end
    
    % Add rectangle to list
    Geometry = [Geometry,{[dXGrid,dYGrid,dXLength,dYLength,nHigh,1]}];
    
    RectCount = RectCount + 1;
    if RectCount > (MaxFractures * 0.95)
        disp('Warning: High fracture count');
    end
end

% Fracture non binarized pixels
for i = 1:Nx % Defining texture for patterned layer. Probably could have vectorized this.
    for j = 1:Ny
        if PatternElse(i,j)==1
            % Add each reamaining pixel and its refractive index independently
            Geometry = [Geometry,{[XGrid(i),YGrid(j),dX,dY,PatternIn(i,j),1]}];
        end
    end
end
GeometryOut = Geometry;
end