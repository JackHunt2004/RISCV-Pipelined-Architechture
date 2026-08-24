`timescale 1ns / 1ps

module tb_branch_selfcheck;

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
        if (!rst && retire_valid) begin
            if (retire_reg_write)
                retired_writes = retired_writes + 1;

            /*
             * Each branch case has a deliberately placed wrong-path
             * ADDI instruction. None of these PCs may retire.
             *
             * Wrong-path PCs:
             *   24, 36, 48, 60, 72, 84
             */
            if (retire_pc == 32'd24 ||
                retire_pc == 32'd36 ||
                retire_pc == 32'd48 ||
                retire_pc == 32'd60 ||
                retire_pc == 32'd72 ||
                retire_pc == 32'd84) begin

                $display(
                    "FAIL: Wrong-path instruction retired at PC %0d",
                    retire_pc
                );

                failures = failures + 1;
            end
        end
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
         * ------------------------------------------------------------
         * Setup
         * ------------------------------------------------------------
         *
         * x1 = 1
         * x2 = 1
         * x3 = -1
         * x4 = 0xffffffff
         * x5 = 0
         *
         * The branch tests use these values to exercise both signed
         * and unsigned comparisons.
         */

        dut.im.inst_mem[0] = 32'h00100093; // ADDI x1, x0, 1
        dut.im.inst_mem[1] = 32'h00100113; // ADDI x2, x0, 1
        dut.im.inst_mem[2] = 32'hfff00193; // ADDI x3, x0, -1
        dut.im.inst_mem[3] = 32'hfff00213; // ADDI x4, x0, -1
        dut.im.inst_mem[4] = 32'h00000293; // ADDI x5, x0, 0

        /*
         * ------------------------------------------------------------
         * Case 1: BEQ taken
         *
         * PC 20: BEQ x1,x2,+8
         * PC 24: wrong path
         * PC 28: target
         *
         * Target writes x6 = 1.
         */
        dut.im.inst_mem[5] = 32'h00208463; // BEQ x1,x2,+8
        dut.im.inst_mem[6] = 32'h06300313; // WRONG PATH: ADDI x6,x0,99
        dut.im.inst_mem[7] = 32'h00100313; // TARGET: ADDI x6,x0,1

        /*
         * ------------------------------------------------------------
         * Case 2: BNE taken
         *
         * PC 32: BNE x1,x3,+8
         * PC 36: wrong path
         * PC 40: target
         *
         * Target writes x7 = 2.
         */
        dut.im.inst_mem[8]  = 32'h00309463; // BNE x1,x3,+8
        dut.im.inst_mem[9]  = 32'h06300393; // WRONG PATH: ADDI x7,x0,99
        dut.im.inst_mem[10] = 32'h00200393; // TARGET: ADDI x7,x0,2

        /*
         * ------------------------------------------------------------
         * Case 3: BLT taken, signed
         *
         * PC 44: BLT x3,x1,+8
         * -1 < +1 => taken
         *
         * PC 48: wrong path
         * PC 52: target
         *
         * Target writes x8 = 3.
         */
        dut.im.inst_mem[11] = 32'h0011c463; // BLT x3,x1,+8
        dut.im.inst_mem[12] = 32'h06300413; // WRONG PATH: ADDI x8,x0,99
        dut.im.inst_mem[13] = 32'h00300413; // TARGET: ADDI x8,x0,3

        /*
         * ------------------------------------------------------------
         * Case 4: BGE taken, signed
         *
         * PC 56: BGE x1,x3,+8
         * +1 >= -1 => taken
         *
         * PC 60: wrong path
         * PC 64: target
         *
         * Target writes x9 = 4.
         */
        dut.im.inst_mem[14] = 32'h0030d463; // BGE x1,x3,+8
        dut.im.inst_mem[15] = 32'h06300493; // WRONG PATH: ADDI x9,x0,99
        dut.im.inst_mem[16] = 32'h00400493; // TARGET: ADDI x9,x0,4

        /*
         * ------------------------------------------------------------
         * Case 5: BLTU taken, unsigned
         *
         * PC 68: BLTU x1,x4,+8
         * 1 < 0xffffffff => taken
         *
         * PC 72: wrong path
         * PC 76: target
         *
         * Target writes x10 = 5.
         */
        dut.im.inst_mem[17] = 32'h0040e463; // BLTU x1,x4,+8
        dut.im.inst_mem[18] = 32'h06300513; // WRONG PATH: ADDI x10,x0,99
        dut.im.inst_mem[19] = 32'h00500513; // TARGET: ADDI x10,x0,5

        /*
         * ------------------------------------------------------------
         * Case 6: BGEU taken, unsigned
         *
         * PC 80: BGEU x4,x1,+8
         * 0xffffffff >= 1 => taken
         *
         * PC 84: wrong path
         * PC 88: target
         *
         * Target writes x11 = 6.
         */
        dut.im.inst_mem[20] = 32'h00127463; // BGEU x4,x1,+8
        dut.im.inst_mem[21] = 32'h06300593; // WRONG PATH: ADDI x11,x0,99
        dut.im.inst_mem[22] = 32'h00600593; // TARGET: ADDI x11,x0,6

        /*
         * ------------------------------------------------------------
         * Not-taken cases
         * ------------------------------------------------------------
         *
         * These branches must fall through to the following ADDI.
         *
         * PC 92: BEQ x1,x3,+8
         * 1 == -1 => false
         * PC 96 executes and writes x12 = 7.
         *
         * PC 100: BLT x1,x3,+8
         * 1 < -1 => false
         * PC 104 executes and writes x13 = 8.
         *
         * PC 108: BLTU x4,x1,+8
         * 0xffffffff < 1 => false
         * PC 112 executes and writes x14 = 9.
         */
        dut.im.inst_mem[23] = 32'h00308463; // BEQ x1,x3,+8
        dut.im.inst_mem[24] = 32'h00700613; // FALL THROUGH: ADDI x12,x0,7
        dut.im.inst_mem[25] = 32'h00000013; // NOP

        dut.im.inst_mem[26] = 32'h0030c463; // BLT x1,x3,+8
        dut.im.inst_mem[27] = 32'h00800693; // FALL THROUGH: ADDI x13,x0,8
        dut.im.inst_mem[28] = 32'h00000013; // NOP

        dut.im.inst_mem[29] = 32'h00126463; // BLTU x4,x1,+8
        dut.im.inst_mem[30] = 32'h00900713; // FALL THROUGH: ADDI x14,x0,9
        dut.im.inst_mem[31] = 32'h00000013; // NOP

        /*
         * Hold reset for three clock edges, then release.
         */
        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        /*
         * Allow all instructions to retire.
         */
        repeat (45) @(posedge clk);
        #1;

        /*
         * ------------------------------------------------------------
         * Architectural checks
         * ------------------------------------------------------------
         */

        check_register(5'd0,  32'h00000000);
        check_register(5'd1,  32'h00000001);
        check_register(5'd2,  32'h00000001);
        check_register(5'd3,  32'hffffffff);
        check_register(5'd4,  32'hffffffff);
        check_register(5'd5,  32'h00000000);

        check_register(5'd6,  32'h00000001);
        check_register(5'd7,  32'h00000002);
        check_register(5'd8,  32'h00000003);
        check_register(5'd9,  32'h00000004);
        check_register(5'd10, 32'h00000005);
        check_register(5'd11, 32'h00000006);

        check_register(5'd12, 32'h00000007);
        check_register(5'd13, 32'h00000008);
        check_register(5'd14, 32'h00000009);

        /*
         * Data memory must remain inactive.
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
         * There are 14 expected architectural register writes:
         * x1-x5 setup + x6-x14 branch results.
         */
        if (retired_writes < 14) begin
            $display(
                "FAIL: Expected at least 14 retired register writes, observed %0d",
                retired_writes
            );
            failures = failures + 1;
        end

        if (failures == 0) begin
            $display("TEST_PASS: Milestone 2B branch regression passed");
            $finish;
        end
        else begin
            $display("TEST_FAIL: %0d checks failed", failures);
            $fatal(1);
        end
    end

    initial begin
        $dumpfile("build/riscv_pipeline_branch_selfcheck.vcd");
        $dumpvars(0, tb_branch_selfcheck);
    end

endmodule