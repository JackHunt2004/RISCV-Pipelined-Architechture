`timescale 1ns/1ps

module tb_m3_4_execution_memory_selfcheck;

    reg clk;
    reg rst;

    reg ex_valid;
    reg [31:0] ex_instruction;
    reg [31:0] ex_pc;
    reg [4:0] ex_rs1;
    reg [4:0] ex_rs2;
    reg [4:0] ex_rd;
    reg [31:0] ex_rs1_data;
    reg [31:0] ex_rs2_data;
    reg [31:0] ex_imm_val;
    reg [5:0] ex_alu_control;
    reg [2:0] ex_branch_type;
    reg [1:0] ex_jump_type;
    reg ex_wb_pc4;
    reg ex_reg_write;

    reg ex_mem_read;
    reg ex_mem_write;
    reg [1:0] ex_mem_size;
    reg ex_mem_unsigned;

    reg [4:0] wb_rd;
    reg wb_reg_write;
    reg [31:0] wb_result;

    wire take_branch;
    wire take_jump;
    wire [31:0] branch_target;
    wire [31:0] jump_target;

    wire mem_valid;
    wire [31:0] mem_instruction;
    wire [31:0] mem_pc;
    wire [4:0] mem_rd;
    wire mem_reg_write;
    wire [31:0] mem_result;
    wire [31:0] mem_store_data;

    wire mem_mem_read;
    wire mem_mem_write;
    wire [1:0] mem_mem_size;
    wire mem_mem_unsigned;

    integer failures;

    execution_unit dut(
        .clk(clk),
        .rst(rst),

        .ex_valid(ex_valid),
        .ex_instruction(ex_instruction),
        .ex_pc(ex_pc),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm_val(ex_imm_val),
        .ex_alu_control(ex_alu_control),
        .ex_branch_type(ex_branch_type),
        .ex_jump_type(ex_jump_type),
        .ex_wb_pc4(ex_wb_pc4),
        .ex_reg_write(ex_reg_write),

        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_size(ex_mem_size),
        .ex_mem_unsigned(ex_mem_unsigned),

        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_result(wb_result),

        .take_branch(take_branch),
        .take_jump(take_jump),
        .branch_target(branch_target),
        .jump_target(jump_target),

        .mem_valid(mem_valid),
        .mem_instruction(mem_instruction),
        .mem_pc(mem_pc),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .mem_result(mem_result),
        .mem_store_data(mem_store_data),

        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_mem_size(mem_mem_size),
        .mem_mem_unsigned(mem_mem_unsigned)
    );

    always #5 clk = ~clk;

    task check_value;
        input [31:0] actual;
        input [31:0] expected;
        input [127:0] test_name;

        begin
            if (actual !== expected) begin
                $display("TEST_FAIL: %s", test_name);
                $display("  Expected = 0x%08h", expected);
                $display("  Actual   = 0x%08h", actual);
                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    task check_memory_controls;
        input expected_read;
        input expected_write;
        input [1:0] expected_size;
        input expected_unsigned;
        input [127:0] test_name;

        begin
            if (mem_mem_read !== expected_read ||
                mem_mem_write !== expected_write ||
                mem_mem_size !== expected_size ||
                mem_mem_unsigned !== expected_unsigned) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  Expected: read=%b write=%b size=%b unsigned=%b",
                         expected_read,
                         expected_write,
                         expected_size,
                         expected_unsigned);

                $display("  Actual:   read=%b write=%b size=%b unsigned=%b",
                         mem_mem_read,
                         mem_mem_write,
                         mem_mem_size,
                         mem_mem_unsigned);

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

        ex_valid = 1'b0;
        ex_instruction = 32'b0;
        ex_pc = 32'b0;
        ex_rs1 = 5'd0;
        ex_rs2 = 5'd0;
        ex_rd = 5'd0;
        ex_rs1_data = 32'b0;
        ex_rs2_data = 32'b0;
        ex_imm_val = 32'b0;
        ex_alu_control = 6'd11;
        ex_branch_type = 3'b0;
        ex_jump_type = 2'b0;
        ex_wb_pc4 = 1'b0;
        ex_reg_write = 1'b0;

        ex_mem_read = 1'b0;
        ex_mem_write = 1'b0;
        ex_mem_size = 2'b00;
        ex_mem_unsigned = 1'b0;

        wb_rd = 5'd0;
        wb_reg_write = 1'b0;
        wb_result = 32'b0;

        // ------------------------------------------------------------
        // Reset
        // ------------------------------------------------------------

        #12;
        rst = 1'b0;

        // ------------------------------------------------------------
        // Test 1:
        // Effective address = rs1 + immediate
        //
        // rs1 = 100
        // immediate = 12
        // expected address = 112
        // ------------------------------------------------------------

        ex_valid = 1'b1;
        ex_rs1 = 5'd1;
        ex_rs2 = 5'd2;
        ex_rs1_data = 32'd100;
        ex_rs2_data = 32'h12345678;
        ex_imm_val = 32'd12;

        ex_mem_read = 1'b1;
        ex_mem_write = 1'b0;
        ex_mem_size = 2'b10;
        ex_mem_unsigned = 1'b0;

        @(posedge clk);
        #1;

        check_value(
            mem_result,
            32'd112,
            "Effective address generation"
        );

        check_memory_controls(
            1'b1,
            1'b0,
            2'b10,
            1'b0,
            "Load metadata reaches EX/MEM"
        );

        // ------------------------------------------------------------
        // Test 2:
        // Store data must come from forwarded operand_b path.
        //
        // No forwarding here:
        // rs2_data = 0x12345678
        // ------------------------------------------------------------

        ex_mem_read = 1'b0;
        ex_mem_write = 1'b1;
        ex_mem_size = 2'b00;
        ex_mem_unsigned = 1'b0;

        @(posedge clk);
        #1;

        check_value(
            mem_store_data,
            32'h12345678,
            "Store data reaches EX/MEM"
        );

        check_memory_controls(
            1'b0,
            1'b1,
            2'b00,
            1'b0,
            "Store metadata reaches EX/MEM"
        );

        // ------------------------------------------------------------
        // Test 3:
        // EX/MEM forwarding to store data.
        //
        // ex_rs2 = x5
        // mem_rd = x5
        // mem_result = 0xAABBCCDD
        //
        // Therefore operand_b should be forwarded from mem_result.
        // ------------------------------------------------------------

        ex_rs2 = 5'd5;
        ex_rs2_data = 32'h11111111;

        wb_rd = 5'd0;
        wb_reg_write = 1'b0;
        wb_result = 32'b0;

        ex_mem_read = 1'b0;
        ex_mem_write = 1'b1;
        ex_mem_size = 2'b10;
        ex_mem_unsigned = 1'b0;

        // The EX/MEM register currently represents the previous
        // instruction and its result is used by forwarding logic.
        //
        // mem_rd and mem_result are internal to execution_unit and
        // are produced by the ex_mem_reg instance. To establish the
        // forwarding condition, first clock in an instruction that
        // writes x5.

        ex_rs1 = 5'd1;
        ex_rs1_data = 32'd200;
        ex_imm_val = 32'd0;
        ex_rd = 5'd5;
        ex_reg_write = 1'b1;
        ex_mem_write = 1'b0;
        ex_mem_read = 1'b0;

        @(posedge clk);
        #1;

        // Now configure the following store to use x5.
        ex_rd = 5'd0;
        ex_rs2 = 5'd5;
        ex_rs2_data = 32'h11111111;
        ex_rs1 = 5'd1;
        ex_rs1_data = 32'd300;
        ex_imm_val = 32'd4;
        ex_reg_write = 1'b0;
        ex_mem_write = 1'b1;
        ex_mem_size = 2'b10;

        @(posedge clk);
        #1;

        check_value(
            mem_store_data,
            32'd200,
            "EX/MEM forwarding supplies store data"
        );

        // ------------------------------------------------------------
        // Final result
        // ------------------------------------------------------------

        if (failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.4 EX memory path passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.4 EX memory path failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule