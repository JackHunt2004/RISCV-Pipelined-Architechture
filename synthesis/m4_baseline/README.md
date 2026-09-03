# M4 ASIC Synthesis Flow

This directory contains the verified synthesis flow used to generate the
official M4 Sky130 baseline netlist.

## Authoritative Synthesis Top

The authoritative synthesis top is:

    riscv_core

Do not synthesize `soc_top` for core PPA reporting.

## Verified Toolchain

- Yosys 0.33
- Sky130 HD standard-cell library
- TT / 0.25C / 1.80V Liberty
- ABC technology mapping
- `dfflibmap` sequential-cell mapping

## Verified Flow

The synthesis sequence is:

    read_verilog -Irtl rtl/*.v

    hierarchy -top riscv_core

    proc
    memory
    opt

    techmap
    opt

    dfflibmap -liberty <SKY130_LIB>
    abc -liberty <SKY130_LIB>

    opt

    stat -liberty <SKY130_LIB>

    check

    write_verilog -noattr <mapped_netlist>

The exact executable flow is stored in:

    run_yosys.tcl

## Important: Generic Sequential Cells

The initial synthesis flow produced generic Yosys sequential cells such as:

    $_DFFE_PP_
    $_SDFFE_PP0P_
    $_SDFF_PP0_
    $_SDFF_PP1_

These cells were removed from the final mapped implementation by adding:

    dfflibmap -liberty <SKY130_LIB>

before ABC.

This step is required for the verified M4 flow.

## Verification

After synthesis, check for generic sequential cells:

    grep -oE '\$_[A-Za-z0-9_]+' <mapped_netlist> | sort | uniq -c

The official mapped M4 netlists should produce no output.

## Generic Mux / STA Lesson

Earlier STA experiments encountered generic `$mux` structures and required
manual structural mux conversion for that experimental flow.

The current authoritative Yosys synthesis flow produces fully technology-
mapped Sky130 combinational logic without generic `$mux` cells.

Therefore the historical mux-conversion workaround is not required for the
current official M4 flow.

## Area Measurement

The baseline-specific area utility is:

    calculate_area.py

The reusable M4 area utility is:

    scripts/calculate_netlist_area.py

Area must be calculated using the same Sky130 Liberty file and the same
measurement methodology for every PPA comparison.

## Reproducibility

From the repository root:

    yosys -s synthesis/m4_baseline/run_yosys.tcl

The generated baseline netlist is:

    netlist/m4_baseline/riscv_core_baseline_m4.v

For future optimizations, use the same synthesis sequence unless the
experiment explicitly tests a synthesis-flow change.
