module register_file(clk,rst,rs1,rs2,rd,result,reg_write,rs1_data,rs2_data);
    input clk,rst;
    input [4:0] rs1,rs2,rd;
    input [31:0] result;
    input reg_write;
    output [31:0] rs1_data,rs2_data;

    reg [31:0] registers [31:0];
    integer i;

    always@(posedge clk)
        begin
            if(rst)
                begin
                    for(i=0;i<32;i=i+1)
                        begin
                            registers[i]<=32'b0;
                        end
                end
            else if(reg_write && rd!=5'd0)
                begin
                    registers[rd]<=result;
                end
        end

    assign rs1_data=(rs1==5'd0) ? 32'b0 :
                    ((reg_write && rd!=5'd0 && rd==rs1) ? result : registers[rs1]);
    assign rs2_data=(rs2==5'd0) ? 32'b0 :
                    ((reg_write && rd!=5'd0 && rd==rs2) ? result : registers[rs2]);
endmodule
