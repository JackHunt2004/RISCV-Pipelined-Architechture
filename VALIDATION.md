# Redone Milestone 1 validation status

## Completed in the artifact-building workspace

- Structural parsing of every RTL and testbench module
- Balanced module, begin/end, case/endcase, and task/endtask blocks
- Named-port declaration and completeness checks for every instance
- All 16 module interfaces match the architecture-correct Milestone 1 revision
- All modules use the original separate port-declaration coding style
- All 13 module instances retain complete named-port connections
- Explicit check that `riscv_core` has instruction, data, and retirement ports
- Explicit check that `instruction_memory` is instantiated only by `soc_top`
- Legacy floating control names absent
- Semantic guards for shifts, BGE, JALR, retirement, and memory boundaries
- Directed regression instruction encodings checked
- ZIP integrity checked after packaging

## Executable acceptance gate

Icarus Verilog and Yosys are not installed in the artifact-building runtime.
Run the following in the audited development environment:

```bash
make clean
make test
```

Accept only the final `TEST_PASS` result. Then perform a Yosys hierarchy/check
pass with `riscv_core` selected as top before technology mapping.
