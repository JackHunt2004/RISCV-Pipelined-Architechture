module $_MUX_ (A, B, S, Y);
  input A;
  input B;
  input S;
  output Y;

  sky130_fd_sc_hd__mux2_1 _TECHMAP_REPLACE_ (
    .A0(A),
    .A1(B),
    .S(S),
    .X(Y)
  );
endmodule
