module riscv_core(clk,rst,imem_valid,imem_addr,imem_rdata,dmem_valid,dmem_write,dmem_wstrb,dmem_addr,dmem_wdata,dmem_rdata,retire_valid,retire_pc,retire_instruction,retire_reg_write,retire_rd,retire_data);
    input clk,rst;

    input [31:0] imem_rdata;
    input [31:0] dmem_rdata;

    output imem_valid;
    output [31:0] imem_addr;

    output dmem_valid,dmem_write;
    output [3:0] dmem_wstrb;
    output [31:0] dmem_addr,dmem_wdata;

    output retire_valid,retire_reg_write;
    output [31:0] retire_pc,retire_instruction,retire_data;
    output [4:0] retire_rd;


    /*
     * ============================================================
     * IF / ID
     * ============================================================
     */

    wire id_valid;
    wire [31:0] id_instruction,id_pc;


    /*
     * ============================================================
     * ID / EX
     * ============================================================
     */

    wire ex_valid;
    wire ex_wb_pc4;
    wire ex_reg_write;

    wire [31:0] ex_instruction;
    wire [31:0] ex_pc;

    wire [4:0] ex_rs1,ex_rs2,ex_rd;

    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm_val;

    wire [5:0] ex_alu_control;
    wire [2:0] ex_branch_type;
    wire [1:0] ex_jump_type;

    wire ex_mem_read;
    wire ex_mem_write;
    wire ex_mem_unsigned;
    wire [1:0] ex_mem_size;


    /*
     * ============================================================
     * BRANCH / JUMP
     * ============================================================
     */

    wire take_branch;
    wire take_jump;
    wire redirect;

    wire [31:0] branch_target;
    wire [31:0] jump_target;

    assign redirect = take_branch | take_jump;


    /*
     * ============================================================
     * EX / MEM
     * ============================================================
     */

    wire mem_valid;
    wire mem_reg_write;

    wire [31:0] mem_instruction;
    wire [31:0] mem_pc;
    wire [31:0] mem_result;
    wire [31:0] mem_store_data;

    wire [4:0] mem_rd;

    wire mem_mem_read;
    wire mem_mem_write;
    wire mem_mem_unsigned;
    wire [1:0] mem_mem_size;


    /*
     * ============================================================
     * MEM / WB
     * ============================================================
     */

    wire wb_valid;
    wire wb_reg_write;

    wire [31:0] wb_instruction;
    wire [31:0] wb_pc;
    wire [31:0] wb_result;

    wire [4:0] wb_rd;


    /*
     * ============================================================
     * M3.7 LOAD DATA EXTRACTION
     *
     * mem_result = effective address
     * dmem_rdata = data returned by external data memory
     *
     * For loads, convert the memory data into the correct
     * architectural 32-bit value.
     *
     * mem_mem_size:
     *   00 = byte
     *   01 = halfword
     *   10 = word
     *
     * mem_mem_unsigned:
     *   0 = signed load
     *   1 = unsigned load
     * ============================================================
     */

    reg [31:0] mem_load_data;

    always @(*)
        begin
            mem_load_data = 32'b0;

            if(mem_mem_read)
                begin
                    case(mem_mem_size)

                        /*
                         * ------------------------------------------------
                         * BYTE LOAD
                         * ------------------------------------------------
                         */

                        2'b00:
                            begin
                                case(mem_result[1:0])

                                    2'b00:
                                        begin
                                            if(mem_mem_unsigned)
                                                mem_load_data =
                                                    {24'b0,dmem_rdata[7:0]};
                                            else
                                                mem_load_data =
                                                    {{24{dmem_rdata[7]}},
                                                     dmem_rdata[7:0]};
                                        end

                                    2'b01:
                                        begin
                                            if(mem_mem_unsigned)
                                                mem_load_data =
                                                    {24'b0,dmem_rdata[15:8]};
                                            else
                                                mem_load_data =
                                                    {{24{dmem_rdata[15]}},
                                                     dmem_rdata[15:8]};
                                        end

                                    2'b10:
                                        begin
                                            if(mem_mem_unsigned)
                                                mem_load_data =
                                                    {24'b0,dmem_rdata[23:16]};
                                            else
                                                mem_load_data =
                                                    {{24{dmem_rdata[23]}},
                                                     dmem_rdata[23:16]};
                                        end

                                    2'b11:
                                        begin
                                            if(mem_mem_unsigned)
                                                mem_load_data =
                                                    {24'b0,dmem_rdata[31:24]};
                                            else
                                                mem_load_data =
                                                    {{24{dmem_rdata[31]}},
                                                     dmem_rdata[31:24]};
                                        end

                                    default:
                                        begin
                                            mem_load_data = 32'b0;
                                        end

                                endcase
                            end


                        /*
                         * ------------------------------------------------
                         * HALFWORD LOAD
                         * ------------------------------------------------
                         */

                        2'b01:
                            begin
                                if(mem_result[1] == 1'b0)
                                    begin
                                        if(mem_mem_unsigned)
                                            mem_load_data =
                                                {16'b0,dmem_rdata[15:0]};
                                        else
                                            mem_load_data =
                                                {{16{dmem_rdata[15]}},
                                                 dmem_rdata[15:0]};
                                    end
                                else
                                    begin
                                        if(mem_mem_unsigned)
                                            mem_load_data =
                                                {16'b0,dmem_rdata[31:16]};
                                        else
                                            mem_load_data =
                                                {{16{dmem_rdata[31]}},
                                                 dmem_rdata[31:16]};
                                    end
                            end


                        /*
                         * ------------------------------------------------
                         * WORD LOAD
                         * ------------------------------------------------
                         */

                        2'b10:
                            begin
                                mem_load_data = dmem_rdata;
                            end


                        /*
                         * ------------------------------------------------
                         * INVALID SIZE
                         * ------------------------------------------------
                         */

                        default:
                            begin
                                mem_load_data = 32'b0;
                            end

                    endcase
                end
        end


    /*
     * ============================================================
     * M3.7 MEM -> WB DATA SELECTION
     *
     * LOAD:
     *     WB receives extracted dmem_rdata.
     *
     * NON-LOAD:
     *     WB receives normal EX result.
     * ============================================================
     */

    wire [31:0] mem_wb_input;

    assign mem_wb_input = mem_mem_read ?
                          mem_load_data :
                          mem_result;


    /*
     * ============================================================
     * EXTERNAL DATA MEMORY INTERFACE
     * ============================================================
     */

    assign dmem_valid = mem_valid &&
                        (mem_mem_read || mem_mem_write);

    assign dmem_write = mem_valid &&
                        mem_mem_write;

    assign dmem_addr = mem_result;

    assign dmem_wdata = mem_store_data;


    /*
     * Store byte enables.
     *
     * 00 = byte
     * 01 = halfword
     * 10 = word
     */

    reg [3:0] dmem_wstrb_reg;

    assign dmem_wstrb = dmem_wstrb_reg;

    always @(*)
        begin
            dmem_wstrb_reg = 4'b0000;

            if(mem_valid && mem_mem_write)
                begin
                    case(mem_mem_size)

                        2'b00:
                            dmem_wstrb_reg = 4'b0001;

                        2'b01:
                            dmem_wstrb_reg = 4'b0011;

                        2'b10:
                            dmem_wstrb_reg = 4'b1111;

                        default:
                            dmem_wstrb_reg = 4'b0000;

                    endcase
                end
        end


    /*
     * ============================================================
     * RETIREMENT INTERFACE
     * ============================================================
     */

    assign retire_valid = wb_valid;
    assign retire_pc = wb_pc;
    assign retire_instruction = wb_instruction;
    assign retire_reg_write = wb_reg_write;
    assign retire_rd = wb_rd;
    assign retire_data = wb_result;


    /*
     * ============================================================
     * INSTRUCTION FETCH
     * ============================================================
     */

    instruction_fetch_unit IFU(
        .clk(clk),
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
        .id_instruction(id_instruction)
    );


    /*
     * ============================================================
     * INSTRUCTION DECODE
     * ============================================================
     */

    instruction_decode_unit IDU(
        .clk(clk),
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

        .ex_reg_write(ex_reg_write),

        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_size(ex_mem_size),
        .ex_mem_unsigned(ex_mem_unsigned)
    );


    /*
     * ============================================================
     * EXECUTION
     * ============================================================
     */

    execution_unit EXU(
        .clk(clk),
        .rst(rst),

        .ex_valid(ex_valid),
        .ex_instruction(ex_instruction),
        .ex_pc(ex_pc),

        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),

        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm_val(ex_imm_val),

        .ex_alu_control(ex_alu_control),
        .ex_branch_type(ex_branch_type),
        .ex_jump_type(ex_jump_type),

        .ex_wb_pc4(ex_wb_pc4),
        .ex_reg_write(ex_reg_write),

        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_size(ex_mem_size),
        .ex_mem_unsigned(ex_mem_unsigned),

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
        .mem_result(mem_result),

        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_mem_size(mem_mem_size),
        .mem_mem_unsigned(mem_mem_unsigned),

        .mem_store_data(mem_store_data)
    );


    /*
     * ============================================================
     * MEM / WB
     *
     * IMPORTANT:
     *
     * mem_wb_input is used instead of mem_result so that LOAD
     * instructions write dmem_rdata into the register file,
     * while normal ALU instructions continue to write mem_result.
     * ============================================================
     */

    mem_wb_reg MEMWB(
        .clk(clk),
        .rst(rst),

        .mem_valid(mem_valid),
        .mem_instruction(mem_instruction),
        .mem_pc(mem_pc),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),

        .mem_result(mem_wb_input),
        .mem_load_data(mem_load_data),
        .mem_mem_read(mem_mem_read),

        .wb_valid(wb_valid),
        .wb_instruction(wb_instruction),
        .wb_pc(wb_pc),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_result(wb_result)
    );

endmodule