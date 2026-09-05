# M4 Final Optimization — EXP4 PPA Checkpoint

## 1. Objective

M4 was the RTL-level timing optimization phase for the verified 32-bit RISC-V 5-stage pipelined processor.

The original verified baseline remains the immutable reference point. The objective of M4 was to reduce the critical timing path while keeping area overhead small and preserving full functional correctness.

**EXP4 is the final retained optimization of M4. No further RTL optimization is planned in M4.**

---

## 2. Optimization Progression

| Version | Focus | Critical Delay (ns) | WNS (ns) | Area (µm²) | Cells |
|---|---|---:|---:|---:|---:|
| Baseline | Verified reference | 17.305 | -7.371 | 77,385.4688 | 7,502 |
| EXP2 | Arithmetic datapath optimization | 14.693 | -4.816 | 79,571.3152 | 7,694 |
| EXP3 | PC/branch-target adder optimization | 12.817 | -2.930 | 82,277.6608 | 7,546 |
| **EXP4** | **Final arithmetic critical-path optimization** | **12.196** | **-2.343** | **78,146.1984** | **7,353** |

EXP4 hold slack: **+0.385 ns (MET)**.

---

## 3. Final Baseline → EXP4 Result

### Timing

Critical delay:

**17.305 ns → 12.196 ns**

Absolute improvement:

**5.109 ns**

Percentage improvement:

**29.53%**

WNS:

**-7.371 ns → -2.343 ns**

WNS improvement:

**+5.028 ns**

The processor remains setup-time limited at the 10 ns clock target, but the setup violation has been substantially reduced.

### Area

Cell count:

**7,502 → 7,353**

Change:

**-149 cells (-1.99%)**

Sky130 standard-cell area:

**77,385.4688 µm² → 78,146.1984 µm²**

Change:

**+760.7296 µm² (+0.98%)**

Thus, the final M4 result achieves approximately **29.5% critical-delay improvement for less than 1% area overhead** relative to the immutable baseline.

---

## 4. EXP4 Implementation

EXP4 targeted the arithmetic datapath that had become the dominant critical path after EXP3.

A dedicated RTL module was introduced:

`rtl/arithmetic_adder.v`

The module implements the unified ADD/SUB arithmetic operation using an 8-bit block structure with carry-select behavior for the upper blocks.

The ALU instantiates the dedicated arithmetic adder rather than expressing the complete arithmetic operation as a single RTL addition.

The existing JALR and PC/branch-target datapath optimizations from EXP3 were retained.

The final EXP4 synthesis netlist is:

`netlist/m4_exp3/riscv_core_exp3_m4.v`

The area measurement uses the Sky130 HD TT Liberty file and counts instantiated Sky130 standard cells from the final technology-mapped netlist.

---

## 5. Functional Verification

The complete project regression was run after the EXP4 RTL modification.

**Result: PASS**

No functional regression was observed from the EXP4 arithmetic datapath change.

---

## 6. Final STA

### Setup

- Startpoint: `IFU/ifid/_151_`
- Endpoint: `IDU/idex/_504_`
- Critical delay: **12.196 ns**
- WNS: **-2.343 ns**

The previous EXP3 ALU arithmetic carry-chain bottleneck is no longer the worst setup path. The critical path migrated into the IF/ID → register-file/read/decode → ID/EX portion of the design.

### Hold

- Startpoint: `IDU/idex/_399_`
- Endpoint: `EXU/exmem/_290_`
- Hold slack: **+0.385 ns**
- Result: **MET**

No hold violation was introduced by EXP4.

---

## 7. PPA Interpretation

EXP4 is a strong improvement over both the original baseline and the preceding EXP3 implementation.

Compared with the immutable baseline:

- Critical delay improved by **29.53%**
- WNS improved by **5.028 ns**
- Area increased by only **0.98%**
- Cell count decreased by **1.99%**
- Hold timing remains positive

Compared with EXP3:

- Critical delay improved by **0.621 ns**
- WNS improved by **0.587 ns**
- Area decreased by **5.02%**
- Cell count decreased by **2.56%**
- Hold slack remains positive

The newly exposed ID/register-file path is not being optimized further in M4. The improvement obtained by EXP4 is considered sufficient to close the RTL optimization phase.

---

## 8. M4 Final Decision

**EXP4 is the final retained M4 optimization.**

No EXP5 or additional RTL critical-path optimization will be pursued as part of M4.

The reason for stopping is that the project has already achieved a substantial timing improvement with minimal area trade-off:

> **~29.5% critical-delay reduction with <1% area overhead versus the verified baseline.**

Further RTL optimization would target a newly exposed path and would risk diminishing returns or compromising the established PPA result.

---

## 9. Reproducibility

Authoritative synthesis top:

`riscv_core`

Sky130 HD TT Liberty:

`~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib`

Clock constraint:

**10 ns / 100 MHz**

OpenSTA:

`/home/jackhunt2004/projects/OpenSTA/build/sta`

SDC:

`constraints/riscv_core.sdc`

Final EXP4 area script:

`sta/scripts/calculate_exp4_area.py`

---

## 10. Final M4 Status

**M4 STATUS: COMPLETE**

**Final optimization: EXP4**

**Final critical delay: 12.196 ns**

**Final WNS: -2.343 ns**

**Final hold slack: +0.385 ns**

**Final area: 78,146.1984 µm²**

**Final cell count: 7,353**

**Baseline → EXP4 timing improvement: 29.53%**

**Baseline → EXP4 area overhead: 0.98%**

The design is now ready to proceed to the next stage of the ASIC flow without further M4 RTL optimization.
