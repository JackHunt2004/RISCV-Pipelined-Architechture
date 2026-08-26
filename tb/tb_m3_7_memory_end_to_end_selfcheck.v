`timescale 1ns/1ps

module tb_m3_7_memory_end_to_end_selfcheck;

    reg clk;
    reg rst;

    wire dmem_valid;
    wire dmem_write;
    wire [3:0] dmem_wstrb;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;

    reg [31:0] dmem_rdata;

    wire [31:0] fetch_pc;

    wire retire_valid;
    wire retire_reg_write;
    wire [31:0] retire_pc;
    wire [31:0] retire_instruction;
    wire [4:0] retire_rd;
    wire [31:0] retire_data;

    reg [31:0] data_mem [0:255];

    integer i;
    integer failures;
    integer memory_writes;

    /*
     * ============================================================
     * DUT
     * ============================================================
     */

    soc_top dut(
        .clk(clk),
        .rst(rst),

        .dmem_rdata(dmem_rdata),

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

    /*
     * ============================================================
     * DATA MEMORY READ
     *
     * Single-cycle combinational read.
     *
     * Word addressed using address[9:2].
     * ============================================================
     */

    always @(*) begin
        if(dmem_valid && !dmem_write)
            dmem_rdata = data_mem[dmem_addr[9:2]];
        else
            dmem_rdata = 32'b0;
    end

    /*
     * ============================================================
     * DATA MEMORY WRITE
     *
     * Byte strobes:
     *
     * 0001 = byte 0
     * 0011 = bytes 0-1
     * 1111 = complete word
     * ============================================================
     */

    always @(posedge clk) begin
        if(!rst && dmem_valid && dmem_write) begin

            if(dmem_wstrb[0])
                data_mem[dmem_addr[9:2]][7:0] <= dmem_wdata[7:0];

            if(dmem_wstrb[1])
                data_mem[dmem_addr[9:2]][15:8] <= dmem_wdata[15:8];

            if(dmem_wstrb[2])
                data_mem[dmem_addr[9:2]][23:16] <= dmem_wdata[23:16];

            if(dmem_wstrb[3])
                data_mem[dmem_addr[9:2]][31:24] <= dmem_wdata[31:24];

            memory_writes = memory_writes + 1;
        end
    end

    /*
     * ============================================================
     * REGISTER CHECK
     * ============================================================
     */

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;
        input [127:0] test_name;

        begin
            if(dut.core.IDU.rf.registers[register_number] !== expected_value) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  x%0d expected = 0x%08h",
                         register_number,
                         expected_value);

                $display("  x%0d actual   = 0x%08h",
                         register_number,
                         dut.core.IDU.rf.registers[register_number]);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    /*
     * ============================================================
     * MEMORY CHECK
     * ============================================================
     */

    task check_memory;
        input [31:0] address;
        input [31:0] expected_value;
        input [127:0] test_name;

        begin
            if(data_mem[address[9:2]] !== expected_value) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  Address  = 0x%08h",
                         address);

                $display("  Expected = 0x%08h",
                         expected_value);

                $display("  Actual   = 0x%08h",
                         data_mem[address[9:2]]);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    /*
     * ============================================================
     * MAIN TEST
     * ============================================================
     */

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        failures = 0;
        memory_writes = 0;

        /*
         * --------------------------------------------------------
         * Initialize data memory
         * --------------------------------------------------------
         */

        for(i = 0; i < 256; i = i + 1)
            data_mem[i] = 32'b0;

        /*
         * Initial memory contents.
         *
         * 0x100 = 0x12345678
         * 0x104 = 0x00000080
         * 0x108 = 0x00008000
         * --------------------------------------------------------
         */

        data_mem[32'h100 >> 2] = 32'h12345678;
        data_mem[32'h104 >> 2] = 32'h00000080;
        data_mem[32'h108 >> 2] = 32'h00008000;

        /*
         * --------------------------------------------------------
         * Initialize instruction memory to NOPs
         * --------------------------------------------------------
         */

        #1;

        for(i = 0; i < 64; i = i + 1)
            dut.im.inst_mem[i] = 32'h00000013;

        /*
         * --------------------------------------------------------
         * Program
         *
         * x1 = 0x100
         *
         * LW  x2, 0(x1)
         * LB  x3, 4(x1)
         * LBU x4, 4(x1)
         * LH  x5, 8(x1)
         * LHU x6, 8(x1)
         *
         * SW  x2, 12(x1)
         *
         * --------------------------------------------------------
         */

        dut.im.inst_mem[0] = 32'h10000093; // ADDI x1,x0,0x100

        dut.im.inst_mem[1] = 32'h0000A103; // LW  x2,0(x1)

        dut.im.inst_mem[2] = 32'h00408183; // LB  x3,4(x1)

        dut.im.inst_mem[3] = 32'h0040C203; // LBU x4,4(x1)

        dut.im.inst_mem[4] = 32'h00809283; // LH  x5,8(x1)

        dut.im.inst_mem[5] = 32'h0080D303; // LHU x6,8(x1)

        dut.im.inst_mem[6] = 32'h0020A623; // SW  x2,12(x1)

        dut.im.inst_mem[7] = 32'h0000006F; // Infinite loop

        /*
         * --------------------------------------------------------
         * Release reset
         * --------------------------------------------------------
         */

        repeat(3) @(posedge clk);

        @(negedge clk);

        rst = 1'b0;

        /*
         * Allow pipeline to execute.
         */

        repeat(50) @(posedge clk);

        #1;

        /*
         * --------------------------------------------------------
         * Register checks
         * --------------------------------------------------------
         */

        check_register(
            5'd1,
            32'h00000100,
            "Base address loaded into x1"
        );

        check_register(
            5'd2,
            32'h12345678,
            "LW result reaches x2"
        );

        check_register(
            5'd3,
            32'hFFFFFF80,
            "LB sign extension reaches x3"
        );

        check_register(
            5'd4,
            32'h00000080,
            "LBU zero extension reaches x4"
        );

        check_register(
            5'd5,
            32'hFFFF8000,
            "LH sign extension reaches x5"
        );

        check_register(
            5'd6,
            32'h00008000,
            "LHU zero extension reaches x6"
        );

        /*
         * --------------------------------------------------------
         * Store verification
         * --------------------------------------------------------
         */

        check_memory(
            32'h0000010C,
            32'h12345678,
            "SW writes loaded data to memory"
        );

        /*
         * --------------------------------------------------------
         * Verify memory interface was actually exercised
         * --------------------------------------------------------
         */

        if(memory_writes == 0) begin
            $display("TEST_FAIL: No data-memory writes observed");
            failures = failures + 1;
        end
        else begin
            $display("TEST_PASS: Data-memory write transaction observed");
        end

        /*
         * --------------------------------------------------------
         * Final result
         * --------------------------------------------------------
         */

        if(failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.7 memory end-to-end passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.7 memory end-to-end failed");
            $display("Failures = %0d", failures);
            $display("==============================================");

            $fatal(1);
        end

        $finish;
    end

    initial begin
        $dumpfile("build/m3_7_memory_end_to_end.vcd");
        $dumpvars(0,tb_m3_7_memory_end_to_end_selfcheck);
    end

endmodule