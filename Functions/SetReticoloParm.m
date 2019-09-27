% Set parameters used by Reticolo for symmetry and other calculations
function ReticoloParm = SetReticoloParm(OptParm, Polarizations, polIter)
    ReticoloParm = res0;
    if OptParm.Geometry.SymmetryX || OptParm.Geometry.SymmetryY
        ReticoloParm.sym.pol = Polarizations(polIter);
        if OptParm.Geometry.SymmetryX
            ReticoloParm.sym.x = OptParm.Geometry.Period(1)/2;
        end
        if OptParm.Geometry.SymmetryY
            ReticoloParm.sym.y = OptParm.Geometry.Period(2)/2;
        end
    end
    ReticoloParm.res3.npts = [0,OptParm.Simulation.ZGrid,0]; %Number of points to sample field in each layer
    ReticoloParm.res3.sens = -1; % Default to illumination from below
    ReticoloParm.res1.champ = 1; % Accurate fields
end