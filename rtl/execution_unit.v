module execution_unit(clk,rst,ex_rs1_data,ex_rs2_data,ex_pc,ex_rd,ex_alu_control,ex_imm_val,ex_beq_control,ex_bneq_control,ex_bgt_control,ex_blt_control,ex_jump,ex_reg_write,take_branch,take_jump,branch_target,jump_target,mem_rd,mem_reg_write,mem_result);
    input clk,rst;
    input [31:0] ex_pc;
    input [31:0] ex_rs1_data,ex_rs2_data;
    input [4:0] ex_rd;
    input [5:0] ex_alu_control;
    input [31:0] ex_imm_val;
    input ex_beq_control,ex_bneq_control,ex_bgt_control,ex_blt_control,ex_jump,ex_reg_write;

    output [31:0] mem_result;
    output [31:0] branch_target,jump_target;
    output reg take_branch;
    output take_jump,mem_reg_write;
    output [4:0] mem_rd;

    wire [31:0] result;

    alu_unit alu(.ex_alu_control(ex_alu_control),
                 .result(result),
                 .rs1_data(ex_rs1_data),
                 .rs2_data(ex_rs2_data),
                 .imm_val(ex_imm_val));
    
    always @(*) 
        begin
            take_branch = 1'b0;
            if (ex_beq_control)
                take_branch = (ex_rs1_data == ex_rs2_data);
            else if (ex_bneq_control)
                take_branch = (ex_rs1_data != ex_rs2_data);
            else if (ex_blt_control)
                take_branch = ($signed(ex_rs1_data) < $signed(ex_rs2_data));
            else if (ex_bgt_control)
                take_branch = ($signed(ex_rs1_data) > $signed(ex_rs2_data));
        end
    
    assign branch_target = ex_pc + ex_imm_val;
    assign jump_target   = ex_pc + ex_imm_val;
    assign take_jump     = ex_jump;

    ex_mem_reg exmem(.clk(clk),
                     .rst(rst),
                     .ex_result(result),
                     .ex_rd(ex_rd),
                     .ex_reg_write(ex_reg_write),
                     .mem_result(mem_result),
                     .mem_rd(mem_rd),
                     .mem_reg_write(mem_reg_write));
endmodule