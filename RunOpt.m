close all
clear all
addpath('Functions')

% Initialize optimization parameters
% Default values and descriptions found in 'Functions/Initialize.m'
OptParm = Initialize();

% Defines target output angle
target_angle = 50;

% Device parameters
OptParm.Input.Wavelength = 1050;
OptParm.Input.Polarization = 'TM';
OptParm.Optimization.Target = [1];
OptParm.Geometry.Thickness = 325; % Device layer thickness

% Compute necessary period corresponding to target angle
period = [OptParm.Input.Wavelength*OptParm.Optimization.Target/(sind(target_angle)-sind(OptParm.Input.Theta)),0.5*OptParm.Input.Wavelength];
OptParm.Geometry.Period = period;

% Define # of Fourier orders
OptParm.Simulation.Fourier = [12 12];

% Run robust optimization
OptParm.Optimization.Robustness.StartDeviation = [-5 0 5]; % Starting edge deviation values
OptParm.Optimization.Robustness.EndDeviation = OptParm.Optimization.Robustness.StartDeviation; % Ending edge deviation values
OptParm.Optimization.Robustness.Weights = [.5 1 .5];

% Plot efficiency history
OptParm.Display.PlotEfficiency = 1;

% Run optimizations
optout = OptimizeDevice(OptParm)
