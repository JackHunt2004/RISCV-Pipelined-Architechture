`timescale 1ns / 1ps
module tb_top;

    reg clk;
    reg rst;

    top dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        // Hold reset long enough to load instruction memory
        #20;
        rst = 0;

        // ================= R-TYPE =================
        // ADD @ PC = 0
        #40;

        // ================= I-TYPE =================
        // ADDI @ PC = 40
        #40;

        // ================= B-TYPE =================
        // BEQ @ PC = 76
        #40;

        // ================= J-TYPE =================
        // JAL @ PC = 92
        #40;

        #20;
        $finish;
    end

    initial begin
    $dumpfile("riscv_pipeline.vcd");
    $dumpvars(0, tb_top);
    end


    initial begin
        $display("Time\tPC\tInstruction\tWB_RD\tWB_DATA");
        $monitor("%0t\t%h\t%h\t%d\t%h",
                 $time,
                 dut.id_pc,
                 dut.id_instruction,
                 dut.wb_rd,
                 dut.wb_result);
    end

endmodule