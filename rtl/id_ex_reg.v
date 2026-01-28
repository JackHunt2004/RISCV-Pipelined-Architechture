module id_ex_reg (clk,rst,id_alu_control,id_pc,id_beq_control,id_bgt_control,id_blt_control,id_bneq_control,id_rd,id_rs1_data,id_rs2_data,id_imm_val,id_reg_write,ex_alu_control,ex_pc,ex_beq_control,ex_bgt_control,ex_blt_control,ex_bneq_control,ex_rd,ex_rs1_data,ex_rs2_data,ex_imm_val,ex_reg_write);
    input clk,rst;
    input [31:0] id_rs1_data,id_rs2_data;
    input [4:0] id_rd;
    input [31:0] id_pc;
    input id_beq_control,id_bneq_control,id_bgt_control,id_blt_control;
    input id_reg_write;
    input [31:0] id_imm_val;
    input [5:0] id_alu_control;

    output reg [31:0] ex_rs1_data,ex_rs2_data;
    output reg [4:0] ex_rd;
    output reg [31:0] ex_pc;
    output reg ex_beq_control,ex_bneq_control,ex_bgt_control,ex_blt_control;
    output reg ex_reg_write;
    output reg [31:0] ex_imm_val;
    output reg [5:0] ex_alu_control;

    always@(posedge clk)
        if(rst)
            begin
                ex_alu_control<=0;
                ex_beq_control<=0;
                ex_bgt_control<=0;
                ex_blt_control<=0;
                ex_bneq_control<=0;
                ex_imm_val<=0;
                ex_rd<=0;
                ex_rs1_data<=0;
                ex_rs2_data<=0;
                ex_reg_write<=0;
                ex_pc<=0;
            end
        else
            begin
                ex_alu_control<=id_alu_control;
                ex_beq_control<=id_beq_control;
                ex_bgt_control<=id_bgt_control;
                ex_blt_control<=id_blt_control;
                ex_bneq_control<=id_bneq_control;
                ex_imm_val<=id_imm_val;
                ex_rd<=id_rd;
                ex_rs1_data<=id_rs1_data;
                ex_rs2_data<=id_rs2_data;
                ex_pc<=id_pc;
                ex_reg_write<=id_reg_write;
            end
endmodule