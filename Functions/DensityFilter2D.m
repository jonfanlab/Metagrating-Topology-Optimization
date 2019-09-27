% Distance weighted averaging filter of radius R
function PatternOut = DensityFilter2D(PatternIn,Radius)
    % If the radius is less than 1 pixel, no filter can be applied
    if Radius<1
        PatternOut = PatternIn;
    else
        % Define grid
        [X1,X2] = meshgrid(-ceil(Radius):ceil(Radius),-ceil(Radius):ceil(Radius));
        
        % Compute weights
        Weights = Radius - (X1.^2+X2.^2).^(1/2);
        Weights(Weights<0) = 0;
        B = sum(Weights(:));
        
        %Apply filter
        PatternOut = imfilter(PatternIn, Weights/B, 'circular');
    end
end