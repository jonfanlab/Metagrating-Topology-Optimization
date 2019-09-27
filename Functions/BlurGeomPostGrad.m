% Apply blurring filters when specificed in OptParm
function DevicePattern = BlurGeomPostGrad(DevicePattern, iter, OptParm, GridScale)  
    MaxIterations = OptParm.Optimization.Iterations;
    
    % Large blur every X iterations
    if ((mod(iter,OptParm.Optimization.Filter.BlurLargeIter)==0)&&(iter<(MaxIterations - OptParm.Optimization.Filter.BlurLargeIterStop)))
        FilterLarge = fspecial('disk',0.5*floor(OptParm.Optimization.Filter.BlurRadiusLarge/GridScale));
        DevicePattern = imfilter(DevicePattern,FilterLarge,'circular');
        
    % Small blur every Y iterations
    elseif ((mod(iter,OptParm.Optimization.Filter.BlurSmallIter)==0)&&(iter<(MaxIterations - OptParm.Optimization.Filter.BlurSmallIterStop)))
        FilterSmall = fspecial('disk',OptParm.Optimization.Filter.BlurRadiusSmall/GridScale);
        DevicePattern = imfilter(DevicePattern,FilterSmall,'circular');
    end
end