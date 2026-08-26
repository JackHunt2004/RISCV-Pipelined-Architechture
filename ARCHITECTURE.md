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

## Pipeline organization

The processor uses a five-stage in-order pipeline:

```text
IF → ID → EX → MEM → WB
```

The pipeline registers are:

```text
IF/ID → ID/EX → EX/MEM → MEM/WB
```

`riscv_core` is the processor synthesis boundary. `soc_top` provides the
included instruction-memory integration used by simulation.

## `riscv_core` interface

| Interface | Direction from core | Purpose |
| --- | --- | --- |
| `imem_valid` | Output | Instruction request is active |
| `imem_addr` | Output | Byte address of the requested instruction |
| `imem_rdata` | Input | 32-bit instruction returned combinationally |
| `dmem_valid` | Output | Data-memory transaction is active |
| `dmem_write` | Output | Data transaction is a store |
| `dmem_wstrb[3:0]` | Output | Store byte enables |
| `dmem_addr` | Output | Data byte address |
| `dmem_wdata` | Output | Store data |
| `dmem_rdata` | Input | Load data returned by the data memory |
| `retire_*` | Output | Observable WB-stage instruction, PC, destination register, and result |

The instruction memory and data memory are external to `riscv_core`.

## Instruction memory timing contract

`imem_rdata` is the combinational response corresponding to `imem_addr`.

There is no instruction-memory ready/wait-state protocol in the current
implementation.

## Data memory timing contract

The M3 memory interface uses a single-cycle, zero-wait-state data-memory
contract.

For a load:

```text
dmem_valid = 1
dmem_write = 0
dmem_addr  = effective address
dmem_rdata = load data
```

For a store:

```text
dmem_valid = 1
dmem_write = 1
dmem_addr  = effective address
dmem_wdata = store data
dmem_wstrb = byte enables
```

When no memory operation is active:

```text
dmem_valid = 0
```

There is no ready/busy or variable-latency data-memory protocol.

A latency-tolerant memory interface can be introduced later together with
global pipeline stall control.

## Supported memory instructions

### Loads

| Instruction | Operation | Size | Extension |
| --- | --- | --- | --- |
| `LB` | Load byte | 8-bit | Sign extend |
| `LBU` | Load byte | 8-bit | Zero extend |
| `LH` | Load halfword | 16-bit | Sign extend |
| `LHU` | Load halfword | 16-bit | Zero extend |
| `LW` | Load word | 32-bit | None |

### Stores

| Instruction | Operation | Size | `dmem_wstrb` |
| --- | --- | --- | --- |
| `SB` | Store byte | 8-bit | `0001` |
| `SH` | Store halfword | 16-bit | `0011` |
| `SW` | Store word | 32-bit | `1111` |

The verified M3 scope uses naturally aligned accesses.

## Memory pipeline flow

Memory-control metadata is generated during decode and propagated through
the pipeline with the instruction.

```text
ID
│
├── mem_read
├── mem_write
├── mem_size
└── mem_unsigned
        │
        ▼
      ID/EX
        │
        ▼
       EX
        │
        ├── effective address
        └── forwarded store data
        │
        ▼
      EX/MEM
        │
        ▼
       MEM
        │
        ├── dmem_valid
        ├── dmem_write
        ├── dmem_addr
        ├── dmem_wdata
        └── dmem_wstrb
        │
        ▼
      MEM/WB
        │
        └── load data / ALU result
        │
        ▼
       WB
```

## Effective address generation

Load and store effective addresses are generated in the existing EX-stage ALU
using:

```text
effective_address = rs1 + immediate
```

The resulting address is carried through the EX/MEM path and drives
`dmem_addr`.

## Store-data path

Store data uses the EX-stage operand path, including the existing forwarding
unit.

This allows the store operand to receive the most recent value from the
appropriate pipeline stage when forwarding conditions are satisfied.

## Load-data extraction

Load data is extracted according to the decoded memory size and unsigned
control.

For byte loads, the selected byte is extended to 32 bits.

For halfword loads, the selected 16-bit value is extended to 32 bits.

For word loads, the complete 32-bit memory value is transferred.

Signed operations use sign extension and unsigned operations use zero
extension.

## Writeback selection

The MEM/WB path selects the value that is ultimately written to the register
file.

For an ALU instruction:

```text
WB result = ALU result
```

For a load:

```text
WB result = extracted load data
```

Only valid instructions with register-write control active update the
architectural register file.

## Control-flow behavior

The existing branch and jump mechanisms remain part of the pipeline.

Branch and jump decisions are generated in EX and redirect instruction fetch
when taken.

The current M3 memory integration does not introduce a new control-flow
mechanism.

## Hazard and forwarding scope

The processor contains the existing EX-stage forwarding mechanism for
applicable data dependencies.

General pipeline hazard handling is intentionally outside the completed M3
scope.

In particular, M3 does not implement a general load-use interlock/stall
mechanism.

Therefore the current memory interface assumes the zero-wait-state execution
model and does not claim complete hazard handling for arbitrary dependent
load sequences.

Hazard detection, pipeline stalls, and broader dependency handling remain
future work.

## Alignment and unsupported functionality

The verified M3 scope covers naturally aligned byte, halfword, and word
accesses.

The current architecture does not claim support for:

- Misaligned memory accesses
- Variable-latency memory
- Ready/busy memory handshaking
- General pipeline stalls
- General load-use hazard interlocking
- Atomic memory operations
- CSR/system instructions
- Other RISC-V extensions outside the implemented instruction subset

## Observability

The retirement interface makes architecturally completed work observable
without relying solely on internal waveforms.

The interface exposes:

```text
retire_valid
retire_pc
retire_instruction
retire_reg_write
retire_rd
retire_data
```

This also provides an observable output path when `riscv_core` is synthesized
as the top-level module.

## Verification status

Milestone 3 verified the memory subsystem incrementally through dedicated
self-checking testbenches covering:

- Memory instruction decode
- ID/EX memory-control propagation
- EX memory path
- Data-memory interface generation
- Load writeback
- Load extraction and extension
- End-to-end load/store behavior
- Memory-interface safety
- Existing architectural regression behavior

The M3 implementation is committed as:

```text
3c21016 Complete Milestone 3 memory subsystem integration
```
