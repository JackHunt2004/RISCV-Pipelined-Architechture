module instruction_memory(if_instruction,if_pc);
    input [31:0] if_pc;
    output [31:0] if_instruction;

    reg [31:0] inst_mem [63:0];
    wire [29:0] word_address;
    integer i;

    assign word_address=if_pc[31:2];
    assign if_instruction=(word_address<64) ? inst_mem[word_address] : 32'h00000013;

    initial
        begin
            for(i=0;i<64;i=i+1)
                begin
                    inst_mem[i]=32'h00000013;
                end

            // R-Type Instructions
            inst_mem[0]=32'h007302b3;
            inst_mem[1]=32'h407302b3;
            inst_mem[2]=32'h007372b3;
            inst_mem[3]=32'h007362b3;
            inst_mem[4]=32'h007342b3;
            inst_mem[5]=32'h007312b3;
            inst_mem[6]=32'h007352b3;
            inst_mem[7]=32'h407352b3;
            inst_mem[8]=32'h007322b3;
            inst_mem[9]=32'h007332b3;

            // I-Type Instructions
            inst_mem[10]=32'h00430293;
            inst_mem[11]=32'h00431293;
            inst_mem[12]=32'h00432293;
            inst_mem[13]=32'h00433293;
            inst_mem[14]=32'h00434293;
            inst_mem[15]=32'h00435293;
            inst_mem[16]=32'h40435293;
            inst_mem[17]=32'h00436293;
            inst_mem[18]=32'h00437293;

            // Branch and Jump Instructions
            inst_mem[19]=32'h00730463;
            inst_mem[20]=32'h00731463;
            inst_mem[21]=32'h00735463;
            inst_mem[22]=32'h00734463;
            inst_mem[23]=32'h010002ef;
            inst_mem[24]=32'h000302e7;
        end
endmodule
