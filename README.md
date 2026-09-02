# Pipelined RISC-V Core — ASIC Flow & PPA Optimization

A 5-stage pipelined RISC-V processor developed from an architecture-correct RTL baseline and progressively prepared for a complete ASIC implementation flow.

The project covers RTL design, ISA correctness, pipeline control, verification, synthesis, static timing analysis, and PPA optimization using the Sky130 HD standard-cell library.

## Architecture

The processor uses a conventional five-stage pipeline:

```text
IF → ID → EX → MEM → WB
```

The reusable processor is implemented as `riscv_core` and is the synthesis top. `soc_top` provides the simulation/integration wrapper, while `tb_top_selfcheck` is the regression top.

### Authoritative module boundaries

- `riscv_core` — reusable processor and synthesis top
- `soc_top` — simulation/integration wrapper
- `instruction_memory` — belongs to `soc_top`
- `tb_top_selfcheck` — self-checking regression top

See `ARCHITECTURE.md` for the interface contract and hierarchy.
See `CODING_STYLE.md` for RTL coding conventions.

## Completed Architecture Work

### Milestone 1 — Architecture correctness

Completed:

- Explicit decode-to-EX control generation
- Correct SRLI/SRAI semantics
- ORI and five-bit shift semantics
- BGE semantics
- JAL and JALR support
- Signed and unsigned branch comparisons
- Redirect flushing of IF/ID and ID/EX
- EX/MEM and MEM/WB forwarding
- Forwarding support for branches and JALR
- WB-to-ID register-file bypass
- Pipeline-valid and retirement metadata
- Self-checking directed regression

### Milestone 2 — Memory subsystem

Completed:

- Explicit instruction-memory interface
- Explicit data-memory interface
- Memory-stage integration
- Load/store datapath integration
- Memory control propagation through the pipeline
- Regression coverage for memory operations

### Milestone 3 — Synthesis readiness

Completed:

- Architecture and hierarchy cleanup
- RTL lint/sanity checks
- Reproducible synthesis flow
- Sky130 HD technology mapping
- Baseline synthesized netlist
- PPA measurement infrastructure

## ASIC Flow

The project is being evaluated using the Sky130 HD standard-cell library.

### Toolchain

- Yosys — RTL synthesis and technology mapping
- OpenSTA — static timing analysis
- Sky130 HD — target standard-cell library
- Icarus Verilog — RTL simulation and regression

Target library:

```text
sky130_fd_sc_hd
```

Target operating corner:

```text
TT
0.25C
1.80V
```

## M4 — PPA Optimization

Milestone 4 focuses on evaluating targeted RTL optimizations using synthesis and timing results rather than changing the processor architecture.

### EXP2 — Unified arithmetic datapath

The second optimization experiment restructures the ALU arithmetic operations so that ADD, SUB, and ADDI share a single arithmetic datapath.

The implementation uses a unified two's-complement formulation:

```text
ADD  : A + B
SUB  : A + ~B + 1
ADDI : A + immediate
```

The arithmetic operand is selected between `rs2_data` and `imm_val`, while subtraction is controlled through operand inversion and carry-in.

This experiment is intended to reduce duplicated arithmetic-selection logic while preserving the existing architectural behavior.

### EXP2 Area Results

Synthesis was performed against the same Sky130 HD TT library.

| Metric | Baseline | EXP2 | Change |
|---|---:|---:|---:|
| Core area | 39607.9872 | 39482.8672 | **-0.316%** |
| ALU area | 11564.8416 | 11439.7216 | **-1.082%** |
| Mapped cells | 5193 | 5104 | **-1.71%** |

The complete core-area reduction comes from the ALU optimization; the other major blocks remain structurally unchanged.

Cell count is reported as a structural indicator. The area figures above are based on the mapped Sky130 cell areas reported by Yosys.

## Static Timing Analysis

The project is currently establishing a reproducible apples-to-apples OpenSTA comparison between the baseline and EXP2 implementations.

Timing constraint:

```text
Clock period: 10 ns
Target frequency: 100 MHz
```

The saved STA netlists preserve the Sky130-mapped combinational structure and map only the sequential elements required for OpenSTA compatibility.

Current STA preparation flow:

```text
Sky130-mapped TT netlist
        ↓
      proc
        ↓
generic $dff
        ↓
Sky130 dfxtp_1 mapping
        ↓
      opt
        ↓
OpenSTA
```

An additional combinational technology-mapping pass must not be applied to an already Sky130-mapped netlist, as this changes the synthesized structure and can produce artificial mux-cell growth.

### STA artifacts

```text
netlist/
├── riscv_core_baseline_tt.v
├── riscv_core_exp2_tt.v
└── sta/
    ├── riscv_core_baseline_sta.v
    └── riscv_core_exp2_sta.v
```

The baseline and EXP2 STA netlists were structurally verified to contain:

| Cell | Baseline | EXP2 |
|---|---:|---:|
| `dfxtp_1` | 1526 | 1526 |
| `mux2_1` | 75 | 72 |
| `mux2i_1` | 122 | 139 |
| `mux4_2` | 652 | 656 |

Timing results will be used together with the area results to determine the overall PPA impact of EXP2.

## STA Mapping References

Reusable mapping references are maintained under:

```text
sta/mapping/
├── README.md
├── sky130_dff_map.v
└── sky130_mux_map.v
```

`sky130_dff_map.v` provides the validated mapping of generic Yosys `$dff` cells to `sky130_fd_sc_hd__dfxtp_1` cells for OpenSTA preparation.

`sky130_mux_map.v` provides a parameterized mapping for generic Yosys `$mux` cells.

The MUX mapping must only be used when generic `$mux` cells are actually present. It must not be applied to a netlist that is already Sky130 technology-mapped.

See `sta/mapping/README.md` for the detailed mapping notes.

## Repository Structure

```text
rtl/         RTL source
tb/          Testbenches and regression infrastructure
constraints/ Timing constraints
netlist/     Synthesized and STA-prepared netlists
sta/         Synthesis/STA scripts, logs, and mapping references
```

## Verification

RTL regression is run using Icarus Verilog:

```bash
make clean
make test
```

The regression is self-checking and reports a `TEST_PASS` result on success.

## Current Status

```text
M1  Architecture correctness       ✓ Complete
M2  Memory subsystem               ✓ Complete
M3  Synthesis readiness            ✓ Complete
M4  PPA optimization               → In progress
```

### M4 EXP2 status

```text
RTL optimization                  ✓ Complete
Sky130 synthesis                  ✓ Complete
Area comparison                   ✓ Complete
Structurally faithful STA setup   ✓ Complete
Baseline vs EXP2 timing           → Next
PPA evaluation                    → Pending STA
```

## Next Step

Complete the baseline-vs-EXP2 OpenSTA comparison using identical timing constraints and the saved structurally faithful STA netlists.

After the PPA experiment is evaluated, the project will continue toward the remaining ASIC implementation stages, including physical design, signoff timing, DRC/LVS, and final GDS generation.
