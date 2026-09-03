# Netlist Checkpoints

This directory contains technology-mapped Sky130 netlists generated from
verified RISC-V RTL checkpoints.

## M4 Baseline

Path:

    m4_baseline/riscv_core_baseline_m4.v

Source RTL:

    Commit: 580f7ec
    Complete architecture-correct Milestone 1 upgrade

Implementation:

- Top module: `riscv_core`
- Sky130 HD standard-cell library
- TT / 0.25C / 1.80V
- Generated using the verified M4 Yosys synthesis flow
- `dfflibmap` used for sequential-cell mapping
- ABC used for combinational technology mapping

Reference PPA:

- Cells: 7,502
- Cell area: 77,385.4688 µm²
- WNS: -7.371 ns
- Critical-path delay: 17.305 ns

## M4 EXP2

Path:

    m4_exp2/riscv_core_exp2_m4.v

Optimization:

    EXP2 — unified ADD/SUB/ADDI arithmetic datapath

Implementation:

- Top module: `riscv_core`
- Sky130 HD standard-cell library
- TT / 0.25C / 1.80V
- Generated using the same synthesis methodology as the baseline
- `dfflibmap` used for sequential-cell mapping
- ABC used for combinational technology mapping

Reference PPA:

- Cells: 7,694
- Cell area: 79,571.3152 µm²
- WNS: -4.816 ns
- Hold slack: +0.385 ns
- Critical-path delay: 14.693 ns

## Purpose

These netlists are implementation checkpoints used for:

- OpenSTA timing analysis
- Cell-area measurement
- PPA comparison
- Reproducibility
- Debugging and future ASIC-flow work

The netlists should be treated as generated artifacts and should not be
manually edited.

For a new optimization, modify the RTL and regenerate a new checkpoint
netlist using the corresponding synthesis flow.
