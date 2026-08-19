module mem_wb_reg(clk,rst,mem_valid,mem_instruction,mem_pc,mem_rd,mem_reg_write,mem_result,wb_valid,wb_instruction,wb_pc,wb_rd,wb_reg_write,wb_result);
    input clk,rst;
    input mem_valid,mem_reg_write;
    input [31:0] mem_instruction,mem_pc,mem_result;
    input [4:0] mem_rd;
    output reg wb_valid,wb_reg_write;
    output reg [31:0] wb_instruction,wb_pc,wb_result;
    output reg [4:0] wb_rd;

    always@(posedge clk)
        begin
            if(rst)
                begin
                    wb_valid<=1'b0;
                    wb_instruction<=32'h00000013;
                    wb_pc<=32'b0;
                    wb_rd<=5'b0;
                    wb_reg_write<=1'b0;
                    wb_result<=32'b0;
                end
            else
                begin
                    wb_valid<=mem_valid;
                    wb_instruction<=mem_instruction;
                    wb_pc<=mem_pc;
                    wb_rd<=mem_rd;
                    wb_reg_write<=mem_reg_write && mem_valid;
                    wb_result<=mem_result;
                end
        end
endmodule
