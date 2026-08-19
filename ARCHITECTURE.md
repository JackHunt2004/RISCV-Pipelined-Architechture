# Processor architecture and interface contract

## Hierarchy

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

## `riscv_core` interface

| Interface | Direction from core | Purpose |
| --- | --- | --- |
| `imem_valid` | Output | Instruction request is active |
| `imem_addr` | Output | Byte address of the requested instruction |
| `imem_rdata` | Input | 32-bit instruction returned combinationally |
| `dmem_valid` | Output | Data transaction request; inactive in M1 |
| `dmem_write` | Output | Data transaction is a store; inactive in M1 |
| `dmem_wstrb[3:0]` | Output | Store byte enables; inactive in M1 |
| `dmem_addr` | Output | Data byte address; inactive in M1 |
| `dmem_wdata` | Output | Store data; inactive in M1 |
| `dmem_rdata` | Input | Load response data; consumed beginning in M2 |
| `retire_*` | Output | Observable WB-stage instruction, PC, and register result |

The instruction memory and any future data memory are outside the processor
core. Synthesize `riscv_core`; use `soc_top` for the included simulation ROM.

## Memory timing contract

Milestone 1 assumes `imem_rdata` is the combinational response for `imem_addr`.
There is no ready/wait-state mechanism yet. A latency-tolerant valid/ready bus
can be introduced later together with global pipeline stall control; that is a
performance/integration extension, not hidden inside the current contract.

## Observability

The retirement interface makes architecturally completed work observable
without relying solely on internal waveforms. It also prevents the complete
processor from appearing as unused logic when `riscv_core` is synthesized as
the top module.
