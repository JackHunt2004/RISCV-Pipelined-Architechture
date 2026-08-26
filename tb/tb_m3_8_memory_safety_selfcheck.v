`timescale 1ns/1ps

module tb_m3_8_memory_safety_selfcheck;

    reg clk,rst;
    reg [31:0] dmem_rdata;

    wire dmem_valid,dmem_write;
    wire [3:0] dmem_wstrb;
    wire [31:0] dmem_addr,dmem_wdata;
    wire [31:0] fetch_pc;

    wire retire_valid,retire_reg_write;
    wire [31:0] retire_pc,retire_instruction,retire_data;
    wire [4:0] retire_rd;

    integer i;
    integer failures;
    integer load_transactions;
    integer store_transactions;
    integer invalid_transactions;

    soc_top dut(.clk(clk),
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
                .retire_data(retire_data));

    always #5 clk=~clk;

    always@(*)
        begin
            if(dmem_valid && !dmem_write)
                dmem_rdata=32'h12345678;
            else
                dmem_rdata=32'b0;
        end

    always@(posedge clk)
        begin
            if(!rst)
                begin
                    if(dmem_valid && !dmem_write)
                        begin
                            load_transactions=load_transactions+1;
                            $display("MEM_LOAD: addr=0x%08h data=0x%08h",
                                     dmem_addr,dmem_rdata);
                        end

                    if(dmem_valid && dmem_write)
                        begin
                            store_transactions=store_transactions+1;
                            $display("MEM_STORE: addr=0x%08h data=0x%08h wstrb=%b",
                                     dmem_addr,dmem_wdata,dmem_wstrb);

                            if(dmem_wstrb!==4'b0001 &&
                               dmem_wstrb!==4'b0011 &&
                               dmem_wstrb!==4'b1111)
                                begin
                                    $display("TEST_FAIL: Invalid store byte-enable");
                                    failures=failures+1;
                                end
                        end

                    if(!dmem_valid &&
                       (dmem_write!==1'b0 || dmem_wstrb!==4'b0000))
                        begin
                            invalid_transactions=invalid_transactions+1;
                            $display("TEST_FAIL: Invalid inactive memory interface");
                            failures=failures+1;
                        end
                end
        end

    initial
        begin
            clk=1'b0;
            rst=1'b1;
            failures=0;
            load_transactions=0;
            store_transactions=0;
            invalid_transactions=0;

            #1;

            for(i=0;i<64;i=i+1)
                dut.im.inst_mem[i]=32'h00000013;

            dut.im.inst_mem[0]=32'h10000093;
            dut.im.inst_mem[1]=32'h0000a103;
            dut.im.inst_mem[2]=32'h0020a023;
            dut.im.inst_mem[3]=32'h00000013;
            dut.im.inst_mem[4]=32'h00000013;
            dut.im.inst_mem[5]=32'h00000013;

            repeat(3) @(posedge clk);
            @(negedge clk);
            rst=1'b0;

            repeat(30) @(posedge clk);
            #1;

            if(load_transactions>0)
                $display("TEST_PASS: Data-memory read transaction observed");
            else
                begin
                    $display("TEST_FAIL: No data-memory read transaction observed");
                    failures=failures+1;
                end

            if(store_transactions>0)
                $display("TEST_PASS: Data-memory write transaction observed");
            else
                begin
                    $display("TEST_FAIL: No data-memory write transaction observed");
                    failures=failures+1;
                end

            if(invalid_transactions==0)
                $display("TEST_PASS: Inactive memory interface remains safe");

            if(failures==0)
                begin
                    $display("");
                    $display("==============================================");
                    $display("TEST_PASS: Milestone 3.8 memory safety passed");
                    $display("==============================================");
                    $finish;
                end
            else
                begin
                    $display("");
                    $display("==============================================");
                    $display("TEST_FAIL: Milestone 3.8 memory safety failed");
                    $display("Failures = %0d",failures);
                    $display("==============================================");
                    $fatal(1);
                end
        end

    initial
        begin
            $dumpfile("build/m3_8_memory_safety.vcd");
            $dumpvars(0,tb_m3_8_memory_safety_selfcheck);
        end

endmodule