# Metagrating-Topology-Optimization

## Requirements
Matlab 2015b or newer. Older versions may be sufficient but have not been tested.

RETICOLO - rigourous coupled wave analysis (RCWA) solver. Can be downloaded from [RETICOLO](https://www.lp2n.institutoptique.fr/Membres-Services/Responsables-d-equipe/LALANNE-Philippe). Copy the folder `reticolo_allege` into the working directory.

## Quick Start
Run `RunOpt.m` with default parameters. The example optimization should begin immediately if all files have been installed corrected.

In `RunOpt.m`, define all optimization parameters as necessary. Descriptions of all parameters can be found in `Functions/Initialize.m` along with their default values.

A schematic of metagrating parameter defintions can be found at [MetaNet](http://metanet.stanford.edu/search/dielectric-metagratings/info/).

## Features
### Robustness
Robustness parameters, found in `OptParm.Optimization.Robustness`, are accepted as vectors of dynamic length according to the number of robustness simulations used in computing the gradient. Details on robust optimization can be found in this [paper](https://fanlab.stanford.edu/wp-content/papercite-data/pdf/wang2019robust.pdf).

The default robustness parameters of 
```
StartDeviation = [-5 0 5];
Weights = [.5 1 .5];
```
define a gradient derived from a -5nm eroded structure, an unperturbed structure, and a 5nm dilated structure, weighted at 0.5x, 1x, and 0.5x respectively.

Additionally, the magnitude of robustness can be scaled as the optimization progresses between the values defined in `StartDeviation` and `EndDeviation`. The speed of scaling is defined by `Ramp`. For no scaling, `StartDeviation` and `EndDeviation` should be set to the same value.

Additional robustness can be added as desired. i.e.
```
StartDeviation = [-10 -5 0 5 10];
Weights = [.25 .5 1 .5 .25];
```
defines additional simulations with even greater perturbations.


Optimizations without robustness can be specified by
```
StartDeviation = [0];
Weights = [1];
```
### Parallelization
The optimization method can be parallelized across multiple threads in the case of either two polarization devices or robust optimization. In `OptimizeDevice.m`, the `for` loops
```
for robustIter = 1:NRobustness
```
and
```
for polIter = 1:NumPol  
```
can be replaced with `parfor` loops instead. Note that only one of the two loops may be parallelized at a time.
### Checkpointing
Checkpointing saves the state of the optimization and allows the user to stop and start the optimization without losing progress. This behavior is desirable when running shared computing resources where jobs may be preempted without warning.

To enable checkpointing, set `OptParm.Checkpoint.Enable = true` and define a checkpoint file location with `OptParm.Checkpoint.File`. Then, throughout the optimization, the entire optimization state will be saved every few iterations with a frequency defined by `OptParm.Checkpoint.Frequency`.

When restarting a checkpointed optimization, the optimization will attempt to load the file at `OptParm.Checkpoint.File` if it exists, and continue, otherwise the optimization will start from the beginning again.

Warning: Checkpointing may fail if the optimization is terminated while writing to the checkpoint file. 
