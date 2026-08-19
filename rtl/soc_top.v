module soc_top(clk,rst,dmem_rdata,dmem_valid,dmem_write,dmem_wstrb,dmem_addr,dmem_wdata,fetch_pc,retire_valid,retire_pc,retire_instruction,retire_reg_write,retire_rd,retire_data);
    input clk,rst;
    input [31:0] dmem_rdata;
    output dmem_valid,dmem_write;
    output [3:0] dmem_wstrb;
    output [31:0] dmem_addr,dmem_wdata;
    output [31:0] fetch_pc;
    output retire_valid,retire_reg_write;
    output [31:0] retire_pc,retire_instruction,retire_data;
    output [4:0] retire_rd;

    wire imem_valid;
    wire [31:0] imem_addr,imem_rdata;

    assign fetch_pc=imem_addr;

    instruction_memory im(.if_instruction(imem_rdata),
                          .if_pc(imem_addr));

    riscv_core core(.clk(clk),
                    .rst(rst),
                    .imem_valid(imem_valid),
                    .imem_addr(imem_addr),
                    .imem_rdata(imem_rdata),
                    .dmem_valid(dmem_valid),
                    .dmem_write(dmem_write),
                    .dmem_wstrb(dmem_wstrb),
                    .dmem_addr(dmem_addr),
                    .dmem_wdata(dmem_wdata),
                    .dmem_rdata(dmem_rdata),
                    .retire_valid(retire_valid),
                    .retire_pc(retire_pc),
                    .retire_instruction(retire_instruction),
                    .retire_reg_write(retire_reg_write),
                    .retire_rd(retire_rd),
                    .retire_data(retire_data));
endmodule
