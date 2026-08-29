# Sky130 STA Netlist

This directory contains the technology-mapped netlist used for OpenSTA timing analysis.

## STA Netlist

`riscv_core_sky130_sta.v`

This netlist is derived from the Sky130 HD technology-mapped RISC-V core.

The final STA netlist contains:

- 0 generic Yosys cells
- 0 Verilog ternary operators
- 1526 `sky130_fd_sc_hd__dfxtp_1` flip-flops
- 1603 `sky130_fd_sc_hd__mux2_1` cells
- 652 `sky130_fd_sc_hd__mux4_2` cells
- 122 `sky130_fd_sc_hd__mux2i_1` cells

The STA netlist was prepared so that OpenSTA can parse the synthesized design using Sky130 standard-cell definitions.

## Baseline STA

Constraints:

`constraints/riscv_core.sdc`

STA script:

`sta/run_sta.tcl`

Technology:

- Sky130 HD
- TT
- 0.25C
- 1.80V

Clock target:

- Period: 10 ns
- Frequency: 100 MHz

Baseline OpenSTA result:

- Worst setup slack: -7.460 ns
- Worst hold slack: +0.410 ns

The baseline setup timing therefore violates the 100 MHz target and will be used as the reference point for subsequent optimization.
