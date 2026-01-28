module if_id_reg(clk,rst,if_instruction,id_instruction,if_pc,id_pc);
    input clk,rst;
    input [31:0] if_pc;
    input [31:0] if_instruction;
    output reg [31:0] id_instruction;
    output reg [31:0] id_pc;

    always@(posedge clk)
        if(rst)
            begin
                id_instruction<=32'b0;
                id_pc<=32'b0;
            end
        else
            begin
                id_instruction<=if_instruction;
                id_pc<=if_pc;
            end
endmodule