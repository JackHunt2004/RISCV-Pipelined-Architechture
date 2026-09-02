# Sky130 STA Mapping References

These mapping files are preserved as references for preparing Yosys-generated
netlists for OpenSTA using the Sky130 HD standard-cell library.

## DFF mapping

`sky130_dff_map.v`

Maps Yosys generic `$dff` cells to:

`sky130_fd_sc_hd__dfxtp_1`

This was validated on the synthesized RISC-V netlist after:

- `read_verilog`
- `hierarchy`
- `proc`
- `techmap -map sky130_dff_map.v`
- `opt`

Validated result:

- `$dff`: 0
- `sky130_fd_sc_hd__dfxtp_1`: 1526

The mapping is used because OpenSTA cannot directly parse the generic
Yosys `$dff` representation.

## MUX mapping

`sky130_mux_map.v`

Maps parameterized Yosys `$mux` cells to:

`sky130_fd_sc_hd__mux2_1`

The mapping is width-aware and generates one Sky130 mux cell per bit.

## Important warning

Do NOT apply the MUX mapping to a netlist that is already Sky130
technology-mapped.

The synthesized baseline and EXP2 netlists already contain Sky130 cells,
including:

- `sky130_fd_sc_hd__mux2_1`
- `sky130_fd_sc_hd__mux2i_1`
- `sky130_fd_sc_hd__mux4_2`

Running another generic MUX technology-mapping pass on these already-mapped
netlists caused an artificial increase in `mux2_1` cells and changed the
structure of the design.

Therefore:

- Use these mapping files only when the corresponding generic Yosys cells
  actually exist.
- Do not re-techmap an already Sky130-mapped combinational netlist.
- The saved STA netlists in `netlist/sta/` are the structurally faithful
  reference netlists for the current baseline and EXP2 STA work.

## Current saved STA netlists

- `netlist/sta/riscv_core_baseline_sta.v`
- `netlist/sta/riscv_core_exp2_sta.v`

These should be used directly for the current apples-to-apples OpenSTA
comparison.
