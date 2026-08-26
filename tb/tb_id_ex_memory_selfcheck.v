`timescale 1ns/1ps

module tb_id_ex_memory_selfcheck;

    reg clk;
    reg rst;
    reg flush;

    reg id_valid;
    reg [31:0] id_instruction;
    reg [5:0] id_alu_control;
    reg [31:0] id_pc;
    reg [2:0] id_branch_type;
    reg [1:0] id_jump_type;
    reg id_wb_pc4;
    reg [4:0] id_rd;
    reg [4:0] id_rs1;
    reg [4:0] id_rs2;
    reg [31:0] id_rs1_data;
    reg [31:0] id_rs2_data;
    reg [31:0] id_imm_val;
    reg id_reg_write;

    reg id_mem_read;
    reg id_mem_write;
    reg [1:0] id_mem_size;
    reg id_mem_unsigned;

    wire ex_valid;
    wire [31:0] ex_instruction;
    wire [5:0] ex_alu_control;
    wire [31:0] ex_pc;
    wire [2:0] ex_branch_type;
    wire [1:0] ex_jump_type;
    wire ex_wb_pc4;
    wire [4:0] ex_rd;
    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm_val;
    wire ex_reg_write;

    wire ex_mem_read;
    wire ex_mem_write;
    wire [1:0] ex_mem_size;
    wire ex_mem_unsigned;

    integer failures;

    id_ex_reg dut(
        .clk(clk),
        .rst(rst),
        .flush(flush),

        .id_valid(id_valid),
        .id_instruction(id_instruction),
        .id_alu_control(id_alu_control),
        .id_pc(id_pc),
        .id_branch_type(id_branch_type),
        .id_jump_type(id_jump_type),
        .id_wb_pc4(id_wb_pc4),
        .id_rd(id_rd),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm_val(id_imm_val),
        .id_reg_write(id_reg_write),

        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_mem_size(id_mem_size),
        .id_mem_unsigned(id_mem_unsigned),

        .ex_valid(ex_valid),
        .ex_instruction(ex_instruction),
        .ex_alu_control(ex_alu_control),
        .ex_pc(ex_pc),
        .ex_branch_type(ex_branch_type),
        .ex_jump_type(ex_jump_type),
        .ex_wb_pc4(ex_wb_pc4),
        .ex_rd(ex_rd),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm_val(ex_imm_val),
        .ex_reg_write(ex_reg_write),

        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_size(ex_mem_size),
        .ex_mem_unsigned(ex_mem_unsigned)
    );

    always #5 clk = ~clk;

    task check_memory_controls;
        input expected_read;
        input expected_write;
        input [1:0] expected_size;
        input expected_unsigned;
        input [127:0] test_name;

        begin
            if (ex_mem_read !== expected_read ||
                ex_mem_write !== expected_write ||
                ex_mem_size !== expected_size ||
                ex_mem_unsigned !== expected_unsigned) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  Expected: read=%b write=%b size=%b unsigned=%b",
                         expected_read,
                         expected_write,
                         expected_size,
                         expected_unsigned);

                $display("  Actual:   read=%b write=%b size=%b unsigned=%b",
                         ex_mem_read,
                         ex_mem_write,
                         ex_mem_size,
                         ex_mem_unsigned);

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
        flush = 1'b0;

        id_valid = 1'b0;
        id_instruction = 32'b0;
        id_alu_control = 6'b0;
        id_pc = 32'b0;
        id_branch_type = 3'b0;
        id_jump_type = 2'b0;
        id_wb_pc4 = 1'b0;
        id_rd = 5'b0;
        id_rs1 = 5'b0;
        id_rs2 = 5'b0;
        id_rs1_data = 32'b0;
        id_rs2_data = 32'b0;
        id_imm_val = 32'b0;
        id_reg_write = 1'b0;

        id_mem_read = 1'b0;
        id_mem_write = 1'b0;
        id_mem_size = 2'b00;
        id_mem_unsigned = 1'b0;

        // Reset
        #12;

        rst = 1'b0;

        // ------------------------------------------------------------
        // Test 1: Load control propagation
        // LW -> read=1, write=0, word, signed
        // ------------------------------------------------------------

        id_valid = 1'b1;
        id_mem_read = 1'b1;
        id_mem_write = 1'b0;
        id_mem_size = 2'b10;
        id_mem_unsigned = 1'b0;

        @(posedge clk);
        #1;

        check_memory_controls(
            1'b1,
            1'b0,
            2'b10,
            1'b0,
            "LW memory controls propagate"
        );

        // ------------------------------------------------------------
        // Test 2: Store control propagation
        // SH -> read=0, write=1, halfword
        // ------------------------------------------------------------

        id_mem_read = 1'b0;
        id_mem_write = 1'b1;
        id_mem_size = 2'b01;
        id_mem_unsigned = 1'b0;

        @(posedge clk);
        #1;

        check_memory_controls(
            1'b0,
            1'b1,
            2'b01,
            1'b0,
            "SH memory controls propagate"
        );

        // ------------------------------------------------------------
        // Test 3: Unsigned load propagation
        // LBU -> read=1, write=0, byte, unsigned
        // ------------------------------------------------------------

        id_mem_read = 1'b1;
        id_mem_write = 1'b0;
        id_mem_size = 2'b00;
        id_mem_unsigned = 1'b1;

        @(posedge clk);
        #1;

        check_memory_controls(
            1'b1,
            1'b0,
            2'b00,
            1'b1,
            "LBU memory controls propagate"
        );

        // ------------------------------------------------------------
        // Test 4: Flush must clear memory controls
        // ------------------------------------------------------------

        flush = 1'b1;

        @(posedge clk);
        #1;

        check_memory_controls(
            1'b0,
            1'b0,
            2'b00,
            1'b0,
            "Flush clears memory controls"
        );

        flush = 1'b0;

        // ------------------------------------------------------------
        // Final result
        // ------------------------------------------------------------

        if (failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.3 ID/EX memory controls passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.3 ID/EX memory controls failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule