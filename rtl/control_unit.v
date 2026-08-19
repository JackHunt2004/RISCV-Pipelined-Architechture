module control_unit(op_code,func7,func3,alu_control,branch_type,jump_type,reg_write,wb_pc4);
    input [6:0] op_code;
    input [6:0] func7;
    input [2:0] func3;
    output reg [5:0] alu_control;
    output reg [2:0] branch_type;
    output reg [1:0] jump_type;
    output reg reg_write,wb_pc4;

    always@(*)
        begin
            alu_control=6'd0;
            branch_type=3'd0;
            jump_type=2'd0;
            reg_write=1'b0;
            wb_pc4=1'b0;

            case(op_code)
                7'b0110011:begin // R-Type Instructions
                                case({func7,func3})
                                    {7'b0000000,3'b000}:begin
                                                                    alu_control=6'd1;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0100000,3'b000}:begin
                                                                    alu_control=6'd2;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b001}:begin
                                                                    alu_control=6'd3;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b010}:begin
                                                                    alu_control=6'd4;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b011}:begin
                                                                    alu_control=6'd5;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b100}:begin
                                                                    alu_control=6'd6;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b101}:begin
                                                                    alu_control=6'd7;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0100000,3'b101}:begin
                                                                    alu_control=6'd8;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b110}:begin
                                                                    alu_control=6'd9;
                                                                    reg_write=1'b1;
                                                                end
                                    {7'b0000000,3'b111}:begin
                                                                    alu_control=6'd10;
                                                                    reg_write=1'b1;
                                                                end
                                    default:begin
                                                alu_control=6'd0;
                                                reg_write=1'b0;
                                            end
                                endcase
                            end

                7'b0010011:begin // I-Type Instructions
                                case(func3)
                                    3'b000:begin
                                                alu_control=6'd11;
                                                reg_write=1'b1;
                                            end
                                    3'b001:begin
                                                if(func7==7'b0000000)
                                                    begin
                                                        alu_control=6'd12;
                                                        reg_write=1'b1;
                                                    end
                                            end
                                    3'b010:begin
                                                alu_control=6'd13;
                                                reg_write=1'b1;
                                            end
                                    3'b011:begin
                                                alu_control=6'd14;
                                                reg_write=1'b1;
                                            end
                                    3'b100:begin
                                                alu_control=6'd15;
                                                reg_write=1'b1;
                                            end
                                    3'b101:begin
                                                if(func7==7'b0000000)
                                                    begin
                                                        alu_control=6'd16;
                                                        reg_write=1'b1;
                                                    end
                                                else if(func7==7'b0100000)
                                                    begin
                                                        alu_control=6'd17;
                                                        reg_write=1'b1;
                                                    end
                                            end
                                    3'b110:begin
                                                alu_control=6'd18;
                                                reg_write=1'b1;
                                            end
                                    3'b111:begin
                                                alu_control=6'd19;
                                                reg_write=1'b1;
                                            end
                                    default:begin
                                                alu_control=6'd0;
                                                reg_write=1'b0;
                                            end
                                endcase
                            end

                7'b1100011:begin // B-Type Instructions
                                case(func3)
                                    3'b000:branch_type=3'd1;
                                    3'b001:branch_type=3'd2;
                                    3'b100:branch_type=3'd3;
                                    3'b101:branch_type=3'd4;
                                    3'b110:branch_type=3'd5;
                                    3'b111:branch_type=3'd6;
                                    default:branch_type=3'd0;
                                endcase
                            end

                7'b1101111:begin // JAL
                                jump_type=2'd1;
                                reg_write=1'b1;
                                wb_pc4=1'b1;
                            end

                7'b1100111:begin // JALR
                                if(func3==3'b000)
                                    begin
                                        jump_type=2'd2;
                                        reg_write=1'b1;
                                        wb_pc4=1'b1;
                                    end
                            end

                default:begin
                            alu_control=6'd0;
                            branch_type=3'd0;
                            jump_type=2'd0;
                            reg_write=1'b0;
                            wb_pc4=1'b0;
                        end
            endcase
        end
endmodule
