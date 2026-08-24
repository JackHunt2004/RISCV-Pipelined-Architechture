IVERILOG ?= iverilog
VVP      ?= vvp
YOSYS    ?= yosys

RTL := $(wildcard rtl/*.v)
BUILD := build

.PHONY: all test test_alu test_branch test_forwarding regression wave check clean

all: test

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/selfcheck: $(RTL) tb/tb_top_selfcheck.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_top_selfcheck -o $@ $(RTL) tb/tb_top_selfcheck.v

$(BUILD)/alu_selfcheck: $(RTL) tb/tb_alu_selfcheck.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_alu_selfcheck -o $@ $(RTL) tb/tb_alu_selfcheck.v

$(BUILD)/branch_selfcheck: $(RTL) tb/tb_branch_selfcheck.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_branch_selfcheck -o $@ $(RTL) tb/tb_branch_selfcheck.v

$(BUILD)/forwarding_selfcheck: $(RTL) tb/tb_forwarding_selfcheck.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_forwarding_selfcheck -o $@ $(RTL) tb/tb_forwarding_selfcheck.v

$(BUILD)/wave: $(RTL) tb/tb_top.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_top -o $@ $(RTL) tb/tb_top.v

test: $(BUILD)/selfcheck
	$(VVP) $(BUILD)/selfcheck

test_alu: $(BUILD)/alu_selfcheck
	$(VVP) $(BUILD)/alu_selfcheck

test_branch: $(BUILD)/branch_selfcheck
	$(VVP) $(BUILD)/branch_selfcheck

test_forwarding: $(BUILD)/forwarding_selfcheck
	$(VVP) $(BUILD)/forwarding_selfcheck

regression: test test_alu test_branch test_forwarding

wave: $(BUILD)/wave
	$(VVP) $(BUILD)/wave

check:
	$(YOSYS) -Q -p 'read_verilog -Irtl $(RTL); hierarchy -check -top riscv_core; proc; check'

clean:
	rm -rf $(BUILD)