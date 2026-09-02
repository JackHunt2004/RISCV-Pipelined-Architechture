module \$mux (A, B, S, Y);
  parameter WIDTH = 1;

  input [WIDTH-1:0] A;
  input [WIDTH-1:0] B;
  input S;
  output [WIDTH-1:0] Y;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_mux
      sky130_fd_sc_hd__mux2_1 _TECHMAP_REPLACE_ (
        .A0(A[i]),
        .A1(B[i]),
        .S(S),
        .X(Y[i])
      );
    end
  endgenerate
endmodule
