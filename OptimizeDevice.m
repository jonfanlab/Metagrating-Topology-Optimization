% Single wavelength deflector optimization
% See Initialize() for definitions of parameters in OptParm
function OptOut = OptimizeDevice(OptParm)

%Extract common values for easier use
Wavelength = OptParm.Input.Wavelength;
Period = OptParm.Geometry.Period;
nBot = OptParm.Geometry.Substrate;
nTop = OptParm.Geometry.Top;
nDevice = OptParm.Geometry.Device;
MaxIterations = OptParm.Optimization.Iterations;

%Compute incident k-vector
kParallelForward = nBot*sind(OptParm.Input.Theta);

% Compute total Fourier orders
NFourier = ceil(OptParm.Simulation.Fourier.*Period/Wavelength);

% Define polarization values
if strcmp(OptParm.Input.Polarization,'TE') 
    Polarizations = 1;
elseif strcmp(OptParm.Input.Polarization,'TM')
    Polarizations = -1;
elseif strcmp(OptParm.Input.Polarization,'Both')
    Polarizations = [1, -1];
else
    error('Invalid polarization');
end
NumPol = length(Polarizations); 

% Define grid for the device
[xGrid, yGrid, GridScale] = DefineGrid(OptParm.Simulation.Grid, Period, Wavelength);
Nx = length(xGrid); %Number of x grid points
Ny = length(yGrid); %Number of y grid points

% If no starting point is given, generate a random starting point
if isempty(OptParm.Optimization.Start)
    DevicePattern = RandomStart(Nx,Ny,Period,...
        OptParm.Optimization.RandomStart,OptParm.Geometry.SymmetryX,OptParm.Geometry.SymmetryY);
else % Else regrid and use given starting point
    DeviceIn = OptParm.Optimization.Start;
    DevicePattern = FineGrid(DeviceIn,Period,[Nx Ny]./size(DeviceIn),0,1); 
end
StartPattern = DevicePattern;

% Define full device stack
DeviceProfile = {[0,OptParm.Geometry.Thickness,0],[1,3,2]}; % See Reticolo documentaion for definitions

% Generate binarization parameter B
BVector = GenerateBVector(MaxIterations, OptParm.Optimization.Binarize);

% Generate thresholding parameters for robustness
[ThresholdVectors, NRobustness] = GenerateThreshVectors(OptParm);

% Compute blur radii in grid units
BlurGridLarge = OptParm.Optimization.Filter.BlurRadiusLarge/GridScale;
BlurGrid = OptParm.Optimization.Filter.BlurRadius/GridScale;
Figs = [];
% Initializing plot for geometries
if OptParm.Display.PlotGeometry 
    Figs.FigGeo = figure;
end

% Initializing plot for geometries
if OptParm.Display.PlotEfficiency
    Figs.FigEff = figure;
end

% Store efficiency at each iteration
AbsoluteEfficiency = zeros(MaxIterations,NRobustness,NumPol);
RelativeEfficiency = zeros(MaxIterations,NRobustness,NumPol);

iterStart = 1;
% Load checkpoint file if exists
if OptParm.Checkpoint.Enable
    CheckpointFile = OptParm.Checkpoint.File;
    if exist(CheckpointFile, 'file')
        load(CheckpointFile);
        iterStart = iter;
    end
end

%Initialize Reticolo
retio([],inf*1i);

%Main optimization loop
for iter = iterStart:MaxIterations
    
    % Save checkpoint file if appropriate
    if OptParm.Checkpoint.Enable && (mod(iter, OptParm.Checkpoint.Frequency) == 0)
        save(CheckpointFile);
    end
    tic;
    
    % First filter to enforce binarization
    FilteredPattern = DensityFilter2D(DevicePattern,BlurGridLarge);
    BinaryPattern = ThreshFilter(FilteredPattern,BVector(iter),0.5);
  
    GradientsAll = cell([NRobustness, 1]);
    DispPattern = cell([NRobustness, 1]);
    
    % Begin robustness loop
    % Can be changed to parfor as necessary
    for robustIter = 1:NRobustness
        % Second filter to model physical edge deviations
        FilteredPattern2 = GaussFilter2D(BinaryPattern,BlurGrid);
        FinalPattern = ThreshFilter(FilteredPattern2,BVector(iter),ThresholdVectors(robustIter, iter));
        DispPattern{robustIter} = FinalPattern;
        % Define textures for each layer
        LayerTextures = cell(1,3);
        LayerTextures{1} = {nTop};
        LayerTextures{2} = {nBot};
        nPattern = FinalPattern*(nDevice - nTop) + nTop;
        LayerTextures{3} = FractureGeom(nPattern,nTop,nDevice,xGrid,yGrid);

        % Initialize empty field matrix
        FieldProductWeighted = zeros(NumPol,OptParm.Simulation.ZGrid,Nx,Ny);
        
        % Begin polarization loop
        % Can be changed to parfor as necessary
        for polIter = 1:NumPol  
            % Set simulation parameters in Reticolo
            ReticoloParm = SetReticoloParm(OptParm, Polarizations, polIter);

            % res1 computes the scattering matrices of each layer
            LayerResults = res1(Wavelength,Period,LayerTextures,NFourier,kParallelForward,0,ReticoloParm);

            % res2 computes the scattering matrix of the full device stack
            DeviceResults = res2(LayerResults,DeviceProfile);

            if OptParm.Optimization.Target(polIter) == 0 && OptParm.Input.Theta == 0
                FieldConvention = -1; % For normal output, opposite sign convention
            else
                FieldConvention = 1;
            end

            if (Polarizations(polIter)==1) %For TE polarization
                % Extract simulation results
                TransmittedLight = DeviceResults.TEinc_bottom_transmitted;
                
                % Find appropriate target
                TargetIndex = find((TransmittedLight.order(:,1)==OptParm.Optimization.Target(polIter))&(TransmittedLight.order(:,2)==0));
                
                % Store efficiencies
                AbsEff = TransmittedLight.efficiency_TE(TargetIndex);
                RelativeEfficiency(iter,robustIter,polIter) = TransmittedLight.efficiency_TE(TargetIndex)/sum(sum(TransmittedLight.efficiency));
    
                % Compute input field for adjoint simulation
                AdjointIncidence = [0,FieldConvention*exp(1i*angle(conj(TransmittedLight.amplitude_TE(TargetIndex))))];
                normalization = sqrt(2/3); % Normalize field for polarizations

                % res3 computes internal fields for each layer
                [ForwardField,~,~] = res3(xGrid,yGrid,LayerResults,DeviceProfile,[0,1],ReticoloParm);
                
            elseif (Polarizations(polIter)==-1) %For TM polarization
                % Extract simulation results
                TransmittedLight = DeviceResults.TMinc_bottom_transmitted;
                
                % Find appropriate target and store efficiencies
                TargetIndex = find((TransmittedLight.order(:,1)==OptParm.Optimization.Target(polIter))&(TransmittedLight.order(:,2)==0));
                AbsEff = TransmittedLight.efficiency_TM(TargetIndex);
                RelativeEfficiency(iter,robustIter,polIter) = TransmittedLight.efficiency_TM(TargetIndex)/sum(sum(TransmittedLight.efficiency));
                
                % Compute input field for adjoint simulation
                AdjointIncidence = [-FieldConvention*exp(1i*angle(conj(TransmittedLight.amplitude_TM(TargetIndex)))),0];
                normalization = (3/2)*sqrt(2/3); % Normalize field for polarizations

                % res3 computes internal fields for each layer
                [ForwardField,~,~] = res3(xGrid,yGrid,LayerResults,DeviceProfile,[1,0],ReticoloParm);
            end

            kParallelAdjoint = -TransmittedLight.K(TargetIndex,1); % Get appropriate adjoint k vector
            ReticoloParm.res3.sens = 1; % Reverse illumination direction

            % Recompute layer scattering matrices for reverse direction
            LayerResults = res1(Wavelength,Period,LayerTextures,NFourier,kParallelAdjoint,0,ReticoloParm);

            % Compute adjoint internal field
            [AdjointField,~,RefractiveIndex] = res3(xGrid,yGrid,LayerResults,DeviceProfile,AdjointIncidence,ReticoloParm);
            
            % Begin to compute 3D gradient by overlap of forward and adjoint fields
            FieldProduct = ForwardField(:,:,:,1).*AdjointField(:,:,:,1) + ...
                ForwardField(:,:,:,2).*AdjointField(:,:,:,2) + ForwardField(:,:,:,3).*AdjointField(:,:,:,3);
            
            % Weight field overlap by refractive index and efficiency
            FieldProductWeighted(polIter,:,:,:) = 0.5*normalization*RefractiveIndex.*FieldProduct.*(1-AbsEff);
            AbsoluteEfficiency(iter,robustIter,polIter) = AbsEff;

        end

        % Compute raw gradient for each pattern averaged over polarization
        FieldAll = 2*squeeze(mean(sum(FieldProductWeighted,1),2));
        Gradient = real(-1i*FieldAll);

        % Back propagate gradient through robustness filters
        Gradient = GaussGrad2D(Gradient,FilteredPattern2,BVector(iter),ThresholdVectors(robustIter, iter),BlurGrid);
        Gradient = FilteredGrad2D(Gradient,FilteredPattern,BVector(iter),0.5,BlurGridLarge);
        GradientsAll{robustIter} = Gradient;
    end
    
    % Sum gradient over all robustness variants
    Gradients=zeros(size(DevicePattern));
    for robustIter = 1:NRobustness
        Gradients= Gradients + GradientsAll{robustIter};
    end
    Gradient = Gradients;
    Gradient = EnforceSymmetry(Gradient, OptParm.Geometry.SymmetryX, OptParm.Geometry.SymmetryY);
    
    % Normalize gradient to step size
    CurrStepSize = OptParm.Optimization.Gradient.StepSize*OptParm.Optimization.Gradient.StepDecline^iter;
    Gradient = CurrStepSize*Gradient/max(max(abs(Gradient))); 

    % Ensure final device will stay between 0 and 1
    % Remove unusable terms from normalization
    Gradient((Gradient+DevicePattern)>1) = 1-DevicePattern((Gradient+DevicePattern)>1);
    Gradient((DevicePattern+Gradient)<0) = -DevicePattern((DevicePattern+Gradient)<0);

    Gradient = CurrStepSize*Gradient/max(max(abs(Gradient))); % Re-normalize gradient

    % Add gradient to device
    DevicePattern = DevicePattern + Gradient;

    % Ensure valid geometry
    DevicePattern = EnforceSymmetry(DevicePattern, OptParm.Geometry.SymmetryX, OptParm.Geometry.SymmetryY);
    DevicePattern(DevicePattern<0) = 0;                                              
    DevicePattern(DevicePattern>1) = 1;
    
    % Apply blur if necessary
    DevicePattern = BlurGeomPostGrad(DevicePattern, iter, OptParm, GridScale);
    
    [~,RobustInd] = min(abs(OptParm.Optimization.Robustness.EndDeviation));
    ShowProgress(OptParm, {xGrid,yGrid}, DispPattern{RobustInd}, iter, MaxIterations, AbsoluteEfficiency, RelativeEfficiency, Figs)
    toc;
end
% Compute different pattern varients
FilteredPattern = DensityFilter2D(DevicePattern,BlurGridLarge);
BinaryPattern = ThreshFilter(FilteredPattern,BVector(iter),0.5);
FilteredPattern2 = GaussFilter2D(BinaryPattern,BlurGrid);
FinalPattern = ThreshFilter(FilteredPattern2,BVector(iter),0.5);

% Save outputs
OptOut.BasePattern = DevicePattern;
OptOut.BinaryPattern = FilteredPattern;
OptOut.FinalPattern = FinalPattern;
OptOut.StartPattern = StartPattern;
OptOut.AbsoluteEfficiency = AbsoluteEfficiency;
OptOut.RelativeEfficiency = RelativeEfficiency;
end