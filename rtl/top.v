module top (clk,rst);
    input clk,rst;

    wire [31:0] id_instruction;
    wire [31:0] id_pc;

    wire [31:0] ex_pc;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm_val;
    wire [4:0]  ex_rd;
    wire [5:0]  ex_alu_control;
    wire        ex_beq_control;
    wire        ex_bneq_control;
    wire        ex_bgt_control;
    wire        ex_blt_control;
    wire        ex_jump;
    wire        ex_reg_write;

    wire        take_branch;
    wire        take_jump;
    wire [31:0] branch_target;
    wire [31:0] jump_target;

    wire [31:0] mem_result;
    wire [4:0]  mem_rd;
    wire        mem_reg_write;

    wire [31:0] wb_result;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;

    instruction_fetch_unit IFU (.clk(clk),
                                .rst(rst),
                                .take_branch(take_branch),
                                .take_jump(take_jump),
                                .branch_target(branch_target),
                                .jump_target(jump_target),
                                .id_instruction(id_instruction),
                                .id_pc(id_pc));

    instruction_decode_unit IDU (.clk(clk),
                                 .rst(rst),
                                 .id_instruction(id_instruction),
                                 .id_pc(id_pc),
                                 .wb_rd(wb_rd),
                                 .wb_result(wb_result),
                                 .ex_pc(ex_pc),
                                 .ex_rs1_data(ex_rs1_data),
                                 .ex_rs2_data(ex_rs2_data),
                                 .ex_imm_val(ex_imm_val),
                                 .ex_rd(ex_rd),
                                 .ex_alu_control(ex_alu_control),
                                 .wb_reg_write(wb_reg_write));

    execution_unit EXU (.clk(clk),
                        .rst(rst),
                        .ex_pc(ex_pc),
                        .ex_rs1_data(ex_rs1_data),
                        .ex_rs2_data(ex_rs2_data),
                        .ex_imm_val(ex_imm_val),
                        .ex_rd(ex_rd),
                        .ex_alu_control(ex_alu_control),
                        .ex_beq_control(ex_beq_control),
                        .ex_bneq_control(ex_bneq_control),
                        .ex_bgt_control(ex_bgt_control),
                        .ex_blt_control(ex_blt_control),
                        .ex_jump(ex_jump),
                        .ex_reg_write(ex_reg_write),
                        .take_branch(take_branch),
                        .take_jump(take_jump),
                        .branch_target(branch_target),
                        .jump_target(jump_target),
                        .mem_result(mem_result),
                        .mem_rd(mem_rd),
                        .mem_reg_write(mem_reg_write));

    mem_wb_reg MEMWB (.clk(clk),
                     .rst(rst),
                     .mem_result(mem_result),
                     .mem_rd(mem_rd),
                     .mem_reg_write(mem_reg_write),
                     .wb_result(wb_result),
                     .wb_rd(wb_rd),
                     .wb_reg_write(wb_reg_write));

endmodule