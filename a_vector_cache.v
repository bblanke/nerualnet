module a_vector_cache(
  input wire clock,
  input wire [5:0] address,
  input wire write,
  input wire [15:0] vector_write_element,
  output wire [15:0] vector_read_element
);

  reg [15:0] cache [0:63];

  always @ (posedge clock) begin
    cache[address] <= write ? vector_write_element : cache[address];
  end

  assign vector_read_element = cache[address];

endmodule
