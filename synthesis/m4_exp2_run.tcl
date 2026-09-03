read_verilog -Irtl rtl/*.v

hierarchy -top riscv_core

proc
memory
opt

techmap
opt
dfflibmap -liberty ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

opt

stat -liberty ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

check

write_verilog -noattr netlist/m4_exp2/riscv_core_exp2_m4.v
