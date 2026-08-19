module if_id_reg(clk,rst,flush,if_valid,if_instruction,if_pc,id_valid,id_instruction,id_pc);
    input clk,rst,flush;
    input if_valid;
    input [31:0] if_instruction,if_pc;
    output reg id_valid;
    output reg [31:0] id_instruction,id_pc;

    always@(posedge clk)
        begin
            if(rst || flush)
                begin
                    id_valid<=1'b0;
                    id_instruction<=32'h00000013;
                    id_pc<=32'b0;
                end
            else
                begin
                    id_valid<=if_valid;
                    id_instruction<=if_instruction;
                    id_pc<=if_pc;
                end
        end
endmodule
