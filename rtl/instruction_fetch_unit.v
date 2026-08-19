module instruction_fetch_unit(clk,rst,flush,take_branch,take_jump,jump_target,branch_target,imem_valid,imem_addr,imem_rdata,id_valid,id_pc,id_instruction);
    input clk,rst,flush;
    input take_branch,take_jump;
    input [31:0] jump_target,branch_target;
    input [31:0] imem_rdata;
    output imem_valid;
    output [31:0] imem_addr;
    output id_valid;
    output [31:0] id_pc,id_instruction;

    reg [31:0] if_pc;
    wire [31:0] next_pc;

    assign imem_valid=1'b1;
    assign imem_addr=if_pc;
    assign next_pc=take_jump ? jump_target :
                   take_branch ? branch_target : if_pc+32'd4;

    always@(posedge clk)
        begin
            if(rst)
                begin
                    if_pc<=32'b0;
                end
            else
                begin
                    if_pc<=next_pc;
                end
        end

    if_id_reg ifid(.clk(clk),
                   .rst(rst),
                   .flush(flush),
                   .if_valid(imem_valid),
                   .if_instruction(imem_rdata),
                   .if_pc(if_pc),
                   .id_valid(id_valid),
                   .id_instruction(id_instruction),
                   .id_pc(id_pc));
endmodule
