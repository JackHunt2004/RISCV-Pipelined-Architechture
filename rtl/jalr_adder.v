module jalr_full_adder(a,b,cin,sum,cout);

    input  a,b,cin;
    output sum,cout;

    wire p,g;

    assign p    = a ^ b;
    assign sum  = p ^ cin;
    assign g    = a & b;
    assign cout = g | (p & cin);

endmodule


module jalr_adder8(a,b,cin,sum,cout);

    input  [7:0] a,b;
    input        cin;
    output [7:0] sum;
    output       cout;

    wire [8:0] c;

    assign c[0] = cin;

    jalr_full_adder fa0(a[0],b[0],c[0],sum[0],c[1]);
    jalr_full_adder fa1(a[1],b[1],c[1],sum[1],c[2]);
    jalr_full_adder fa2(a[2],b[2],c[2],sum[2],c[3]);
    jalr_full_adder fa3(a[3],b[3],c[3],sum[3],c[4]);
    jalr_full_adder fa4(a[4],b[4],c[4],sum[4],c[5]);
    jalr_full_adder fa5(a[5],b[5],c[5],sum[5],c[6]);
    jalr_full_adder fa6(a[6],b[6],c[6],sum[6],c[7]);
    jalr_full_adder fa7(a[7],b[7],c[7],sum[7],c[8]);

    assign cout = c[8];

endmodule


module jalr_adder(a,b,result);

    input  [31:0] a,b;
    output [31:0] result;

    wire [7:0] sum0;
    wire [7:0] sum1_0;
    wire [7:0] sum1_1;
    wire [7:0] sum2_0;
    wire [7:0] sum2_1;
    wire [7:0] sum3_0;
    wire [7:0] sum3_1;

    wire c8;
    wire c16_0,c16_1;
    wire c24_0,c24_1;
    wire c32_0,c32_1;

    /*
     * Block 0:
     * Actual carry-in is zero.
     */
    jalr_adder8 add0(
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(1'b0),
        .sum(sum0),
        .cout(c8)
    );

    /*
     * Block 1:
     * Calculate both possible carry-in cases in parallel.
     */
    jalr_adder8 add1_c0(
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(1'b0),
        .sum(sum1_0),
        .cout(c16_0)
    );

    jalr_adder8 add1_c1(
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(1'b1),
        .sum(sum1_1),
        .cout(c16_1)
    );

    /*
     * Block 2:
     * Both carry possibilities are calculated in parallel.
     */
    jalr_adder8 add2_c0(
        .a(a[23:16]),
        .b(b[23:16]),
        .cin(1'b0),
        .sum(sum2_0),
        .cout(c24_0)
    );

    jalr_adder8 add2_c1(
        .a(a[23:16]),
        .b(b[23:16]),
        .cin(1'b1),
        .sum(sum2_1),
        .cout(c24_1)
    );

    /*
     * Block 3:
     * Both carry possibilities are calculated in parallel.
     */
    jalr_adder8 add3_c0(
        .a(a[31:24]),
        .b(b[31:24]),
        .cin(1'b0),
        .sum(sum3_0),
        .cout(c32_0)
    );

    jalr_adder8 add3_c1(
        .a(a[31:24]),
        .b(b[31:24]),
        .cin(1'b1),
        .sum(sum3_1),
        .cout(c32_1)
    );

    /*
     * Carry-select between blocks.
     */
    assign result[7:0] =
        sum0;

    assign result[15:8] =
        c8 ? sum1_1 : sum1_0;

    assign result[23:16] =
        c16_1 ? sum2_1 : sum2_0;

    assign result[31:24] =
        c24_1 ? sum3_1 : sum3_0;

    /*
     * JALR target must have bit 0 cleared.
     */
    assign result[0] = 1'b0;

endmodule
