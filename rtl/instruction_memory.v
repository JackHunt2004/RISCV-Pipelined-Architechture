module instruction_memory(if_instruction,if_pc);
    input [31:0] if_pc;
    output [31:0] if_instruction;

    reg [7:0] inst_mem [159:0];

    assign if_instruction = {inst_mem[if_pc+3] , inst_mem[if_pc+2] , inst_mem[if_pc+1] , inst_mem[if_pc]};

    initial
        begin
                    // ================= R-TYPE INSTRUCTIONS =================

                    // ADD  - 0x007302B3
                    inst_mem[0]  = 8'hB3;
                    inst_mem[1]  = 8'h02;
                    inst_mem[2]  = 8'h73;
                    inst_mem[3]  = 8'h00;

                    // SUB  - 0x407302B3
                    inst_mem[4]  = 8'hB3;
                    inst_mem[5]  = 8'h02;
                    inst_mem[6]  = 8'h73;
                    inst_mem[7]  = 8'h40;

                    // AND  - 0x007372B3
                    inst_mem[8]  = 8'hB3;
                    inst_mem[9]  = 8'h72;
                    inst_mem[10] = 8'h73;
                    inst_mem[11] = 8'h00;

                    // OR   - 0x007362B3
                    inst_mem[12] = 8'hB3;
                    inst_mem[13] = 8'h62;
                    inst_mem[14] = 8'h73;
                    inst_mem[15] = 8'h00;

                    // XOR  - 0x007342B3
                    inst_mem[16] = 8'hB3;
                    inst_mem[17] = 8'h42;
                    inst_mem[18] = 8'h73;
                    inst_mem[19] = 8'h00;

                    // SLL  - 0x007312B3
                    inst_mem[20] = 8'hB3;
                    inst_mem[21] = 8'h12;
                    inst_mem[22] = 8'h73;
                    inst_mem[23] = 8'h00;

                    // SRL  - 0x007352B3
                    inst_mem[24] = 8'hB3;
                    inst_mem[25] = 8'h52;
                    inst_mem[26] = 8'h73;
                    inst_mem[27] = 8'h00;

                    // SRA  - 0x407352B3
                    inst_mem[28] = 8'hB3;
                    inst_mem[29] = 8'h52;
                    inst_mem[30] = 8'h73;
                    inst_mem[31] = 8'h40;

                    // SLT  - 0x007322B3
                    inst_mem[32] = 8'hB3;
                    inst_mem[33] = 8'h22;
                    inst_mem[34] = 8'h73;
                    inst_mem[35] = 8'h00;

                    // SLTU - 0x007332B3
                    inst_mem[36] = 8'hB3;
                    inst_mem[37] = 8'h32;
                    inst_mem[38] = 8'h73;
                    inst_mem[39] = 8'h00;

                    // ================= I-TYPE (opcode = 0010011) =================

                    // ADDI  - 0x00430293
                    inst_mem[40] = 8'h93;
                    inst_mem[41] = 8'h02;
                    inst_mem[42] = 8'h43;
                    inst_mem[43] = 8'h00;

                    // SLLI  - 0x00431293
                    inst_mem[44] = 8'h93;
                    inst_mem[45] = 8'h12;
                    inst_mem[46] = 8'h43;
                    inst_mem[47] = 8'h00;

                    // SLTI  - 0x00432293
                    inst_mem[48] = 8'h93;
                    inst_mem[49] = 8'h22;
                    inst_mem[50] = 8'h43;
                    inst_mem[51] = 8'h00;

                    // SLTIU - 0x00433293
                    inst_mem[52] = 8'h93;
                    inst_mem[53] = 8'h32;
                    inst_mem[54] = 8'h43;
                    inst_mem[55] = 8'h00;

                    // XORI  - 0x00434293
                    inst_mem[56] = 8'h93;
                    inst_mem[57] = 8'h42;
                    inst_mem[58] = 8'h43;
                    inst_mem[59] = 8'h00;

                    // SRLI  - 0x00435293
                    inst_mem[60] = 8'h93;
                    inst_mem[61] = 8'h52;
                    inst_mem[62] = 8'h43;
                    inst_mem[63] = 8'h00;

                    // SRAI  - 0x40435293
                    inst_mem[64] = 8'h93;
                    inst_mem[65] = 8'h52;
                    inst_mem[66] = 8'h43;
                    inst_mem[67] = 8'h40;

                    // ORI   - 0x00436293
                    inst_mem[68] = 8'h93;
                    inst_mem[69] = 8'h62;
                    inst_mem[70] = 8'h43;
                    inst_mem[71] = 8'h00;

                    // ANDI  - 0x00437293
                    inst_mem[72] = 8'h93;
                    inst_mem[73] = 8'h72;
                    inst_mem[74] = 8'h43;
                    inst_mem[75] = 8'h00;

                    // ================= B-TYPE INSTRUCTIONS =================

                    // BEQ  - 0x00730463
                    inst_mem[76] = 8'h63;
                    inst_mem[77] = 8'h04;
                    inst_mem[78] = 8'h73;
                    inst_mem[79] = 8'h00;

                    // BNEQ - 0x00731463 
                    inst_mem[80] = 8'h63;
                    inst_mem[81] = 8'h14;
                    inst_mem[82] = 8'h73;
                    inst_mem[83] = 8'h00;

                    // BGE  - 0x00735463
                    inst_mem[84] = 8'h63;
                    inst_mem[85] = 8'h54;
                    inst_mem[86] = 8'h73;
                    inst_mem[87] = 8'h00;

                    // BLT  - 0x00734463
                    inst_mem[88] = 8'h63;
                    inst_mem[89] = 8'h44;
                    inst_mem[90] = 8'h73;
                    inst_mem[91] = 8'h00;
            
            // ================= J-TYPE INSTRUCTIONS =================

                    // JAL  - 0x010002EF
                    inst_mem[92] = 8'hEF;
                    inst_mem[93] = 8'h02;
                    inst_mem[94] = 8'h00;
                    inst_mem[95] = 8'h01;

                    // JALR - 0x000302E7
                    inst_mem[96] = 8'hE7;
                    inst_mem[97] = 8'h02;
                    inst_mem[98] = 8'h03;
                    inst_mem[99] = 8'h00;

                end
endmodule