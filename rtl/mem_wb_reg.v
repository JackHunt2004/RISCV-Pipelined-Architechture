module mem_wb_reg(clk,rst,mem_rd,mem_reg_write,mem_result,wb_rd,wb_reg_write,wb_result);
    input clk,rst;
    input mem_reg_write;
    input [31:0] mem_result;
    input [4:0] mem_rd;

    output reg wb_reg_write;
    output reg [31:0] wb_result;
    output reg [4:0] wb_rd;

    always@(posedge clk)
        begin
            if(rst)
                begin
                    wb_rd<=0;
                    wb_reg_write<=0;
                    wb_result<=0;
                end
            else
                begin
                    wb_rd<=mem_rd;
                    wb_reg_write<=mem_reg_write;
                    wb_result<=mem_result;
                end
        end
endmodule