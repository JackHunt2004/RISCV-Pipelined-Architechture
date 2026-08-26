`timescale 1ns/1ps

module tb_m3_6_load_wb_selfcheck;

    reg clk;
    reg rst;

    reg mem_valid;
    reg mem_reg_write;
    reg mem_mem_read;
    reg [31:0] mem_result;
    reg [31:0] mem_load_data;
    reg [31:0] mem_instruction;
    reg [31:0] mem_pc;
    reg [4:0] mem_rd;

    wire wb_valid;
    wire wb_reg_write;
    wire [31:0] wb_instruction;
    wire [31:0] wb_pc;
    wire [4:0] wb_rd;
    wire [31:0] wb_result;

    integer failures;

    mem_wb_reg dut(
        .clk(clk),
        .rst(rst),

        .mem_valid(mem_valid),
        .mem_instruction(mem_instruction),
        .mem_pc(mem_pc),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .mem_result(mem_result),
        .mem_load_data(mem_load_data),
        .mem_mem_read(mem_mem_read),

        .wb_valid(wb_valid),
        .wb_instruction(wb_instruction),
        .wb_pc(wb_pc),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_result(wb_result)
    );

    always #5 clk = ~clk;

    task check_result;
        input [31:0] expected;
        input [127:0] test_name;

        begin
            if(wb_result !== expected) begin
                $display("TEST_FAIL: %s", test_name);
                $display("  Expected = 0x%08h", expected);
                $display("  Actual   = 0x%08h", wb_result);
                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    task check_control;
        input expected_valid;
        input expected_reg_write;
        input [127:0] test_name;

        begin
            if(wb_valid !== expected_valid ||
               wb_reg_write !== expected_reg_write) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  Expected: valid=%b reg_write=%b",
                         expected_valid,
                         expected_reg_write);

                $display("  Actual:   valid=%b reg_write=%b",
                         wb_valid,
                         wb_reg_write);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        failures = 0;

        clk = 1'b0;
        rst = 1'b1;

        mem_valid = 1'b0;
        mem_reg_write = 1'b0;
        mem_mem_read = 1'b0;
        mem_result = 32'b0;
        mem_load_data = 32'b0;
        mem_instruction = 32'h00000013;
        mem_pc = 32'b0;
        mem_rd = 5'b0;

        #12;
        rst = 1'b0;

        /*
         * ------------------------------------------------------------
         * Test 1: Load result must be selected
         * ------------------------------------------------------------
         */

        mem_valid = 1'b1;
        mem_reg_write = 1'b1;
        mem_mem_read = 1'b1;

        mem_result = 32'h00000100;
        mem_load_data = 32'hFFFFFF80;

        @(posedge clk);
        #1;

        check_result(
            32'hFFFFFF80,
            "Load data selected for WB"
        );

        check_control(
            1'b1,
            1'b1,
            "Load WB control propagated"
        );

        /*
         * ------------------------------------------------------------
         * Test 2: Normal ALU result must still be selected
         * ------------------------------------------------------------
         */

        mem_mem_read = 1'b0;
        mem_result = 32'h12345678;
        mem_load_data = 32'hDEADBEEF;

        @(posedge clk);
        #1;

        check_result(
            32'h12345678,
            "ALU result preserved for WB"
        );

        /*
         * ------------------------------------------------------------
         * Test 3: Invalid instruction disables WB
         * ------------------------------------------------------------
         */

        mem_valid = 1'b0;
        mem_reg_write = 1'b1;
        mem_mem_read = 1'b1;
        mem_load_data = 32'hCAFEBABE;

        @(posedge clk);
        #1;

        check_control(
            1'b0,
            1'b0,
            "Invalid MEM entry disables WB"
        );

        /*
         * ------------------------------------------------------------
         * Final result
         * ------------------------------------------------------------
         */

        if(failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.6 MEM/WB load selection passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.6 MEM/WB load selection failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule