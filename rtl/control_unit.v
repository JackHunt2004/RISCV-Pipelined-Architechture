module control_unit(op_code,func7,func3,alu_control,beq_control,bneq_control,bgt_control,blt_control,jump);
    input [6:0] op_code;
    input [2:0] func3;
    input [6:0] func7;
    output reg beq_control,bneq_control,bgt_control,blt_control,jump;

    output reg [5:0] alu_control;

    always@(*)
        begin
            alu_control=6'b0;
            beq_control=1'b0;
            bneq_control=1'b0;
            bgt_control=1'b0;
            blt_control=1'b0;
            jump=1'b0;
            case(op_code) 
            7'b0110011:begin // R-Type Instruction
                        case(func3)
                            3'b000: alu_control = (func7 == 7'b0000000) ? 6'd1 : 6'd2; // ADD or SUB
                            3'b001: alu_control = 6'd3; // SLL
                            3'b010: alu_control = 6'd4; // SLT
                            3'b011: alu_control = 6'd5; // SLTU
                            3'b100: alu_control = 6'd6; // XOR
                            3'b101: alu_control = (func7 == 7'b0000000) ? 6'd7 : 6'd8; // SRL or SRA
                            3'b110: alu_control = 6'd9; // OR
                            3'b111: alu_control = 6'd10; // AND
                        endcase
                        end
            
            7'b0010011:begin // I-Type Instruction
                        case(func3)
                            3'b000: alu_control = 6'd11;
                            3'b001: alu_control = 6'd12;
                            3'b010: alu_control = 6'd13;
                            3'b011: alu_control = 6'd14;
                            3'b100: alu_control = 6'd15;
                            3'b101: alu_control = 6'd16;
                            3'b110: alu_control = (func7 == 7'b0000000) ? 6'd17 : 6'd18;
                            3'b111: alu_control = 6'd19;
                        endcase
                        end

            7'b1100011:begin // B-Type Instruction
                        case(func3)
                            3'b000: begin
                                        alu_control = 6'd20;
                                        beq_control = 1'b1;
                                    end
                            3'b001: begin
                                        alu_control = 6'd21;
                                        bneq_control = 1'b1;
                                    end
                            3'b101: begin
                                        alu_control = 6'd22;
                                        bgt_control = 1'b1;
                                    end
                            3'b100: begin
                                        alu_control = 6'd23;
                                        blt_control = 1'b1;
                                    end
                        endcase
                        end
            7'b1101111:begin // JAL
                            alu_control=6'd24;
                            jump=1'd1;
                        end    

            7'b1100111:begin // JALR
                            alu_control=6'd25;
                            jump=1'd1;
                        end
            default:begin
                        beq_control=0;
                        bneq_control=0;
                        bgt_control=0;
                        blt_control=0;
                        alu_control=6'd0;
                        jump=0;
                    end
            endcase
        end
endmodule
