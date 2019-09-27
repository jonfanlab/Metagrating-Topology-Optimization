% Transfers the pattern onto a finer/coarser grid specifid by the scaling
% factor Scale
function [PatternOut,XOut,YOut] = FineGrid(PatternIn,Period,Scale,Binarize,SmoothGeom)

Pattern = PatternIn;
[Nx, Ny] = size(PatternIn); % Size of input pattern

% Compute size of output pattern
NScaled = round(Scale.*[Nx Ny]);
NxScaled = NScaled(1);
NyScaled = NScaled(2);

% Blur pattern if option is specfied
if SmoothGeom == 1
    Pattern = imgaussfilt(Pattern,Ny/50,'Padding','circular');
end

% Add extra pixels in order to allow for periodic interpolation
Pattern = [Pattern(:,end),Pattern];
Pattern = [Pattern(end,:);Pattern];

% Input grid
[X,Y] = meshgrid(0:Nx,0:Ny);

% Scaled grid
[XScaled,YScaled] = meshgrid(linspace(Nx/NxScaled,Nx,NxScaled),...
    linspace(Ny/NyScaled,Ny,NyScaled));

% Output coordinates
[XOut,YOut] = meshgrid(linspace(0,Period(1),NxScaled),...
    linspace(0,Period(2),NyScaled));

if SmoothGeom == 1
    % Use interpolation if smooth geometry is desired
    PatternOut = interp2(X,Y,Pattern',XScaled,YScaled,'cubic')';
else
    % Place pixels on a square grid otherwise
    PatternOut = zeros([NxScaled NyScaled]);
    for ii = 1:NxScaled
        for jj = 1:NyScaled
            PatternOut(ii,jj) = Pattern(ceil(ii*Nx/NxScaled),...
                ceil(jj*Ny/NyScaled));
        end
    end
end

%Binarize if desired
if Binarize==1
    PatternOut(PatternOut<0.5) = 0;
    PatternOut(PatternOut>=0.5) = 1;
end
end