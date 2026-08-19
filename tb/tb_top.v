`timescale 1ns / 1ps
module tb_top;
    reg clk,rst;
    wire [31:0] fetch_pc;
    wire retire_valid,retire_reg_write;
    wire [31:0] retire_pc,retire_instruction,retire_data;
    wire [4:0] retire_rd;

    soc_top dut(.clk(clk),
                .rst(rst),
                .dmem_rdata(32'b0),
                .dmem_valid(),
                .dmem_write(),
                .dmem_wstrb(),
                .dmem_addr(),
                .dmem_wdata(),
                .fetch_pc(fetch_pc),
                .retire_valid(retire_valid),
                .retire_pc(retire_pc),
                .retire_instruction(retire_instruction),
                .retire_reg_write(retire_reg_write),
                .retire_rd(retire_rd),
                .retire_data(retire_data));

    always #5 clk=~clk;

    initial
        begin
            clk=1'b0;
            rst=1'b1;
            repeat(3) @(posedge clk);
            @(negedge clk);
            rst=1'b0;
            repeat(40) @(posedge clk);
            $finish;
        end

    initial
        begin
            $dumpfile("build/riscv_pipeline.vcd");
            $dumpvars(0,tb_top);
        end

    initial
        begin
            $display("Time\tFetchPC\tRetirePC\tInstruction\tRD\tData\tWE");
            $monitor("%0t\t%h\t%h\t%h\t%0d\t%h\t%b",$time,fetch_pc,retire_pc,retire_instruction,retire_rd,retire_data,retire_reg_write);
        end
endmodule
