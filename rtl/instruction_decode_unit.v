module instruction_decode_unit(clk,rst,id_instruction,id_pc,wb_rd,wb_reg_write,wb_result,ex_alu_control,ex_pc,ex_rs1_data,ex_rs2_data,ex_imm_val,ex_rd);
    input clk,rst;
    input [31:0] id_instruction;
    input [31:0] id_pc;
    input [4:0] wb_rd;
    input [31:0] wb_result;
    input wb_reg_write;

    output [31:0] ex_pc;
    output [31:0] ex_rs1_data,ex_rs2_data;
    output [31:0] ex_imm_val;
    output [4:0] ex_rd;
    output [5:0] ex_alu_control;

    wire [31:0] id_rs1_data, id_rs2_data;
    reg [31:0] id_imm_val;
    wire [6:0] op_code;
    wire [2:0] func3;
    wire [6:0] func7;
    wire [4:0] rs1,rs2,id_rd;
    reg id_reg_write;

    wire [5:0] id_alu_control;
    wire id_beq_control,id_bgt_control,id_bneq,id_blt_control;
    
    assign op_code = id_instruction[6:0];
    assign id_rd = id_instruction[11:7];
    assign func3 = id_instruction[14:12];
    assign rs1 = id_instruction[19:15];
    assign rs2 = id_instruction[24:20];
    assign func7 = id_instruction[31:25];

    always@(*)
        begin
            id_imm_val=32'b0;
            id_reg_write=1'b0;
            case(op_code)
                7'b0010011,
                7'b1100111:begin
                            id_imm_val = {{20{id_instruction[31]}},id_instruction[31:20]};
                            id_reg_write=1'b1;
                           end
                7'b1100011:begin
                            id_imm_val = {{19{id_instruction[31]}},id_instruction[31],id_instruction[7],id_instruction[30:25],id_instruction[11:8],1'b0};
                           end
                7'b1101111:begin
                            id_imm_val = {{11{id_instruction[31]}},id_instruction[31],id_instruction[19:12],id_instruction[20],id_instruction[30:21],1'b0};
                           end
                7'b0110011: id_reg_write = 1'b1;

                default: begin
                            id_imm_val=32'b0;
                            id_reg_write=1'b0;
                         end  
            endcase
        end

    register_file rf(.clk(clk),
                     .rst(rst),
                     .rs1(rs1),
                     .rs2(rs2),
                     .rd(wb_rd),
                     .rs1_data(id_rs1_data),
                     .rs2_data(id_rs2_data),
                     .result(wb_result),
                     .reg_write(wb_reg_write));
    
    control_unit cu(.op_code(op_code),
                    .func7(func7),
                    .func3(func3),
                    .alu_control(id_alu_control),
                    .beq_control(id_beq_control),
                    .bneq_control(id_bneq_control),
                    .bgt_control(id_bgt_control),
                    .blt_control(id_blt_control),
                    .jump(id_jump));
    
    id_ex_reg idex(.clk(clk),
                   .rst(rst),
                   .id_alu_control(id_alu_control),
                   .id_beq_control(id_beq_control),
                   .id_bgt_control(id_bgt_control),
                   .id_blt_control(id_blt_control),
                   .id_bneq_control(id_bneq_control),
                   .id_rd(id_rd),
                   .id_rs1_data(id_rs1_data),
                   .id_rs2_data(id_rs2_data),
                   .id_imm_val(id_imm_val),
                   .id_pc(id_pc),
                   .id_reg_write(id_reg_write),
                   .ex_pc(ex_pc),
                   .ex_alu_control(ex_alu_control),
                   .ex_beq_control(ex_beq_control),
                   .ex_bgt_control(ex_bgt_control),
                   .ex_blt_control(ex_blt_control),
                   .ex_bneq_control(ex_bneq_control),
                   .ex_rd(ex_rd),
                   .ex_rs1_data(ex_rs1_data),
                   .ex_rs2_data(ex_rs2_data),
                   .ex_imm_val(ex_imm_val));
endmodule