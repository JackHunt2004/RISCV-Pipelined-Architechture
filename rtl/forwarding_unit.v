module forwarding_unit(ex_rs1,ex_rs2,mem_rd,mem_reg_write,wb_rd,wb_reg_write,forward_a,forward_b);
    input [4:0] ex_rs1,ex_rs2;
    input [4:0] mem_rd,wb_rd;
    input mem_reg_write,wb_reg_write;
    output reg [1:0] forward_a,forward_b;

    always@(*)
        begin
            forward_a=2'b00;
            forward_b=2'b00;

            if(mem_reg_write && mem_rd!=5'd0 && mem_rd==ex_rs1)
                begin
                    forward_a=2'b10;
                end
            else if(wb_reg_write && wb_rd!=5'd0 && wb_rd==ex_rs1)
                begin
                    forward_a=2'b01;
                end

            if(mem_reg_write && mem_rd!=5'd0 && mem_rd==ex_rs2)
                begin
                    forward_b=2'b10;
                end
            else if(wb_reg_write && wb_rd!=5'd0 && wb_rd==ex_rs2)
                begin
                    forward_b=2'b01;
                end
        end
endmodule
