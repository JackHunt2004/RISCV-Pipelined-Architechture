module \$dff (CLK, D, Q);
    parameter WIDTH = 1;
    parameter CLK_POLARITY = 1;

    input CLK;
    input [WIDTH-1:0] D;
    output [WIDTH-1:0] Q;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_dff
            sky130_fd_sc_hd__dfxtp_1 _TECHMAP_REPLACE_ (
                .CLK(CLK),
                .D(D[i]),
                .Q(Q[i])
            );
        end
    endgenerate
endmodule
