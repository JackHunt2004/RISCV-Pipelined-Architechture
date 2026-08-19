IVERILOG ?= iverilog
VVP      ?= vvp
YOSYS    ?= yosys

RTL := $(wildcard rtl/*.v)
BUILD := build

.PHONY: all test wave check clean

all: test

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/selfcheck: $(RTL) tb/tb_top_selfcheck.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_top_selfcheck -o $@ $(RTL) tb/tb_top_selfcheck.v

$(BUILD)/wave: $(RTL) tb/tb_top.v | $(BUILD)
	$(IVERILOG) -g2012 -Wall -I rtl -s tb_top -o $@ $(RTL) tb/tb_top.v

test: $(BUILD)/selfcheck
	$(VVP) $(BUILD)/selfcheck

wave: $(BUILD)/wave
	$(VVP) $(BUILD)/wave

check:
	$(YOSYS) -Q -p 'read_verilog -Irtl $(RTL); hierarchy -check -top riscv_core; proc; check'

clean:
	rm -rf $(BUILD)
