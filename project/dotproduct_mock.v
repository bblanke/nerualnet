module dotproduct_mock (
  input wire signed [15:0] a,
  input wire signed [15:0] b,
  input wire signed [31:0] c,
  input wire tc,

  output wire signed [31:0] mac
);

  DW02_mac #(16, 16) U1 (.A(a), .B(b), .C(c), .TC(tc), .MAC(mac));
  //assign mac = a + b + c;

endmodule
