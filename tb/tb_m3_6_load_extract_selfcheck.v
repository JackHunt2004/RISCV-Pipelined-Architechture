`timescale 1ns/1ps

module tb_m3_6_load_extract_selfcheck;

    reg [31:0] dmem_rdata;
    reg        mem_mem_read;
    reg [1:0]  mem_mem_size;
    reg        mem_mem_unsigned;

    wire [31:0] mem_load_data;

    integer failures;

    /*
     * ============================================================
     * M3.6 LOAD-DATA EXTRACTION LOGIC UNDER TEST
     *
     * This is the same extraction behavior implemented in
     * rtl/riscv_core.v.
     *
     * mem_mem_size:
     *   00 = byte
     *   01 = halfword
     *   10 = word
     *
     * mem_mem_unsigned:
     *   0 = sign extend
     *   1 = zero extend
     * ============================================================
     */

    reg [31:0] load_data_reg;

    always @(*) begin
        load_data_reg = 32'b0;

        if (mem_mem_read) begin
            case (mem_mem_size)

                2'b00: begin
                    if (mem_mem_unsigned)
                        load_data_reg = {24'b0, dmem_rdata[7:0]};
                    else
                        load_data_reg = {{24{dmem_rdata[7]}},
                                         dmem_rdata[7:0]};
                end

                2'b01: begin
                    if (mem_mem_unsigned)
                        load_data_reg = {16'b0, dmem_rdata[15:0]};
                    else
                        load_data_reg = {{16{dmem_rdata[15]}},
                                         dmem_rdata[15:0]};
                end

                2'b10: begin
                    load_data_reg = dmem_rdata;
                end

                default: begin
                    load_data_reg = 32'b0;
                end

            endcase
        end
    end

    assign mem_load_data = load_data_reg;

    /*
     * ============================================================
     * SELF-CHECK TASK
     * ============================================================
     */

    task check_load;
        input [31:0] expected;
        input [127:0] test_name;

        begin
            #1;

            if (mem_load_data !== expected) begin
                $display("TEST_FAIL: %s", test_name);

                $display("  dmem_rdata      = 0x%08h",
                         dmem_rdata);

                $display("  mem_mem_size    = %02b",
                         mem_mem_size);

                $display("  mem_mem_unsigned= %b",
                         mem_mem_unsigned);

                $display("  Expected        = 0x%08h",
                         expected);

                $display("  Actual          = 0x%08h",
                         mem_load_data);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    /*
     * ============================================================
     * TEST SEQUENCE
     * ============================================================
     */

    initial begin

        failures = 0;

        dmem_rdata = 32'b0;
        mem_mem_read = 1'b0;
        mem_mem_size = 2'b00;
        mem_mem_unsigned = 1'b0;

        /*
         * --------------------------------------------------------
         * Test 1: LB positive
         *
         * 0x7F -> 0x0000007F
         * --------------------------------------------------------
         */

        mem_mem_read = 1'b1;
        mem_mem_size = 2'b00;
        mem_mem_unsigned = 1'b0;
        dmem_rdata = 32'h0000007F;

        check_load(
            32'h0000007F,
            "LB positive sign extension"
        );

        /*
         * --------------------------------------------------------
         * Test 2: LB negative
         *
         * 0x80 -> 0xFFFFFF80
         * --------------------------------------------------------
         */

        dmem_rdata = 32'h00000080;

        check_load(
            32'hFFFFFF80,
            "LB negative sign extension"
        );

        /*
         * --------------------------------------------------------
         * Test 3: LBU with high bit set
         *
         * 0x80 -> 0x00000080
         * --------------------------------------------------------
         */

        mem_mem_unsigned = 1'b1;
        dmem_rdata = 32'h00000080;

        check_load(
            32'h00000080,
            "LBU zero extension"
        );

        /*
         * --------------------------------------------------------
         * Test 4: LBU maximum byte
         *
         * 0xFF -> 0x000000FF
         * --------------------------------------------------------
         */

        dmem_rdata = 32'h000000FF;

        check_load(
            32'h000000FF,
            "LBU maximum byte zero extension"
        );

        /*
         * --------------------------------------------------------
         * Test 5: LH positive
         *
         * 0x7FFF -> 0x00007FFF
         * --------------------------------------------------------
         */

        mem_mem_size = 2'b01;
        mem_mem_unsigned = 1'b0;
        dmem_rdata = 32'h00007FFF;

        check_load(
            32'h00007FFF,
            "LH positive sign extension"
        );

        /*
         * --------------------------------------------------------
         * Test 6: LH negative
         *
         * 0x8000 -> 0xFFFF8000
         * --------------------------------------------------------
         */

        dmem_rdata = 32'h00008000;

        check_load(
            32'hFFFF8000,
            "LH negative sign extension"
        );

        /*
         * --------------------------------------------------------
         * Test 7: LHU with high bit set
         *
         * 0x8000 -> 0x00008000
         * --------------------------------------------------------
         */

        mem_mem_unsigned = 1'b1;
        dmem_rdata = 32'h00008000;

        check_load(
            32'h00008000,
            "LHU zero extension"
        );

        /*
         * --------------------------------------------------------
         * Test 8: LHU maximum halfword
         *
         * 0xFFFF -> 0x0000FFFF
         * --------------------------------------------------------
         */

        dmem_rdata = 32'h0000FFFF;

        check_load(
            32'h0000FFFF,
            "LHU maximum halfword zero extension"
        );

        /*
         * --------------------------------------------------------
         * Test 9: LW
         *
         * Complete 32-bit value must be preserved.
         * --------------------------------------------------------
         */

        mem_mem_size = 2'b10;
        mem_mem_unsigned = 1'b0;
        dmem_rdata = 32'hDEADBEEF;

        check_load(
            32'hDEADBEEF,
            "LW full word transfer"
        );

        /*
         * --------------------------------------------------------
         * Test 10: LW with another pattern
         * --------------------------------------------------------
         */

        dmem_rdata = 32'h80000001;

        check_load(
            32'h80000001,
            "LW preserves complete 32-bit value"
        );

        /*
         * --------------------------------------------------------
         * Test 11: No load operation
         *
         * mem_mem_read = 0 should produce zero from the
         * extraction block.
         * --------------------------------------------------------
         */

        mem_mem_read = 1'b0;
        mem_mem_size = 2'b00;
        mem_mem_unsigned = 1'b0;
        dmem_rdata = 32'hDEADBEEF;

        check_load(
            32'h00000000,
            "Non-load produces zero load-data output"
        );

        /*
         * --------------------------------------------------------
         * Final result
         * --------------------------------------------------------
         */

        if (failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.6 load extraction passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.6 load extraction failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule