module id_ex_reg(clk,rst,flush,id_valid,id_instruction,id_alu_control,id_pc,id_branch_type,id_jump_type,id_wb_pc4,id_rd,id_rs1,id_rs2,id_rs1_data,id_rs2_data,id_imm_val,id_reg_write,ex_valid,ex_instruction,ex_alu_control,ex_pc,ex_branch_type,ex_jump_type,ex_wb_pc4,ex_rd,ex_rs1,ex_rs2,ex_rs1_data,ex_rs2_data,ex_imm_val,ex_reg_write);
    input clk,rst,flush;
    input id_valid,id_wb_pc4,id_reg_write;
    input [31:0] id_instruction,id_pc;
    input [5:0] id_alu_control;
    input [2:0] id_branch_type;
    input [1:0] id_jump_type;
    input [4:0] id_rd,id_rs1,id_rs2;
    input [31:0] id_rs1_data,id_rs2_data,id_imm_val;

    output reg ex_valid,ex_wb_pc4,ex_reg_write;
    output reg [31:0] ex_instruction,ex_pc;
    output reg [5:0] ex_alu_control;
    output reg [2:0] ex_branch_type;
    output reg [1:0] ex_jump_type;
    output reg [4:0] ex_rd,ex_rs1,ex_rs2;
    output reg [31:0] ex_rs1_data,ex_rs2_data,ex_imm_val;

    always@(posedge clk)
        begin
            if(rst || flush)
                begin
                    ex_valid<=1'b0;
                    ex_instruction<=32'h00000013;
                    ex_alu_control<=6'b0;
                    ex_pc<=32'b0;
                    ex_branch_type<=3'b0;
                    ex_jump_type<=2'b0;
                    ex_wb_pc4<=1'b0;
                    ex_rd<=5'b0;
                    ex_rs1<=5'b0;
                    ex_rs2<=5'b0;
                    ex_rs1_data<=32'b0;
                    ex_rs2_data<=32'b0;
                    ex_imm_val<=32'b0;
                    ex_reg_write<=1'b0;
                end
            else
                begin
                    ex_valid<=id_valid;
                    ex_instruction<=id_instruction;
                    ex_alu_control<=id_alu_control;
                    ex_pc<=id_pc;
                    ex_branch_type<=id_branch_type;
                    ex_jump_type<=id_jump_type;
                    ex_wb_pc4<=id_wb_pc4;
                    ex_rd<=id_rd;
                    ex_rs1<=id_rs1;
                    ex_rs2<=id_rs2;
                    ex_rs1_data<=id_rs1_data;
                    ex_rs2_data<=id_rs2_data;
                    ex_imm_val<=id_imm_val;
                    ex_reg_write<=id_reg_write && id_valid;
                end
        end
endmodule
