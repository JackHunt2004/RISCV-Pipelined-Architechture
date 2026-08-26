`timescale 1ns/1ps

module tb_memory_decode_selfcheck;

    reg [6:0] op_code;
    reg [6:0] func7;
    reg [2:0] func3;

    wire [5:0] alu_control;
    wire [2:0] branch_type;
    wire [1:0] jump_type;
    wire reg_write;
    wire wb_pc4;

    wire mem_read;
    wire mem_write;
    wire [1:0] mem_size;
    wire mem_unsigned;

    integer failures;

    control_unit dut(
        .op_code(op_code),
        .func7(func7),
        .func3(func3),
        .alu_control(alu_control),
        .branch_type(branch_type),
        .jump_type(jump_type),
        .reg_write(reg_write),
        .wb_pc4(wb_pc4),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned)
    );

    task check_decode;
        input [6:0] test_opcode;
        input [2:0] test_func3;
        input expected_mem_read;
        input expected_mem_write;
        input [1:0] expected_mem_size;
        input expected_mem_unsigned;
        input [5:0] expected_alu_control;
        input [127:0] test_name;

        begin
            op_code = test_opcode;
            func3 = test_func3;
            func7 = 7'b0;

            #1;

            if (mem_read !== expected_mem_read ||
                mem_write !== expected_mem_write ||
                mem_size !== expected_mem_size ||
                mem_unsigned !== expected_mem_unsigned ||
                alu_control !== expected_alu_control) begin

                $display("TEST_FAIL: %s", test_name);
                $display("  Expected: read=%b write=%b size=%b unsigned=%b alu=%d",
                         expected_mem_read,
                         expected_mem_write,
                         expected_mem_size,
                         expected_mem_unsigned,
                         expected_alu_control);

                $display("  Actual:   read=%b write=%b size=%b unsigned=%b alu=%d",
                         mem_read,
                         mem_write,
                         mem_size,
                         mem_unsigned,
                         alu_control);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        failures = 0;

        op_code = 7'b0;
        func7 = 7'b0;
        func3 = 3'b0;

        #1;

        // Loads
        check_decode(
            7'b0000011,
            3'b000,
            1'b1,
            1'b0,
            2'b00,
            1'b0,
            6'd11,
            "LB"
        );

        check_decode(
            7'b0000011,
            3'b001,
            1'b1,
            1'b0,
            2'b01,
            1'b0,
            6'd11,
            "LH"
        );

        check_decode(
            7'b0000011,
            3'b010,
            1'b1,
            1'b0,
            2'b10,
            1'b0,
            6'd11,
            "LW"
        );

        check_decode(
            7'b0000011,
            3'b100,
            1'b1,
            1'b0,
            2'b00,
            1'b1,
            6'd11,
            "LBU"
        );

        check_decode(
            7'b0000011,
            3'b101,
            1'b1,
            1'b0,
            2'b01,
            1'b1,
            6'd11,
            "LHU"
        );

        // Stores
        check_decode(
            7'b0100011,
            3'b000,
            1'b0,
            1'b1,
            2'b00,
            1'b0,
            6'd11,
            "SB"
        );

        check_decode(
            7'b0100011,
            3'b001,
            1'b0,
            1'b1,
            2'b01,
            1'b0,
            6'd11,
            "SH"
        );

        check_decode(
            7'b0100011,
            3'b010,
            1'b0,
            1'b1,
            2'b10,
            1'b0,
            6'd11,
            "SW"
        );

        // Non-memory instruction: ADDI
        check_decode(
            7'b0010011,
            3'b000,
            1'b0,
            1'b0,
            2'b00,
            1'b0,
            6'd11,
            "ADDI non-memory control check"
        );

        if (failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.2 memory decode passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.2 memory decode failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule