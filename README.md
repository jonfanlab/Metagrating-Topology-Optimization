# Topology-Optimization-Code

## Requirements
Matlab 2015b or newer. Older versions may be sufficient but have not been tested.
Reticolo - rigourous coupled wave analysis (RCWA) solver. Can be downloaded from [RETICOLO](https://www.lp2n.institutoptique.fr/Membres-Services/Responsables-d-equipe/LALANNE-Philippe). Copy the folder `reticolo_allege` into the working directory.

## Quick Start
Run `RunOpt.m` with default parameters. The example optimization should begin immediately if all files have been installed corrected.

In `RunOpt.m`, define all optimization parameters as necessary. Descriptions of all parameters can be found in `Functions/Initialize.m` along with their default values.

A schematic of metagrating parameter defintions can be found at [MetaNet](http://metanet.stanford.edu/search/dielectric-metagratings/info/).

## Features
### Robustness

### Parallelization
The optimization method can be parallelized across multiple threads in the case of either two polarizationd devices or robust optimization. In `OptimizeDevice.m`, the `for` loops
```
for robustIter = 1:NRobustness
```
and
```
for polIter = 1:NumPol  
```
can be replaced with `parfor` loops instead. Note that only one of the two loops may be parallelized at a time.
