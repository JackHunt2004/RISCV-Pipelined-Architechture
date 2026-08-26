module instruction_decode_unit(clk,rst,flush,id_valid,id_instruction,id_pc,wb_rd,wb_reg_write,wb_result,ex_valid,ex_instruction,ex_alu_control,ex_pc,ex_branch_type,ex_jump_type,ex_wb_pc4,ex_rd,ex_rs1,ex_rs2,ex_rs1_data,ex_rs2_data,ex_imm_val,ex_reg_write,ex_mem_read,ex_mem_write,ex_mem_size,ex_mem_unsigned);
    input clk,rst,flush;
    input id_valid;
    input [31:0] id_instruction,id_pc;
    input [4:0] wb_rd;
    input wb_reg_write;
    input [31:0] wb_result;

    output ex_valid,ex_wb_pc4,ex_reg_write;
    output [31:0] ex_instruction,ex_pc;
    output [5:0] ex_alu_control;
    output [2:0] ex_branch_type;
    output [1:0] ex_jump_type;
    output [4:0] ex_rd,ex_rs1,ex_rs2;
    output [31:0] ex_rs1_data,ex_rs2_data,ex_imm_val;
    output ex_mem_read,ex_mem_write;
    output [1:0] ex_mem_size;
    output ex_mem_unsigned;

    wire [6:0] op_code,func7;
    wire [2:0] func3;
    wire [4:0] rs1,rs2,id_rd;
    wire [31:0] id_rs1_data,id_rs2_data;
    reg [31:0] id_imm_val;

    wire [5:0] id_alu_control;
    wire [2:0] id_branch_type;
    wire [1:0] id_jump_type;
    wire id_reg_write,id_wb_pc4;

    wire mem_read;
    wire mem_write;
    wire [1:0] mem_size;
    wire mem_unsigned;

    assign op_code=id_instruction[6:0];
    assign id_rd=id_instruction[11:7];
    assign func3=id_instruction[14:12];
    assign rs1=id_instruction[19:15];
    assign rs2=id_instruction[24:20];
    assign func7=id_instruction[31:25];

    assign ex_mem_read=ex_mem_read_int;
    assign ex_mem_write=ex_mem_write_int;
    assign ex_mem_size=ex_mem_size_int;
    assign ex_mem_unsigned=ex_mem_unsigned_int;

    wire ex_mem_read_int;
    wire ex_mem_write_int;
    wire [1:0] ex_mem_size_int;
    wire ex_mem_unsigned_int;

    always@(*)
        begin
            id_imm_val=32'b0;

            case(op_code)
                7'b0010011,
                7'b1100111: begin
                    id_imm_val={{20{id_instruction[31]}},
                               id_instruction[31:20]};
                end

                7'b1100011: begin
                    id_imm_val={{19{id_instruction[31]}},
                               id_instruction[31],
                               id_instruction[7],
                               id_instruction[30:25],
                               id_instruction[11:8],
                               1'b0};
                end

                7'b1101111: begin
                    id_imm_val={{11{id_instruction[31]}},
                               id_instruction[31],
                               id_instruction[19:12],
                               id_instruction[20],
                               id_instruction[30:21],
                               1'b0};
                end

                7'b0100011: begin
                    id_imm_val={{20{id_instruction[31]}},
                               id_instruction[31:25],
                               id_instruction[11:7]};
                end

                7'b0000011: begin
                    id_imm_val={{20{id_instruction[31]}},
                               id_instruction[31:20]};
                end

                default: begin
                    id_imm_val=32'b0;
                end
            endcase
        end

    register_file rf(.clk(clk),
                     .rst(rst),
                     .rs1(rs1),
                     .rs2(rs2),
                     .rd(wb_rd),
                     .result(wb_result),
                     .reg_write(wb_reg_write),
                     .rs1_data(id_rs1_data),
                     .rs2_data(id_rs2_data));

    control_unit cu(.op_code(op_code),
                    .func7(func7),
                    .func3(func3),
                    .alu_control(id_alu_control),
                    .branch_type(id_branch_type),
                    .jump_type(id_jump_type),
                    .reg_write(id_reg_write),
                    .wb_pc4(id_wb_pc4),
                    .mem_read(mem_read),
                    .mem_write(mem_write),
                    .mem_size(mem_size),
                    .mem_unsigned(mem_unsigned));

    id_ex_reg idex(.clk(clk),
                   .rst(rst),
                   .flush(flush),
                   .id_valid(id_valid),
                   .id_instruction(id_instruction),
                   .id_alu_control(id_alu_control),
                   .id_pc(id_pc),
                   .id_branch_type(id_branch_type),
                   .id_jump_type(id_jump_type),
                   .id_wb_pc4(id_wb_pc4),
                   .id_rd(id_rd),
                   .id_rs1(rs1),
                   .id_rs2(rs2),
                   .id_rs1_data(id_rs1_data),
                   .id_rs2_data(id_rs2_data),
                   .id_imm_val(id_imm_val),
                   .id_reg_write(id_reg_write),

                   .id_mem_read(mem_read),
                   .id_mem_write(mem_write),
                   .id_mem_size(mem_size),
                   .id_mem_unsigned(mem_unsigned),

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
                   .ex_reg_write(ex_reg_write),

                   .ex_mem_read(ex_mem_read_int),
                   .ex_mem_write(ex_mem_write_int),
                   .ex_mem_size(ex_mem_size_int),
                   .ex_mem_unsigned(ex_mem_unsigned_int));
endmodule