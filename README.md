# SCA-secure AEADs

This repository contain an implementation of multiple AEAD algorithms with side-channel countermeasures:

* Triplex (a leakage-resilient AEAD, with Skinny as TBC, see associated paper).
* [Romulus-N](https://romulusae.github.io/romulus/).
* [Ascon](https://ascon.iaik.tugraz.at/).

**These implementations have been designed for algorithm comparison purpose only and have not been practically evaluated.**

## Architecture

Except for Romulus-N, the implementations are leveled: some primitives are
masked (using the [HPC2](https://doi.org/10.1109/TC.2020.3022979) masking
scheme), while others are not masked.

## Usage

The designs have been tested with iverilog (version 10.3).
From the "sim" folder, all ciphers can be simulated (with iverilog) and displayed (with GTKWave) with the following command:

```bash
make sim
```


## License

```
Copyright Corentin Verhamme and UCLouvain, 2022

These implementations are licensed under the CERN-OHL-S v2.

You may redistribute and modify this source and make products using it under
the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).

This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.

Source location: https://github.com/uclcrypto/aead_modes_leveled_hw
```

