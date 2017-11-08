module dotproduct_mock (
  input wire [15:0] a,
  input wire [15:0] b,
  input wire [31:0] c,
  input wire tc,

  output wire [31:0] mac
);

  assign mac = a + b + c;

endmodule
