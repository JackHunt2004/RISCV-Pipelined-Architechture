# Synthesis boundary

The authoritative synthesis top is now:

```text
riscv_core
```

Do not synthesize `soc_top` for core PPA reporting; it contains the behavioral
demonstration instruction memory. Historical netlists and schematics under
`baseline/` were generated from the original input-only `top` and are retained
only for comparison.

Before technology mapping, run the self-checking regression and a generic
Yosys hierarchy/check pass using `riscv_core` as top.
