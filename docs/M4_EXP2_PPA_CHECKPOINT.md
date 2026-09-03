# M4 EXP2 PPA Checkpoint

**Project:** RISC-V Pipelined Architecture  
**Milestone:** M4 ASIC Implementation / PPA Optimization  
**Checkpoint:** EXP2 Arithmetic Datapath Optimization  
**Date:** 2026-09-04

---

## 1. Purpose

This checkpoint establishes the official post-EXP2 reference point for the
ASIC-oriented optimization phase.

The project has moved beyond architectural correctness and initial synthesis
setup. The objective of M4 is now to improve implementation PPA using measured
Sky130 synthesis and STA results.

The methodology is:

    RTL → Yosys synthesis → Sky130 HD technology mapping → mapped netlist
       → cell-area measurement + OpenSTA timing analysis

All PPA comparisons must use the same synthesis and measurement methodology.

---

## 2. Official Baseline

The official pre-EXP2 RTL baseline is commit:

    580f7ec
    Complete architecture-correct Milestone 1 upgrade

The baseline was synthesized using the corrected Sky130 synthesis flow:

- Yosys 0.33
- SkyWater130 HD standard-cell library
- TT / 0.25C / 1.80V liberty
- `dfflibmap`
- ABC technology mapping
- Final mapped netlist used for area measurement and STA

The baseline RTL was synthesized in a separate Git worktree to ensure that
EXP2 RTL changes could not contaminate the baseline measurement.

---

## 3. EXP2 Optimization

EXP2 targeted the arithmetic datapath in `rtl/alu.v`.

The optimization unified:

- ADD
- SUB
- ADDI

into a common arithmetic datapath.

The relevant structure is:

    arithmetic_sub  = (ex_alu_control == 6'd2);
    arithmetic_imm  = (ex_alu_control == 6'd11);
    arithmetic_b    = arithmetic_imm ? imm_val : rs2_data;

    arithmetic_result =
        rs1_data + (arithmetic_sub ? ~arithmetic_b : arithmetic_b)
                   + arithmetic_sub;

The individual ADD, SUB and ADDI ALU cases then use the unified
`arithmetic_result`.

The purpose was to encourage synthesis to share arithmetic hardware rather
than maintaining separate arithmetic structures.

---

## 4. Functional Status

The architecture-correct Milestone 1 regression was previously verified
successfully on the official baseline.

EXP2 was synthesized successfully and the resulting netlist contains no
generic Yosys sequential cells.

The mapped EXP2 netlist contains:

    7,694 Sky130 standard-cell instances

All 7,694 extracted cell instances were successfully matched against the
Sky130 Liberty file during area calculation.

---

## 5. Official PPA Comparison

### Cell Count

| Metric | Baseline | EXP2 | Change |
|---|---:|---:|---:|
| Mapped standard cells | 7,502 | 7,694 | +192 |
| Relative change | — | — | +2.56% |

### Cell Area

| Metric | Baseline | EXP2 | Change |
|---|---:|---:|---:|
| Total cell area | 77,385.4688 µm² | 79,571.3152 µm² | +2,185.8464 µm² |
| Relative change | — | — | +2.82% |

Area was calculated directly from the Sky130 TT Liberty cell areas using the
same parser and methodology for both implementations.

---

## 6. Timing Comparison

Target clock:

    10 ns period
    100 MHz

### Setup Timing

| Metric | Baseline | EXP2 | Improvement |
|---|---:|---:|---:|
| Worst setup slack (WNS) | -7.371 ns | -4.816 ns | +2.555 ns |
| Critical-path delay | 17.305 ns | 14.693 ns | 2.612 ns faster |

The critical-path delay was reduced by approximately:

    15.1%

The magnitude of the setup violation was reduced by approximately:

    34.7%

### Hold Timing

EXP2 clean-flow hold slack:

    +0.385 ns

The clean-flow baseline hold result was not retained as an authoritative
checkpoint measurement and therefore is intentionally not used for the
baseline-vs-EXP2 comparison.

---

## 7. Critical-Path Observation

The baseline critical path was associated with the arithmetic/forwarding
logic and contained a long carry structure.

After EXP2, that path was substantially improved and the critical endpoint
changed.

The EXP2 worst setup path is:

    Startpoint: EX/MEM register
    Endpoint:   IFU register

The new critical path still contains a long `maj3_1` carry-chain structure.

Therefore, further optimization should target the NEW post-EXP2 critical path
rather than continuing to optimize the original arithmetic path blindly.

A detailed OpenSTA path report should be used before making the next RTL
change.

---

## 8. Important Methodology Correction

An earlier baseline/EXP2 comparison used different intermediate netlists and
was therefore not considered authoritative.

The official comparison was re-established using:

    Baseline RTL @ 580f7ec
        ↓
    Corrected Yosys + dfflibmap + ABC flow
        ↓
    Sky130 mapped baseline netlist

and:

    EXP2 RTL
        ↓
    Identical Yosys + dfflibmap + ABC flow
        ↓
    Sky130 mapped EXP2 netlist

Both final netlists were measured using the same Liberty-based area
calculation methodology.

Only the results in this document are considered the official M4
baseline-vs-EXP2 PPA results.

---

## 9. Engineering Assessment

EXP2 is a valid timing optimization but not a pure area/PPA improvement.

Result:

- Timing improved substantially.
- Critical-path delay decreased by ~15.1%.
- WNS improved by 2.555 ns.
- Area increased by 2.82%.
- Cell count increased by 2.56%.

Therefore EXP2 is retained as the current optimization baseline because the
timing improvement is significant and the area penalty is relatively small.

---

## 10. Current Optimization Baseline

Future M4 experiments should be compared against:

    EXP2

Current reference values:

    Area:       79,571.3152 µm²
    Cells:      7,694
    WNS:        -4.816 ns
    Hold slack: +0.385 ns
    Critical delay: 14.693 ns

The EXP2 implementation is preserved on:

    branch: m4-exp2-official

Historical checkpoint:

    commit: 61d38a9
    Checkpoint M4 EXP2 STA and PPA results

---

## 11. Next M4 Step

Before making Optimization #2:

1. Generate the complete EXP2 worst-path OpenSTA report.
2. Identify the RTL logic corresponding to the new critical path.
3. Make exactly one targeted RTL optimization.
4. Run the functional regression.
5. Synthesize using the same Sky130 flow.
6. Measure cell count and area.
7. Run OpenSTA using the same constraints.
8. Compare against this EXP2 checkpoint.
9. Keep or revert the optimization based on measured results.

No optimization should be accepted based on RTL intuition alone.

---

## 12. Checkpoint Status

**M4 EXP2: COMPLETE**

**Current status:** EXP2 retained as the new optimization baseline.

**Next task:** M4 Optimization #2 — target the post-EXP2 critical path.
