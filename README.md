# 32-bit RISC-V Pipelined Processor — RTL, Synthesis & PPA Optimization

A 32-bit, five-stage in-order RISC-V processor taken from an architecture-correct RTL baseline through verification, Sky130 synthesis, static timing analysis, and targeted RTL-level PPA optimization.

The final optimization achieved a **29.53% reduction in critical-path delay with only 0.98% area overhead** versus the verified baseline.

> **Project scope:** RTL design and verification → synthesis → Sky130 HD technology mapping → OpenSTA timing analysis → RTL PPA optimization.
>
> Physical design (floorplanning, placement, CTS, routing, DRC/LVS) is intentionally outside the scope of this project.

---

## Final Result

### Baseline → Final EXP4

| Metric | Baseline | Final EXP4 | Improvement |
|---|---:|---:|---:|
| **Critical delay** | 17.305 ns | **12.196 ns** | **29.53% ↓** |
| **WNS** | -7.371 ns | **-2.343 ns** | **5.028 ns better** |
| **Cell count** | 7,502 | **7,353** | **1.99% ↓** |
| **Area** | 77,385.47 µm² | **78,146.20 µm²** | **0.98% ↑** |
| **Hold slack** | — | **+0.385 ns** | **MET** |

The final implementation therefore delivers approximately **30% critical-timing improvement for less than 1% area overhead**.

The final design remains setup-time limited at the 10 ns clock target, but the critical-path violation was substantially reduced.

---

## Architecture

The processor uses a conventional five-stage in-order pipeline:

```text
        ┌────┐   ┌────┐   ┌────┐   ┌─────┐   ┌────┐
        │ IF │ → │ ID │ → │ EX │ → │ MEM │ → │ WB │
        └────┘   └────┘   └────┘   └─────┘   └────┘
           │        │        │         │         │
          IF/ID    ID/EX    EX/MEM    MEM/WB    RegFile
```

Pipeline registers:

```text
IF/ID → ID/EX → EX/MEM → MEM/WB
```

### Core hierarchy

```text
soc_top
├── instruction_memory
└── riscv_core
    ├── instruction_fetch_unit
    │   └── if_id_reg
    ├── instruction_decode_unit
    │   ├── control_unit
    │   ├── register_file
    │   └── id_ex_reg
    ├── execution_unit
    │   ├── forwarding_unit
    │   ├── alu_unit
    │   └── ex_mem_reg
    └── mem_wb_reg
```

`riscv_core` is the synthesis boundary. `soc_top` provides the simulation/integration wrapper and instruction-memory integration.

Detailed interface and pipeline contracts are documented in [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## What Was Implemented

### Pipeline and control

- Five-stage in-order pipeline
- Explicit decode-to-EX control generation
- Pipeline-valid and retirement metadata
- Redirect handling and pipeline flushing
- EX/MEM and MEM/WB forwarding
- Branch and JALR forwarding support
- WB-to-ID register-file bypass

### Instruction support and correctness

- Arithmetic and logical operations
- Immediate operations including ORI
- Logical and arithmetic shifts with five-bit shift amounts
- Conditional branches including signed and unsigned comparisons
- BGE semantics
- JAL and JALR
- Correct JALR target handling

### Memory subsystem

- Explicit instruction-memory interface
- Explicit data-memory interface
- Single-cycle, zero-wait-state data-memory contract
- LB/LBU/LH/LHU/LW
- SB/SH/SW
- Load sign/zero extension
- Store byte-enable generation
- Forwarded store data
- Load/writeback integration

### Verification

The project uses self-checking directed RTL regressions with Icarus Verilog.

Verification coverage includes:

- ALU behavior
- Branch behavior
- Forwarding
- Pipeline execution
- Memory decode and integration
- Load extraction
- Load/writeback
- Memory safety
- End-to-end memory behavior

The final EXP4 regression completed successfully with `TEST_PASS`.

See [`VALIDATION.md`](VALIDATION.md) for the validation methodology and acceptance criteria.

---

## RTL PPA Optimization

M4 was performed as a sequence of targeted RTL experiments. Each experiment was evaluated using functional regression, Sky130 synthesis, area measurement, and OpenSTA timing analysis.

### Optimization progression

```text
Verified Baseline
      │
      ▼
    EXP2
Unified arithmetic datapath
      │
      ▼
    EXP3
PC / branch-target adder optimization
      │
      ▼
    EXP4 ★ FINAL
Arithmetic critical-path optimization
```

### PPA progression

| Version | Optimization focus | Critical delay | WNS | Area | Cells |
|---|---|---:|---:|---:|---:|
| Baseline | Verified reference | 17.305 ns | -7.371 ns | 77,385.47 µm² | 7,502 |
| EXP2 | Unified ADD/SUB/ADDI datapath | 14.693 ns | -4.816 ns | 79,571.32 µm² | 7,694 |
| EXP3 | PC/branch-target adder | 12.817 ns | -2.930 ns | 82,277.66 µm² | 7,546 |
| **EXP4** | **Final arithmetic optimization** | **12.196 ns** | **-2.343 ns** | **78,146.20 µm²** | **7,353** |

### EXP2 — Unified arithmetic datapath

ADD, SUB, and ADDI were consolidated around a shared two's-complement arithmetic formulation:

```text
ADD  : A + B
SUB  : A + ~B + 1
ADDI : A + immediate
```

The arithmetic operand is selected between the register operand and immediate, while subtraction is controlled through operand inversion and carry-in.

Details are documented in [`docs/M4_EXP2_PPA_CHECKPOINT.md`](docs/M4_EXP2_PPA_CHECKPOINT.md).

### EXP3 — PC / branch-target optimization

The critical path migrated to PC + immediate target generation. A dedicated carry-select style target adder was introduced while retaining the JALR datapath optimization.

This reduced the critical delay to **12.817 ns**.

Details are documented in [`docs/M4_EXP3_PPA_CHECKPOINT.md`](docs/M4_EXP3_PPA_CHECKPOINT.md).

### EXP4 — Final optimization

EXP4 targeted the arithmetic carry chain exposed after EXP3.

A dedicated `arithmetic_adder` module was introduced in `rtl/arithmetic_adder.v`, using 8-bit arithmetic blocks with carry-select behavior for upper blocks. The ALU instantiates this dedicated arithmetic datapath for the unified ADD/SUB/ADDI operation.

EXP4 reduced the critical delay from **12.817 ns to 12.196 ns** while also reducing measured area from **82,277.66 µm² to 78,146.20 µm²** relative to EXP3.

**EXP4 is the final M4 optimization. No further RTL optimization is part of this project.**

The complete final checkpoint is [`docs/M4_FINAL_OPTIMIZATION_EXP4_CHECKPOINT.md`](docs/M4_FINAL_OPTIMIZATION_EXP4_CHECKPOINT.md).

---

## ASIC-Oriented Evaluation Flow

The design was evaluated using a reproducible RTL-to-gate flow:

```text
RTL
 │
 ▼
Icarus Verilog
Functional regression
 │
 ▼
Yosys
RTL synthesis
 │
 ▼
Sky130 HD
Technology mapping
 │
 ▼
Mapped netlist
 │
 ▼
OpenSTA
Static timing analysis
 │
 ▼
PPA evaluation
```

### Tools

| Tool | Purpose |
|---|---|
| **Icarus Verilog** | RTL simulation and regression |
| **Yosys** | Synthesis and technology mapping |
| **OpenSTA** | Static timing analysis |
| **Sky130 HD** | Target standard-cell library |

Target library:

```text
sky130_fd_sc_hd
```

Characterization corner:

```text
TT
0.25°C
1.80 V
```

Timing target:

```text
Clock period: 10 ns
Target frequency: 100 MHz
```

Timing constraints are maintained in [`constraints/riscv_core.sdc`](constraints/riscv_core.sdc).

---

## Reproduce the RTL Regression

From the repository root:

```bash
make clean
make test
```

The self-checking regression must finish with:

```text
TEST_PASS
```

The synthesis and STA directories contain the scripts and artifacts used for the ASIC-oriented evaluation.

---

## Repository Structure

```text
.
├── README.md
├── ARCHITECTURE.md
├── VALIDATION.md
├── Makefile
│
├── rtl/                         # Processor RTL
├── tb/                          # Self-checking testbenches
├── constraints/                 # Timing constraints
│
├── synthesis/                   # Yosys synthesis flows
├── sta/                         # OpenSTA flows, mappings and results
├── netlist/                     # Technology-mapped netlists
├── scripts/                    # Supporting analysis scripts
│
└── docs/                        # Optimization checkpoints
    ├── M4_EXP2_PPA_CHECKPOINT.md
    ├── M4_EXP3_PPA_CHECKPOINT.md
    └── M4_FINAL_OPTIMIZATION_EXP4_CHECKPOINT.md
```

---

## Engineering Documentation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — processor hierarchy, interfaces, memory contract and pipeline organization
- [`VALIDATION.md`](VALIDATION.md) — validation methodology and acceptance criteria
- [`docs/M4_EXP2_PPA_CHECKPOINT.md`](docs/M4_EXP2_PPA_CHECKPOINT.md) — EXP2 optimization and PPA results
- [`docs/M4_EXP3_PPA_CHECKPOINT.md`](docs/M4_EXP3_PPA_CHECKPOINT.md) — EXP3 optimization and PPA results
- [`docs/M4_FINAL_OPTIMIZATION_EXP4_CHECKPOINT.md`](docs/M4_FINAL_OPTIMIZATION_EXP4_CHECKPOINT.md) — final M4 results and closure

---

## Project Status

```text
RTL architecture & control       ✓ Complete
Memory subsystem                 ✓ Complete
RTL verification                 ✓ Complete
Sky130 synthesis                 ✓ Complete
Static timing analysis           ✓ Complete
RTL PPA optimization             ✓ Complete
Physical design                  — Out of scope
```

### Final project result

**29.53% critical-delay reduction**

**0.98% area overhead**

**1.99% fewer mapped cells**

**Functional regression: PASS**

The project is complete at the RTL/synthesis/STA optimization stage.
