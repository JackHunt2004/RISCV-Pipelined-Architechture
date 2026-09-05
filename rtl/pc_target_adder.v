module pc_target_adder4(a,b,cin,sum,cout);
    input  [3:0] a,b;
    input        cin;
    output [3:0] sum;
    output       cout;

    wire [4:0] c;

    assign c[0] = cin;

    assign sum[0] = a[0] ^ b[0] ^ c[0];
    assign c[1]   = (a[0] & b[0]) | ((a[0] ^ b[0]) & c[0]);

    assign sum[1] = a[1] ^ b[1] ^ c[1];
    assign c[2]   = (a[1] & b[1]) | ((a[1] ^ b[1]) & c[1]);

    assign sum[2] = a[2] ^ b[2] ^ c[2];
    assign c[3]   = (a[2] & b[2]) | ((a[2] ^ b[2]) & c[2]);

    assign sum[3] = a[3] ^ b[3] ^ c[3];
    assign c[4]   = (a[3] & b[3]) | ((a[3] ^ b[3]) & c[3]);

    assign cout = c[4];
endmodule


module pc_target_adder(a,b,result);
    input  [31:0] a,b;
    output [31:0] result;

    wire [3:0] sum0;

    wire [3:0] sum1_0, sum1_1;
    wire [3:0] sum2_0, sum2_1;
    wire [3:0] sum3_0, sum3_1;
    wire [3:0] sum4_0, sum4_1;
    wire [3:0] sum5_0, sum5_1;
    wire [3:0] sum6_0, sum6_1;
    wire [3:0] sum7_0, sum7_1;

    wire c4;
    wire c8_0,  c8_1;
    wire c12_0, c12_1;
    wire c16_0, c16_1;
    wire c20_0, c20_1;
    wire c24_0, c24_1;
    wire c28_0, c28_1;
    wire c32_0, c32_1;

    pc_target_adder4 add0(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .sum(sum0),
        .cout(c4)
    );

    pc_target_adder4 add1_c0(a[7:4],   b[7:4],   1'b0, sum1_0, c8_0);
    pc_target_adder4 add1_c1(a[7:4],   b[7:4],   1'b1, sum1_1, c8_1);

    pc_target_adder4 add2_c0(a[11:8],  b[11:8],  1'b0, sum2_0, c12_0);
    pc_target_adder4 add2_c1(a[11:8],  b[11:8],  1'b1, sum2_1, c12_1);

    pc_target_adder4 add3_c0(a[15:12], b[15:12], 1'b0, sum3_0, c16_0);
    pc_target_adder4 add3_c1(a[15:12], b[15:12], 1'b1, sum3_1, c16_1);

    pc_target_adder4 add4_c0(a[19:16], b[19:16], 1'b0, sum4_0, c20_0);
    pc_target_adder4 add4_c1(a[19:16], b[19:16], 1'b1, sum4_1, c20_1);

    pc_target_adder4 add5_c0(a[23:20], b[23:20], 1'b0, sum5_0, c24_0);
    pc_target_adder4 add5_c1(a[23:20], b[23:20], 1'b1, sum5_1, c24_1);

    pc_target_adder4 add6_c0(a[27:24], b[27:24], 1'b0, sum6_0, c28_0);
    pc_target_adder4 add6_c1(a[27:24], b[27:24], 1'b1, sum6_1, c28_1);

    pc_target_adder4 add7_c0(a[31:28], b[31:28], 1'b0, sum7_0, c32_0);
    pc_target_adder4 add7_c1(a[31:28], b[31:28], 1'b1, sum7_1, c32_1);

    assign result[3:0]   = sum0;
    assign result[7:4]   = c4  ? sum1_1 : sum1_0;
    assign result[11:8]  = c8_1  ? sum2_1 : sum2_0;
    assign result[15:12] = c12_1 ? sum3_1 : sum3_0;
    assign result[19:16] = c16_1 ? sum4_1 : sum4_0;
    assign result[23:20] = c20_1 ? sum5_1 : sum5_0;
    assign result[27:24] = c24_1 ? sum6_1 : sum6_0;
    assign result[31:28] = c28_1 ? sum7_1 : sum7_0;
endmodule
