`timescale 1ns / 1ps
module tb_top_selfcheck;
    reg clk,rst;
    integer i;
    integer failures,retired_writes;

    wire dmem_valid,dmem_write;
    wire [3:0] dmem_wstrb;
    wire [31:0] dmem_addr,dmem_wdata;
    wire [31:0] fetch_pc;
    wire retire_valid,retire_reg_write;
    wire [31:0] retire_pc,retire_instruction,retire_data;
    wire [4:0] retire_rd;

    soc_top dut(.clk(clk),
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
                .retire_data(retire_data));

    always #5 clk=~clk;

    always@(posedge clk)
        begin
            if(!rst && retire_valid)
                begin
                    if(retire_reg_write)
                        begin
                            retired_writes=retired_writes+1;
                        end
                    if(retire_pc==32'd28 || retire_pc==32'd36)
                        begin
                            $display("FAIL: Wrong path instruction retired at PC %0d",retire_pc);
                            failures=failures+1;
                        end
                end
        end

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;
        begin
            if(dut.core.IDU.rf.registers[register_number]!==expected_value)
                begin
                    $display("FAIL: x%0d expected %h, got %h",register_number,expected_value,dut.core.IDU.rf.registers[register_number]);
                    failures=failures+1;
                end
            else
                begin
                    $display("PASS: x%0d = %h",register_number,expected_value);
                end
        end
    endtask

    initial
        begin
            clk=1'b0;
            rst=1'b1;
            failures=0;
            retired_writes=0;

            #1;
            for(i=0;i<64;i=i+1)
                begin
                    dut.im.inst_mem[i]=32'h00000013;
                end

            dut.im.inst_mem[0]=32'h00500093;
            dut.im.inst_mem[1]=32'h00700113;
            dut.im.inst_mem[2]=32'h002081b3;
            dut.im.inst_mem[3]=32'h00319213;
            dut.im.inst_mem[4]=32'h00126293;
            dut.im.inst_mem[5]=32'h4022d313;
            dut.im.inst_mem[6]=32'h00135463;
            dut.im.inst_mem[7]=32'h06300393; // Wrong Path
            dut.im.inst_mem[8]=32'h0080046f;
            dut.im.inst_mem[9]=32'h06300493; // Wrong Path
            dut.im.inst_mem[10]=32'h03000513;
            dut.im.inst_mem[11]=32'h000505e7;
            dut.im.inst_mem[12]=32'h02a00613;
            dut.im.inst_mem[13]=32'h0000006f;

            repeat(3) @(posedge clk);
            @(negedge clk);
            rst=1'b0;
            repeat(40) @(posedge clk);
            #1;

            check_register(5'd0,32'd0);
            check_register(5'd1,32'd5);
            check_register(5'd2,32'd7);
            check_register(5'd3,32'd12);
            check_register(5'd4,32'd96);
            check_register(5'd5,32'd97);
            check_register(5'd6,32'd24);
            check_register(5'd7,32'd0);
            check_register(5'd8,32'd36);
            check_register(5'd9,32'd0);
            check_register(5'd10,32'd48);
            check_register(5'd11,32'd48);
            check_register(5'd12,32'd42);

            if(dmem_valid!==1'b0 || dmem_write!==1'b0 || dmem_wstrb!==4'b0 || dmem_addr!==32'b0 || dmem_wdata!==32'b0)
                begin
                    $display("FAIL: Data memory interface is not inactive");
                    failures=failures+1;
                end

            if(retired_writes<10)
                begin
                    $display("FAIL: Retirement interface observed only %0d writes",retired_writes);
                    failures=failures+1;
                end

            if(failures==0)
                begin
                    $display("TEST_PASS: Architecture-correct Milestone 1 regression passed");
                    $finish;
                end
            else
                begin
                    $display("TEST_FAIL: %0d checks failed",failures);
                    $fatal(1);
                end
        end

    initial
        begin
            $dumpfile("build/riscv_pipeline_selfcheck.vcd");
            $dumpvars(0,tb_top_selfcheck);
        end
endmodule
