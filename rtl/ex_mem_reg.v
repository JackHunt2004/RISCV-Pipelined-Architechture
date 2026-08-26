module ex_mem_reg(clk,rst,ex_valid,ex_instruction,ex_pc,ex_result,ex_rd,ex_reg_write,ex_mem_read,ex_mem_write,ex_mem_size,ex_mem_unsigned,ex_store_data,mem_valid,mem_instruction,mem_pc,mem_result,mem_rd,mem_reg_write,mem_mem_read,mem_mem_write,mem_mem_size,mem_mem_unsigned,mem_store_data);
    input clk,rst;
    input ex_valid,ex_reg_write;
    input ex_mem_read,ex_mem_write,ex_mem_unsigned;
    input [31:0] ex_instruction,ex_pc,ex_result,ex_store_data;
    input [1:0] ex_mem_size;
    input [4:0] ex_rd;

    output reg mem_valid,mem_reg_write;
    output reg mem_mem_read,mem_mem_write,mem_mem_unsigned;
    output reg [31:0] mem_instruction,mem_pc,mem_result,mem_store_data;
    output reg [1:0] mem_mem_size;
    output reg [4:0] mem_rd;

    always@(posedge clk)
        begin
            if(rst)
                begin
                    mem_valid<=1'b0;
                    mem_instruction<=32'h00000013;
                    mem_pc<=32'b0;
                    mem_result<=32'b0;
                    mem_rd<=5'b0;
                    mem_reg_write<=1'b0;
                    mem_mem_read<=1'b0;
                    mem_mem_write<=1'b0;
                    mem_mem_size<=2'b00;
                    mem_mem_unsigned<=1'b0;
                    mem_store_data<=32'b0;
                end
            else
                begin
                    mem_valid<=ex_valid;
                    mem_instruction<=ex_instruction;
                    mem_pc<=ex_pc;
                    mem_result<=ex_result;
                    mem_rd<=ex_rd;
                    mem_reg_write<=ex_reg_write && ex_valid;
                    mem_mem_read<=ex_mem_read && ex_valid;
                    mem_mem_write<=ex_mem_write && ex_valid;
                    mem_mem_size<=ex_mem_size;
                    mem_mem_unsigned<=ex_mem_unsigned;
                    mem_store_data<=ex_store_data;
                end
        end
endmodule