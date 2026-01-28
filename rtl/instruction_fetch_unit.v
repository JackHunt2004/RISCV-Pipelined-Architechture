module instruction_fetch_unit(clk,rst,take_branch,take_jump,jump_target,branch_target,id_pc,id_instruction);
    input clk,rst,take_branch,take_jump;
    input [31:0] jump_target,branch_target;
    output [31:0] id_pc;
    output [31:0] id_instruction;

    reg  [31:0] if_pc;
    wire [31:0] next_pc;
    wire [31:0] if_instruction;

    assign next_pc = (take_jump === 1'b1) ? jump_target : (take_branch === 1'b1) ? branch_target : if_pc + 32'd4;

    always@(posedge clk)
        if(rst)
            begin
                if_pc <= 32'b0;
            end
        else
            begin
                if_pc <= next_pc;
            end
    
    instruction_memory im(.if_pc(if_pc),
                          .if_instruction(if_instruction));
    
    if_id_reg ifid(.clk(clk),
                   .rst(rst),
                   .if_instruction(if_instruction),
                   .id_instruction(id_instruction),
                   .if_pc(if_pc),
                   .id_pc(id_pc));
endmodule