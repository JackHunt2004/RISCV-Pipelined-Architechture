# Pipelined RISC-V core — architecture-correct Milestone 1

This revision separates the processor core from the demonstration system before
applying the Milestone 1 control, ISA-semantics, forwarding, and flush repairs.

All Verilog modules follow the original project coding style: ports are listed
in the module declaration and defined separately as inputs or outputs, module
instances use aligned named connections, sequential and combinational blocks
use explicit `begin` and `end`, and comments are limited to important sections.

## Authoritative module boundaries

- `riscv_core` is the reusable processor and the synthesis top.
- `soc_top` is the simulation/integration wrapper.
- `instruction_memory` belongs to `soc_top`; it is not inside the processor.
- `tb_top_selfcheck` is the regression top.

The core now has explicit instruction-memory, reserved data-memory, and
retirement interfaces. The system wrapper exposes observable retirement state,
so the design is no longer an input-only block.

See `ARCHITECTURE.md` for the interface contract and hierarchy.
See `CODING_STYLE.md` for the coding conventions used throughout the project.

## Milestone 1 functionality

- Correct explicit decode-to-EX controls
- Correct SRLI/SRAI, ORI, five-bit shifts, BGE, JAL, and JALR semantics
- Signed and unsigned branch comparisons
- Redirect flushing of IF/ID and ID/EX
- EX/MEM and MEM/WB forwarding, including branches and JALR
- WB-to-ID register-file bypass
- Pipeline-valid and retirement metadata
- Self-checking directed regression

## Run

Requirements: Icarus Verilog (`iverilog` and `vvp`).

```bash
make clean
make test
```

Expected final line:

```text
TEST_PASS: architecture-correct Milestone 1 regression passed
```

## Current scope

The instruction interface is a fixed zero-wait combinational-read contract for
this milestone. The data-memory boundary is explicit but held inactive until
loads, stores, and memory-stage controls are added in Milestone 2.

This is not yet full RV32I. LUI, AUIPC, loads, stores, load-use stalls,
exceptions, and CSRs remain deferred.
