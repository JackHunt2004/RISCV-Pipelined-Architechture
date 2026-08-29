# RISC-V pipelined core - initial STA constraints
# Sky130 HD, TT, 0.25C, 1.80V
# Initial target: 100 MHz (10 ns period)

create_clock -name clk -period 10.0 [get_ports clk]

# Reset is asynchronous to normal data timing.
set_false_path -from [get_ports rst]

# External interfaces are intentionally left unconstrained
# for this first internal timing baseline.
