# M4 EXP3 PPA Checkpoint — Critical-Path PC+Immediate Adder Optimization

## 1. Experiment Overview

**Milestone:** M4 — RTL PPA Optimization  
**Experiment:** EXP3  
**Branch:** `m4-exp3-critical-path`  
**Status:** Retained optimization checkpoint  
**Target:** Improve the remaining critical timing path identified after EXP2.

EXP3 targets the PC + immediate addition used for branch and jump target generation in the execution unit.

---

## 2. Baseline Reference

| Metric | Baseline |
|---|---:|
| Mapped cell count | 7,502 |
| Total cell area | 77,385.4688 µm² |
| Critical-path delay | 17.305 ns |
| Setup WNS | -7.371 ns |
| Clock target | 10 ns / 100 MHz |

Baseline commit: `580f7ec`  
Baseline tag: `milestone-1-verified`

---

## 3. EXP2 Reference

| Metric | EXP2 |
|---|---:|
| Mapped cell count | 7,694 |
| Total cell area | 79,571.3152 µm² |
| Critical-path delay | 14.693 ns |
| Setup WNS | -4.816 ns |
| Hold slack | +0.385 ns |

EXP2 branch: `m4-exp2-official`  
EXP2 commit: `31f3ef1`

---

## 4. EXP3 Motivation

After EXP2, timing analysis identified the PC + immediate addition used for branch/jump target generation as a major remaining timing bottleneck.

The relevant RTL operation was:

```verilog
ex_pc + ex_imm_val
```

The synthesized implementation produced a long carry-propagation path.

The objective was to reduce propagation delay without changing architectural behavior.

---

## 5. EXP3 RTL Optimization

A dedicated PC target adder was introduced:

`rtl/pc_target_adder.v`

It uses 4-bit ripple-carry blocks with carry-select computation for upper blocks. Each upper block precomputes results for carry-in 0 and 1, then selects the appropriate result based on the preceding carry.

The adder was integrated into `execution_unit.v`:

```verilog
wire [31:0] pc_imm_sum;

pc_target_adder pc_target_add(
    .a(ex_pc),
    .b(ex_imm_val),
    .result(pc_imm_sum)
);

assign branch_target = pc_imm_sum;
```

The dedicated JALR adder introduced during the EXP3 iteration was retained.

---

## 6. Functional Validation

Full project regression:

```text
make test
```

**PASS**

No functional regression was observed.

---

## 7. Synthesis

Authoritative top: `riscv_core`

Sky130 HD TT library:

`~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib`

EXP3 netlist:

`netlist/m4_exp3/riscv_core_exp3_m4.v`

### EXP3 synthesis result

- **Mapped cell count:** 7,546
- **Total cell area:** 82,277.6608 µm²

---

## 8. Static Timing Analysis

EXP3 was analyzed using OpenSTA 3.1.0 with the Sky130 HD TT library, 10 ns clock period, 100 MHz target, existing project SDC, and the final technology-mapped EXP3 netlist.

### Worst setup path

- **Startpoint:** `EXU/exmem/_282_`
- **Endpoint:** `EXU/exmem/_385_`
- **Data arrival time:** 12.82 ns
- **Data required time:** 9.89 ns
- **Worst setup slack:** **-2.93 ns**

### Worst hold path

- **Startpoint:** `IDU/idex/_399_`
- **Endpoint:** `EXU/exmem/_290_`
- **Worst hold slack:** **+0.39 ns**

Setup remains violated at 10 ns, while hold remains clean.

---

## 9. Critical-Path Migration

EXP3 successfully removed the PC + immediate carry chain from the dominant timing path.

The new worst path is primarily:

```text
EX/MEM register
    ↓
Forwarding logic
    ↓
ALU operand selection
    ↓
ALU arithmetic datapath
    ↓
EX/MEM register
```

The synthesized path contains a long arithmetic carry-related chain including `maj3`, `a21o`, `a311oi`, and `o311ai` cells.

The remaining timing bottleneck is therefore concentrated in the ALU arithmetic datapath.

---

## 10. PPA Comparison

| Metric | Baseline | EXP2 | EXP3 |
|---|---:|---:|---:|
| Mapped cell count | 7,502 | 7,694 | **7,546** |
| Total cell area | 77,385.4688 µm² | 79,571.3152 µm² | **82,277.6608 µm²** |
| Critical delay | 17.305 ns | 14.693 ns | **12.82 ns** |
| Setup WNS | -7.371 ns | -4.816 ns | **-2.93 ns** |
| Hold slack | — | +0.385 ns | **+0.39 ns** |

---

## 11. Improvement Relative to Baseline

### Critical-path delay

17.305 ns → 12.82 ns

**Reduction: 4.485 ns (~25.9%)**

### Setup WNS

-7.371 ns → -2.93 ns

**Improvement: +4.441 ns**

### Cell count

7,502 → 7,546

**Increase: 44 cells (~0.59%)**

### Area

77,385.4688 µm² → 82,277.6608 µm²

**Increase: ~4,892.19 µm² (~6.32%)**

### Hold

**+0.39 ns**, so the design remains hold-clean.

---

## 12. Engineering Assessment

EXP3 represents a substantial timing improvement over the original baseline.

The critical-path delay was reduced by approximately **25.9%**, while mapped cell count increased by only **~0.59%**. The principal tradeoff was an approximately **6.32% increase in mapped cell area**.

The PC + immediate carry chain that motivated EXP3 is no longer the dominant critical path. The ALU arithmetic datapath is now the primary timing limiter.

The design is not timing-closed at the 10 ns target because WNS remains **-2.93 ns**.

Nevertheless, EXP3 is considered a successful and substantial PPA optimization checkpoint.

---

## 13. Current Project State

EXP3 is retained as the current optimized checkpoint.

Current branch:

`m4-exp3-critical-path`

Optimization progression:

```text
Baseline
   ↓
EXP2 — ALU arithmetic optimization
   ↓
EXP3 — PC + immediate carry-select optimization
```

EXP4 will focus on the newly exposed ALU arithmetic critical path.

EXP4 will be retained only if it produces a substantial improvement with a justified PPA tradeoff. Otherwise, EXP3 will remain the final substantial optimization result for the current M4 optimization phase.
