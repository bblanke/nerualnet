module b_vector_cache(
  input wire clock,
  input wire [3:0] address,
  input wire write,
  input wire [15:0] vector_write_element,
  output reg [15:0] vector_read_element
);

  reg [15:0] cache [0:8];

  always @ (posedge clock) begin
    cache[address] <= write ? vector_write_element : cache[address];
  end

  always @ ( * ) begin
    vector_read_element = cache[address];
  end

endmodule
