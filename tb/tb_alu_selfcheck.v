`timescale 1ns / 1ps

module tb_alu_selfcheck;

    reg clk, rst;
    integer i;
    integer failures;
    integer retired_writes;

    wire dmem_valid, dmem_write;
    wire [3:0] dmem_wstrb;
    wire [31:0] dmem_addr, dmem_wdata;
    wire [31:0] fetch_pc;

    wire retire_valid, retire_reg_write;
    wire [31:0] retire_pc, retire_instruction, retire_data;
    wire [4:0] retire_rd;

    soc_top dut(
        .clk(clk),
        .rst(rst),
        .dmem_rdata(32'b0),
        .dmem_valid(dmem_valid),
        .dmem_write(dmem_write),
        .dmem_wstrb(dmem_wstrb),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .fetch_pc(fetch_pc),
        .retire_valid(retire_valid),
        .retire_pc(retire_pc),
        .retire_instruction(retire_instruction),
        .retire_reg_write(retire_reg_write),
        .retire_rd(retire_rd),
        .retire_data(retire_data)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!rst && retire_valid && retire_reg_write)
            retired_writes = retired_writes + 1;
    end

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;
        begin
            if (dut.core.IDU.rf.registers[register_number] !== expected_value) begin
                $display(
                    "FAIL: x%0d expected %h, got %h",
                    register_number,
                    expected_value,
                    dut.core.IDU.rf.registers[register_number]
                );
                failures = failures + 1;
            end
            else begin
                $display(
                    "PASS: x%0d = %h",
                    register_number,
                    expected_value
                );
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        failures = 0;
        retired_writes = 0;

        #1;

        /*
         * Fill instruction memory with NOPs.
         */
        for (i = 0; i < 64; i = i + 1)
            dut.im.inst_mem[i] = 32'h00000013;

        /*
         * Program
         *
         * x1  = 1
         * x2  = 31
         * x3  = -1
         * x4  = 0x80000000
         *
         * R-type coverage:
         * SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
         *
         * I-type coverage:
         * SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
         *
         * Results are deliberately chosen to exercise signed/unsigned
         * comparisons and arithmetic/logical right shifts.
         */

        // Setup
        dut.im.inst_mem[0] = 32'h00100093; // ADDI  x1, x0, 1
        dut.im.inst_mem[1] = 32'h01f00113; // ADDI  x2, x0, 31
        dut.im.inst_mem[2] = 32'hfff00193; // ADDI  x3, x0, -1
        dut.im.inst_mem[3] = 32'h80000213; // ADDI  x4, x0, 0x800

        /*
         * R-type operations
         *
         * x5  = x1 << x2[4:0]       = 0x80000000
         * x6  = signed(x3) < signed(x1)  = 1
         * x7  = unsigned(x3) < unsigned(x1) = 0
         * x8  = x3 ^ x1              = 0xfffffffe
         * x9  = x4 >> x2             = 0x00000001
         * x10 = x3 >>> x2            = 0xffffffff
         * x11 = x3 | x1              = 0xffffffff
         * x12 = x3 & x1              = 0x00000001
         */
        dut.im.inst_mem[4]  = 32'h002092b3; // SLL  x5,  x1, x2
        dut.im.inst_mem[5]  = 32'h0011a333; // SLT  x6,  x3, x1
        dut.im.inst_mem[6]  = 32'h0011b3b3; // SLTU x7,  x3, x1
        dut.im.inst_mem[7]  = 32'h0011c433; // XOR  x8,  x3, x1
        dut.im.inst_mem[8]  = 32'h002254b3; // SRL  x9,  x4, x2
        dut.im.inst_mem[9]  = 32'h4021d533; // SRA  x10, x3, x2
        dut.im.inst_mem[10] = 32'h0011e5b3; // OR   x11, x3, x1
        dut.im.inst_mem[11] = 32'h0011f633; // AND  x12, x3, x1

        /*
         * I-type operations
         *
         * x13 = signed(-1) < signed(1) = 1
         * x14 = unsigned(-1) < unsigned(1) = 0
         * x15 = -1 ^ 1 = 0xfffffffe
         * x16 = 0x80000000 >> 31 = 1
         * x17 = -1 >>> 31 = 0xffffffff
         * x18 = -1 | 1 = 0xffffffff
         * x19 = -1 & 1 = 1
         */
        dut.im.inst_mem[12] = 32'h0011a693; // SLTI  x13, x3, 1
        dut.im.inst_mem[13] = 32'h0011b713; // SLTIU x14, x3, 1
        dut.im.inst_mem[14] = 32'h0011c793; // XORI  x15, x3, 1
        dut.im.inst_mem[15] = 32'h01f25813; // SRLI  x16, x4, 31
        dut.im.inst_mem[16] = 32'h41f1d893; // SRAI  x17, x3, 31
        dut.im.inst_mem[17] = 32'h0011e913; // ORI   x18, x3, 1
        dut.im.inst_mem[18] = 32'h0011f993; // ANDI  x19, x3, 1

        /*
         * NOP after the tested program.
         */
        dut.im.inst_mem[19] = 32'h00000013;

        /*
         * Hold reset for three clock edges, then release.
         */
        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        /*
         * Allow the pipeline to retire the complete program.
         */
        repeat (30) @(posedge clk);
        #1;

        /*
         * Architectural checks.
         */
        check_register(5'd0,  32'h00000000);
        check_register(5'd1,  32'h00000001);
        check_register(5'd2,  32'h0000001f);
        check_register(5'd3,  32'hffffffff);
        check_register(5'd4,  32'hfffff800);

        check_register(5'd5,  32'h80000000);
        check_register(5'd6,  32'h00000001);
        check_register(5'd7,  32'h00000000);
        check_register(5'd8,  32'hfffffffe);
        check_register(5'd9,  32'h00000001);
        check_register(5'd10, 32'hffffffff);
        check_register(5'd11, 32'hffffffff);
        check_register(5'd12, 32'h00000001);

        check_register(5'd13, 32'h00000001);
        check_register(5'd14, 32'h00000000);
        check_register(5'd15, 32'hfffffffe);
        check_register(5'd16, 32'h00000001);
        check_register(5'd17, 32'hffffffff);
        check_register(5'd18, 32'hffffffff);
        check_register(5'd19, 32'h00000001);

        /*
         * The ALU-only program must not access data memory.
         */
        if (dmem_valid !== 1'b0 ||
            dmem_write !== 1'b0 ||
            dmem_wstrb !== 4'b0 ||
            dmem_addr !== 32'b0 ||
            dmem_wdata !== 32'b0) begin

            $display("FAIL: Data memory interface is not inactive");
            failures = failures + 1;
        end

        /*
         * The program contains 19 instructions that write registers.
         */
        if (retired_writes < 19) begin
            $display(
                "FAIL: Expected at least 19 retired register writes, observed %0d",
                retired_writes
            );
            failures = failures + 1;
        end

        if (failures == 0) begin
            $display("TEST_PASS: Milestone 2 ALU/ISA regression passed");
            $finish;
        end
        else begin
            $display("TEST_FAIL: %0d checks failed", failures);
            $fatal(1);
        end
    end

    initial begin
        $dumpfile("build/riscv_pipeline_alu_selfcheck.vcd");
        $dumpvars(0, tb_alu_selfcheck);
    end

endmodule