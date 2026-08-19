# Redone Milestone 1 change inventory

## Architecture correction

- Removed the input-only `top` synthesis boundary.
- Created `riscv_core` as the reusable and authoritative synthesis top.
- Created `soc_top` as the memory-backed simulation wrapper.
- Removed instruction memory from the fetch unit.
- Added instruction, reserved data-memory, and retirement interfaces.
- Added valid, PC, and instruction metadata through the pipeline.

## Edited Verilog files relative to the original project

- `rtl/alu.v`
- `rtl/control_unit.v`
- `rtl/ex_mem_reg.v`
- `rtl/execution_unit.v`
- `rtl/id_ex_reg.v`
- `rtl/if_id_reg.v`
- `rtl/instruction_decode_unit.v`
- `rtl/instruction_fetch_unit.v`
- `rtl/instruction_memory.v`
- `rtl/mem_wb_reg.v`
- `rtl/register_file.v`
- `tb/tb_top.v`

## Removed/replaced Verilog file

- `rtl/top.v` — replaced by separate `riscv_core.v` and `soc_top.v`

## Newly created RTL/test files

- `rtl/riscv_core.v`
- `rtl/soc_top.v`
- `rtl/forwarding_unit.v`
- `tb/tb_top_selfcheck.v`

## Newly created project files

- `Makefile`
- `ARCHITECTURE.md`
- `CODING_STYLE.md`
- `UPGRADE_M1.md`
- `VALIDATION.md`
- `synthesis/README.md`

## Deliberately deferred to Milestone 2

- Load/store decode and data path
- Active data-memory requests
- Load-use hazard detection and stalling
- LUI and AUIPC
- Latency-tolerant memory handshakes

## Coding style rewrite

- Every Verilog module uses a non-ANSI module port list.
- Inputs and outputs are declared separately below the module declaration.
- Named port connections are vertically aligned in module instances.
- Combinational and sequential blocks use the original indentation and
  explicit `begin`/`end` structure.
- Comments are limited to instruction groups, interfaces, and test intent.
