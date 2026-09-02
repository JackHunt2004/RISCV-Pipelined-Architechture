# OpenSTA EXP2 timing analysis
# Sky130 HD TT 0.25C 1.80V

read_liberty ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_verilog netlist/sta/riscv_core_exp2_sta.v

link_design riscv_core

read_sdc constraints/riscv_core.sdc

report_checks -path_delay max -fields {slew cap input_pins} -digits 3
report_checks -path_delay min -fields {slew cap input_pins} -digits 3

report_worst_slack -max -digits 3
report_worst_slack -min -digits 3

report_clock_skew -digits 3
