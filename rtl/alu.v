module alu_unit(ex_alu_control,result,rs1_data,rs2_data,imm_val);
    input [5:0] ex_alu_control;
    input [31:0] rs1_data,rs2_data;
    input [31:0] imm_val;
    output reg [31:0] result;
    
    always@(*)
        begin
            case(ex_alu_control)

            // R-TYPE INSTRUCTIONS 
                6'd1:result = rs1_data + rs2_data; // ADD
                6'd2:result = rs1_data - rs2_data; // SUB
                6'd3:result = rs1_data << rs2_data[2:0]; // SLL
                6'd4:result = ($signed(rs1_data) < $signed(rs2_data)) ? 32'd1 : 32'd0; // SLT
                6'd5:result = (rs1_data < rs2_data) ? 32'd1 : 32'd0; // SLTU
                6'd6:result = rs1_data ^ rs2_data; // XOR
                6'd7:result = rs1_data >> rs2_data[2:0]; // SRL
                6'd8:result = $signed(rs1_data) >>> rs2_data[2:0]; // SRA
                6'd9:result = rs1_data | rs2_data; // OR
                6'd10:result =rs1_data & rs2_data; // AND

            // I-TYPE INSTRUCTIONS
                6'd11:result = rs1_data + imm_val; // ADD
                6'd12:result = rs1_data << imm_val[4:0]; // SLLI
                6'd13:result = ($signed(rs1_data) < $signed(imm_val)) ? 32'd1 : 32'd0; // SLTI
                6'd14:result = (rs1_data < imm_val) ? 32'd1 : 32'd0; // SLTIU
                6'd15:result = rs1_data ^ imm_val; // XORI
                6'd16:result = rs1_data >> imm_val[4:0]; // SRLI
                6'd17:result = $signed(rs1_data) >>> imm_val[4:0]; // SRAI
                6'd18:result = rs1_data | imm_val; // ORI
                6'd19:result = rs1_data & imm_val; // ANDI

                default:result = 32'b0;
            endcase
        end
endmodule
