module dotproduct_mock (
  input wire signed [15:0] a,
  input wire signed [15:0] b,
  input wire signed [31:0] c,
  input wire tc,

  output wire signed [31:0] mac
);

  assign mac = a + b + c;

endmodule
