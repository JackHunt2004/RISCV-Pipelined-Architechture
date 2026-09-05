module arithmetic_adder8(a, b, cin, sum, cout);
    input [7:0] a;
    input [7:0] b;
    input cin;
    output [7:0] sum;
    output cout;

    assign {cout, sum} = a + b + cin;

endmodule


module arithmetic_adder(a, b, sub, result);
    input [31:0] a;
    input [31:0] b;
    input sub;
    output [31:0] result;

    wire [31:0] b_eff;

    wire [7:0] sum0;
    wire [7:0] sum1_0, sum1_1;
    wire [7:0] sum2_0, sum2_1;
    wire [7:0] sum3_0, sum3_1;

    wire c8;
    wire c16_0, c16_1;
    wire c24_0, c24_1;
    wire c32_0, c32_1;

    wire c16;
    wire c24;

    /*
     * ADD:
     *     A + B
     *
     * SUB:
     *     A + ~B + 1
     */
    assign b_eff = sub ? ~b : b;

    /*
     * Lowest 8 bits use the real input carry.
     */
    arithmetic_adder8 add0(
        .a(a[7:0]),
        .b(b_eff[7:0]),
        .cin(sub),
        .sum(sum0),
        .cout(c8)
    );

    /*
     * Upper blocks calculate both possible carry cases
     * in parallel.
     */
    arithmetic_adder8 add1_c0(
        .a(a[15:8]),
        .b(b_eff[15:8]),
        .cin(1'b0),
        .sum(sum1_0),
        .cout(c16_0)
    );

    arithmetic_adder8 add1_c1(
        .a(a[15:8]),
        .b(b_eff[15:8]),
        .cin(1'b1),
        .sum(sum1_1),
        .cout(c16_1)
    );

    arithmetic_adder8 add2_c0(
        .a(a[23:16]),
        .b(b_eff[23:16]),
        .cin(1'b0),
        .sum(sum2_0),
        .cout(c24_0)
    );

    arithmetic_adder8 add2_c1(
        .a(a[23:16]),
        .b(b_eff[23:16]),
        .cin(1'b1),
        .sum(sum2_1),
        .cout(c24_1)
    );

    arithmetic_adder8 add3_c0(
        .a(a[31:24]),
        .b(b_eff[31:24]),
        .cin(1'b0),
        .sum(sum3_0),
        .cout(c32_0)
    );

    arithmetic_adder8 add3_c1(
        .a(a[31:24]),
        .b(b_eff[31:24]),
        .cin(1'b1),
        .sum(sum3_1),
        .cout(c32_1)
    );

    /*
     * Carry-select muxing.
     */
    assign result[7:0] = sum0;

    assign result[15:8] =
        c8 ? sum1_1 : sum1_0;

    assign c16 =
        c8 ? c16_1 : c16_0;

    assign result[23:16] =
        c16 ? sum2_1 : sum2_0;

    assign c24 =
        c16 ? c24_1 : c24_0;

    assign result[31:24] =
        c24 ? sum3_1 : sum3_0;

endmodule
