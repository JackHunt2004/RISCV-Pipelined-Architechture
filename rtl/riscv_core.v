module riscv_core(clk,rst,imem_valid,imem_addr,imem_rdata,dmem_valid,dmem_write,dmem_wstrb,dmem_addr,dmem_wdata,dmem_rdata,retire_valid,retire_pc,retire_instruction,retire_reg_write,retire_rd,retire_data);
    input clk,rst;
    input [31:0] imem_rdata,dmem_rdata;
    output imem_valid;
    output [31:0] imem_addr;
    output dmem_valid,dmem_write;
    output [3:0] dmem_wstrb;
    output [31:0] dmem_addr,dmem_wdata;
    output retire_valid,retire_reg_write;
    output [31:0] retire_pc,retire_instruction,retire_data;
    output [4:0] retire_rd;

    wire id_valid;
    wire [31:0] id_instruction,id_pc;

    wire ex_valid,ex_wb_pc4,ex_reg_write;
    wire [31:0] ex_instruction,ex_pc;
    wire [4:0] ex_rs1,ex_rs2,ex_rd;
    wire [31:0] ex_rs1_data,ex_rs2_data,ex_imm_val;
    wire [5:0] ex_alu_control;
    wire [2:0] ex_branch_type;
    wire [1:0] ex_jump_type;

    wire take_branch,take_jump,redirect;
    wire [31:0] branch_target,jump_target;

    wire mem_valid,mem_reg_write;
    wire [31:0] mem_instruction,mem_pc,mem_result;
    wire [4:0] mem_rd;

    wire wb_valid,wb_reg_write;
    wire [31:0] wb_instruction,wb_pc,wb_result;
    wire [4:0] wb_rd;

    assign redirect=take_branch | take_jump;

    // Data memory interface will be used for Load and Store Instructions
    assign dmem_valid=1'b0;
    assign dmem_write=1'b0;
    assign dmem_wstrb=4'b0;
    assign dmem_addr=32'b0;
    assign dmem_wdata=32'b0;

    assign retire_valid=wb_valid;
    assign retire_pc=wb_pc;
    assign retire_instruction=wb_instruction;
    assign retire_reg_write=wb_reg_write;
    assign retire_rd=wb_rd;
    assign retire_data=wb_result;

    instruction_fetch_unit IFU(.clk(clk),
                               .rst(rst),
                               .flush(redirect),
                               .take_branch(take_branch),
                               .take_jump(take_jump),
                               .jump_target(jump_target),
                               .branch_target(branch_target),
                               .imem_valid(imem_valid),
                               .imem_addr(imem_addr),
                               .imem_rdata(imem_rdata),
                               .id_valid(id_valid),
                               .id_pc(id_pc),
                               .id_instruction(id_instruction));

    instruction_decode_unit IDU(.clk(clk),
                                .rst(rst),
                                .flush(redirect),
                                .id_valid(id_valid),
                                .id_instruction(id_instruction),
                                .id_pc(id_pc),
                                .wb_rd(wb_rd),
                                .wb_reg_write(wb_reg_write),
                                .wb_result(wb_result),
                                .ex_valid(ex_valid),
                                .ex_instruction(ex_instruction),
                                .ex_alu_control(ex_alu_control),
                                .ex_pc(ex_pc),
                                .ex_branch_type(ex_branch_type),
                                .ex_jump_type(ex_jump_type),
                                .ex_wb_pc4(ex_wb_pc4),
                                .ex_rd(ex_rd),
                                .ex_rs1(ex_rs1),
                                .ex_rs2(ex_rs2),
                                .ex_rs1_data(ex_rs1_data),
                                .ex_rs2_data(ex_rs2_data),
                                .ex_imm_val(ex_imm_val),
                                .ex_reg_write(ex_reg_write));

    execution_unit EXU(.clk(clk),
                       .rst(rst),
                       .ex_valid(ex_valid),
                       .ex_instruction(ex_instruction),
                       .ex_pc(ex_pc),
                       .ex_rs1(ex_rs1),
                       .ex_rs2(ex_rs2),
                       .ex_rs1_data(ex_rs1_data),
                       .ex_rs2_data(ex_rs2_data),
                       .ex_rd(ex_rd),
                       .ex_alu_control(ex_alu_control),
                       .ex_imm_val(ex_imm_val),
                       .ex_branch_type(ex_branch_type),
                       .ex_jump_type(ex_jump_type),
                       .ex_wb_pc4(ex_wb_pc4),
                       .ex_reg_write(ex_reg_write),
                       .wb_rd(wb_rd),
                       .wb_reg_write(wb_reg_write),
                       .wb_result(wb_result),
                       .take_branch(take_branch),
                       .take_jump(take_jump),
                       .branch_target(branch_target),
                       .jump_target(jump_target),
                       .mem_valid(mem_valid),
                       .mem_instruction(mem_instruction),
                       .mem_pc(mem_pc),
                       .mem_rd(mem_rd),
                       .mem_reg_write(mem_reg_write),
                       .mem_result(mem_result));

    mem_wb_reg MEMWB(.clk(clk),
                     .rst(rst),
                     .mem_valid(mem_valid),
                     .mem_instruction(mem_instruction),
                     .mem_pc(mem_pc),
                     .mem_rd(mem_rd),
                     .mem_reg_write(mem_reg_write),
                     .mem_result(mem_result),
                     .wb_valid(wb_valid),
                     .wb_instruction(wb_instruction),
                     .wb_pc(wb_pc),
                     .wb_rd(wb_rd),
                     .wb_reg_write(wb_reg_write),
                     .wb_result(wb_result));
endmodule
