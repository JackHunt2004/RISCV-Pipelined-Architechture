module execution_unit(clk,rst,ex_valid,ex_instruction,ex_pc,ex_rs1,ex_rs2,ex_rs1_data,ex_rs2_data,ex_rd,ex_alu_control,ex_imm_val,ex_branch_type,ex_jump_type,ex_wb_pc4,ex_reg_write,wb_rd,wb_reg_write,wb_result,take_branch,take_jump,branch_target,jump_target,mem_valid,mem_instruction,mem_pc,mem_rd,mem_reg_write,mem_result);
    input clk,rst;
    input ex_valid,ex_wb_pc4,ex_reg_write;
    input [31:0] ex_instruction,ex_pc;
    input [4:0] ex_rs1,ex_rs2,ex_rd;
    input [31:0] ex_rs1_data,ex_rs2_data,ex_imm_val;
    input [5:0] ex_alu_control;
    input [2:0] ex_branch_type;
    input [1:0] ex_jump_type;
    input [4:0] wb_rd;
    input wb_reg_write;
    input [31:0] wb_result;

    output reg take_branch;
    output take_jump;
    output [31:0] branch_target,jump_target;
    output mem_valid,mem_reg_write;
    output [31:0] mem_instruction,mem_pc,mem_result;
    output [4:0] mem_rd;

    wire [1:0] forward_a,forward_b;
    reg [31:0] operand_a,operand_b;
    wire [31:0] alu_result,ex_result;

    forwarding_unit fwd(.ex_rs1(ex_rs1),
                        .ex_rs2(ex_rs2),
                        .mem_rd(mem_rd),
                        .mem_reg_write(mem_reg_write),
                        .wb_rd(wb_rd),
                        .wb_reg_write(wb_reg_write),
                        .forward_a(forward_a),
                        .forward_b(forward_b));

    always@(*)
        begin
            case(forward_a)
                2'b10:operand_a=mem_result;
                2'b01:operand_a=wb_result;
                default:operand_a=ex_rs1_data;
            endcase

            case(forward_b)
                2'b10:operand_b=mem_result;
                2'b01:operand_b=wb_result;
                default:operand_b=ex_rs2_data;
            endcase
        end

    alu_unit alu(.ex_alu_control(ex_alu_control),
                 .result(alu_result),
                 .rs1_data(operand_a),
                 .rs2_data(operand_b),
                 .imm_val(ex_imm_val));

    always@(*)
        begin
            take_branch=1'b0;
            if(ex_valid)
                begin
                    case(ex_branch_type)
                        3'd1:take_branch=(operand_a==operand_b);
                        3'd2:take_branch=(operand_a!=operand_b);
                        3'd3:take_branch=($signed(operand_a)<$signed(operand_b));
                        3'd4:take_branch=($signed(operand_a)>=$signed(operand_b));
                        3'd5:take_branch=(operand_a<operand_b);
                        3'd6:take_branch=(operand_a>=operand_b);
                        default:take_branch=1'b0;
                    endcase
                end
        end

    assign branch_target=ex_pc+ex_imm_val;
    assign jump_target=(ex_jump_type==2'd2) ? ((operand_a+ex_imm_val)&32'hfffffffe) : (ex_pc+ex_imm_val);
    assign take_jump=ex_valid && ex_jump_type!=2'd0;
    assign ex_result=ex_wb_pc4 ? ex_pc+32'd4 : alu_result;

    ex_mem_reg exmem(.clk(clk),
                     .rst(rst),
                     .ex_valid(ex_valid),
                     .ex_instruction(ex_instruction),
                     .ex_pc(ex_pc),
                     .ex_result(ex_result),
                     .ex_rd(ex_rd),
                     .ex_reg_write(ex_reg_write),
                     .mem_valid(mem_valid),
                     .mem_instruction(mem_instruction),
                     .mem_pc(mem_pc),
                     .mem_result(mem_result),
                     .mem_rd(mem_rd),
                     .mem_reg_write(mem_reg_write));
endmodule
