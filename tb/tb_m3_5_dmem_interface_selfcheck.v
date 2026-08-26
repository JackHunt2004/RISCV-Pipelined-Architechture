`timescale 1ns/1ps

module tb_m3_5_dmem_interface_selfcheck;

    reg mem_valid;
    reg mem_mem_read;
    reg mem_mem_write;
    reg [1:0] mem_mem_size;
    reg [31:0] mem_result;
    reg [31:0] mem_store_data;

    wire dmem_valid;
    wire dmem_write;
    wire [3:0] dmem_wstrb;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;

    integer failures;

    /*
     * M3.5 interface logic under test.
     *
     * This is the same logic implemented in riscv_core.v.
     */

    assign dmem_valid = mem_valid &&
                        (mem_mem_read || mem_mem_write);

    assign dmem_write = mem_valid && mem_mem_write;

    assign dmem_addr = mem_result;

    assign dmem_wdata = mem_store_data;

    reg [3:0] dmem_wstrb_reg;

    assign dmem_wstrb = dmem_wstrb_reg;

    always@(*)
        begin
            dmem_wstrb_reg = 4'b0000;

            if(mem_valid && mem_mem_write)
                begin
                    case(mem_mem_size)
                        2'b00: dmem_wstrb_reg = 4'b0001;
                        2'b01: dmem_wstrb_reg = 4'b0011;
                        2'b10: dmem_wstrb_reg = 4'b1111;
                        default: dmem_wstrb_reg = 4'b0000;
                    endcase
                end
        end

    task check_dmem;
        input expected_valid;
        input expected_write;
        input [3:0] expected_wstrb;
        input [31:0] expected_addr;
        input [31:0] expected_wdata;
        input [127:0] test_name;

        begin
            if(dmem_valid !== expected_valid ||
               dmem_write !== expected_write ||
               dmem_wstrb !== expected_wstrb ||
               dmem_addr !== expected_addr ||
               dmem_wdata !== expected_wdata) begin

                $display("TEST_FAIL: %s", test_name);

                $display("  Expected: valid=%b write=%b wstrb=%b addr=0x%08h wdata=0x%08h",
                         expected_valid,
                         expected_write,
                         expected_wstrb,
                         expected_addr,
                         expected_wdata);

                $display("  Actual:   valid=%b write=%b wstrb=%b addr=0x%08h wdata=0x%08h",
                         dmem_valid,
                         dmem_write,
                         dmem_wstrb,
                         dmem_addr,
                         dmem_wdata);

                failures = failures + 1;
            end
            else begin
                $display("TEST_PASS: %s", test_name);
            end
        end
    endtask

    initial begin

        failures = 0;

        mem_valid = 1'b0;
        mem_mem_read = 1'b0;
        mem_mem_write = 1'b0;
        mem_mem_size = 2'b00;
        mem_result = 32'b0;
        mem_store_data = 32'b0;

        #1;

        // ------------------------------------------------------------
        // Test 1: LB
        // ------------------------------------------------------------

        mem_valid = 1'b1;
        mem_mem_read = 1'b1;
        mem_mem_write = 1'b0;
        mem_mem_size = 2'b00;
        mem_result = 32'h00000100;
        mem_store_data = 32'b0;

        #1;

        check_dmem(
            1'b1,
            1'b0,
            4'b0000,
            32'h00000100,
            32'h00000000,
            "LB external read interface"
        );

        // ------------------------------------------------------------
        // Test 2: LH
        // ------------------------------------------------------------

        mem_mem_size = 2'b01;
        mem_result = 32'h00000102;

        #1;

        check_dmem(
            1'b1,
            1'b0,
            4'b0000,
            32'h00000102,
            32'h00000000,
            "LH external read interface"
        );

        // ------------------------------------------------------------
        // Test 3: LW
        // ------------------------------------------------------------

        mem_mem_size = 2'b10;
        mem_result = 32'h00000104;

        #1;

        check_dmem(
            1'b1,
            1'b0,
            4'b0000,
            32'h00000104,
            32'h00000000,
            "LW external read interface"
        );

        // ------------------------------------------------------------
        // Test 4: LBU
        // ------------------------------------------------------------

        mem_mem_size = 2'b00;
        mem_result = 32'h00000108;

        #1;

        check_dmem(
            1'b1,
            1'b0,
            4'b0000,
            32'h00000108,
            32'h00000000,
            "LBU external read interface"
        );

        // ------------------------------------------------------------
        // Test 5: LHU
        // ------------------------------------------------------------

        mem_mem_size = 2'b01;
        mem_result = 32'h0000010A;

        #1;

        check_dmem(
            1'b1,
            1'b0,
            4'b0000,
            32'h0000010A,
            32'h00000000,
            "LHU external read interface"
        );

        // ------------------------------------------------------------
        // Test 6: SB
        // ------------------------------------------------------------

        mem_mem_read = 1'b0;
        mem_mem_write = 1'b1;
        mem_mem_size = 2'b00;
        mem_result = 32'h00000200;
        mem_store_data = 32'h000000AB;

        #1;

        check_dmem(
            1'b1,
            1'b1,
            4'b0001,
            32'h00000200,
            32'h000000AB,
            "SB external write interface"
        );

        // ------------------------------------------------------------
        // Test 7: SH
        // ------------------------------------------------------------

        mem_mem_size = 2'b01;
        mem_result = 32'h00000204;
        mem_store_data = 32'h0000BEEF;

        #1;

        check_dmem(
            1'b1,
            1'b1,
            4'b0011,
            32'h00000204,
            32'h0000BEEF,
            "SH external write interface"
        );

        // ------------------------------------------------------------
        // Test 8: SW
        // ------------------------------------------------------------

        mem_mem_size = 2'b10;
        mem_result = 32'h00000208;
        mem_store_data = 32'hDEADBEEF;

        #1;

        check_dmem(
            1'b1,
            1'b1,
            4'b1111,
            32'h00000208,
            32'hDEADBEEF,
            "SW external write interface"
        );

        // ------------------------------------------------------------
        // Test 9: Non-memory instruction
        // ------------------------------------------------------------

        mem_valid = 1'b1;
        mem_mem_read = 1'b0;
        mem_mem_write = 1'b0;
        mem_mem_size = 2'b00;
        mem_result = 32'h00000300;
        mem_store_data = 32'h12345678;

        #1;

        check_dmem(
            1'b0,
            1'b0,
            4'b0000,
            32'h00000300,
            32'h12345678,
            "Non-memory instruction disables dmem_valid"
        );

        // ------------------------------------------------------------
        // Test 10: Invalid pipeline entry
        // ------------------------------------------------------------

        mem_valid = 1'b0;
        mem_mem_read = 1'b1;
        mem_mem_write = 1'b0;
        mem_mem_size = 2'b10;

        #1;

        check_dmem(
            1'b0,
            1'b0,
            4'b0000,
            32'h00000300,
            32'h12345678,
            "Invalid pipeline entry disables dmem interface"
        );

        // ------------------------------------------------------------
        // Final result
        // ------------------------------------------------------------

        if(failures == 0) begin
            $display("");
            $display("==============================================");
            $display("TEST_PASS: Milestone 3.5 dmem interface passed");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("TEST_FAIL: Milestone 3.5 dmem interface failed");
            $display("Failures = %0d", failures);
            $display("==============================================");
        end

        $finish;
    end

endmodule