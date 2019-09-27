% Compute the simulation grid for given geometry
function [xGrid, yGrid, dr] = DefineGrid(Grid, Period, Wavelength)
    
    %Number of grid points
    NGrid = ceil(Grid*Period/Wavelength);
    Nx = NGrid(1);
    Ny = NGrid(2);
    
    %Device period
    Px = Period(1);
    Py = Period(2);
    
    %Compute external grid coordinates
    xBounds = linspace(0,Px,Nx+1); 
    yBounds = linspace(0,Py,Ny+1);
    
    %Compute size of each grid box
    dx = xBounds(2) - xBounds(1);
    dy = yBounds(2) - yBounds(1);
    
    %Compute coordinates of center of each box
    xGrid = xBounds(2:end)- 0.5*dx;
    yGrid = yBounds(2:end)- 0.5*dy;
    
    %Compute average grid size
    dr = mean([dx dy]);
end