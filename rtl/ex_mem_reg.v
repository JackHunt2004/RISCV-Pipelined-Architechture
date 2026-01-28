module ex_mem_reg(clk,rst,ex_result,ex_rd,ex_reg_write,mem_result,mem_rd,mem_reg_write);
    input [31:0] ex_result;
    input clk,rst;
    input [4:0] ex_rd;
    input ex_reg_write;

    output reg [31:0] mem_result;
    output reg [4:0] mem_rd;
    output reg mem_reg_write;

    always@(posedge clk)
        if(rst)
            begin
                mem_result<=32'b0;
                mem_rd<=5'b0;
                mem_reg_write<=1'b0;
            end
        else
            begin
                mem_result<=ex_result;
                mem_rd<=ex_rd;
                mem_reg_write<=ex_reg_write;
            end
endmodule