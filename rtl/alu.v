module alu_unit(ex_alu_control,result,rs1_data,rs2_data,imm_val);
    input [5:0] ex_alu_control;
    input [31:0] rs1_data,rs2_data;
    input [31:0] imm_val;
    output reg [31:0] result;

    wire arithmetic_sub;
    wire arithmetic_imm;
    wire [31:0] arithmetic_b;
    wire [31:0] arithmetic_result;

    /*
     * EXP2:
     * Unified arithmetic datapath for:
     *   ADD  : rs1 + rs2
     *   SUB  : rs1 - rs2
     *   ADDI : rs1 + imm
     */

    assign arithmetic_sub =
        (ex_alu_control == 6'd2);

    assign arithmetic_imm =
        (ex_alu_control == 6'd11);

    assign arithmetic_b =
        arithmetic_imm ? imm_val : rs2_data;

    /*
     * Unified two's-complement arithmetic:
     *
     * ADD : A + B
     * SUB : A + ~B + 1
     */
        arithmetic_adder arithmetic_add(
        .a(rs1_data),
        .b(arithmetic_b),
        .sub(arithmetic_sub),
        .result(arithmetic_result));

    always@(*)
        begin
            case(ex_alu_control)

                // R-Type Instructions
                6'd1: result = arithmetic_result;
                6'd2: result = arithmetic_result;
                6'd3: result = rs1_data << rs2_data[4:0];
                6'd4: result = ($signed(rs1_data) < $signed(rs2_data)) ? 32'd1 : 32'd0;
                6'd5: result = (rs1_data < rs2_data) ? 32'd1 : 32'd0;
                6'd6: result = rs1_data ^ rs2_data;
                6'd7: result = rs1_data >> rs2_data[4:0];
                6'd8: result = $signed(rs1_data) >>> rs2_data[4:0];
                6'd9: result = rs1_data | rs2_data;
                6'd10: result = rs1_data & rs2_data;

                // I-Type Instructions
                6'd11: result = arithmetic_result;
                6'd12: result = rs1_data << imm_val[4:0];
                6'd13: result = ($signed(rs1_data) < $signed(imm_val)) ? 32'd1 : 32'd0;
                6'd14: result = (rs1_data < imm_val) ? 32'd1 : 32'd0;
                6'd15: result = rs1_data ^ imm_val;
                6'd16: result = rs1_data >> imm_val[4:0];
                6'd17: result = $signed(rs1_data) >>> imm_val[4:0];
                6'd18: result = rs1_data | imm_val;
                6'd19: result = rs1_data & imm_val;

                default: result = 32'b0;

            endcase
        end
endmodule
