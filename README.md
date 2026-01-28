# 5-Stage Pipelined RISC-V (RV32I) Processor

## Overview
This project implements a modular 5-stage pipelined RV32I processor in Verilog HDL.

## Pipeline Stages
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute / Address Calculation (EX)
- Memory Access (MEM)
- Write Back (WB)

## Features
- IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers
- Supports R, I, B, and J-type instructions
- Branch and jump resolution in EX stage
- Architecture designed for data and control hazard handling
- RTL synthesized and visualized using Yosys and SkyWater 130nm PDK

## Tools Used
- Verilog HDL
- Icarus Verilog
- Yosys
- SkyWater 130nm PDK

## Status
Baseline pipelined implementation complete.  
Hazard handling (forwarding/stalling) planned as future extension.
