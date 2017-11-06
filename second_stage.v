module second_stage(
  input wire clock,
  input wire en,
  input wire clear,

  input wire [15:0] z0_element,
  input wire [15:0] z1_element,
  input wire [15:0] z2_element,
  input wire [15:0] z3_element,

  input wire z0_element_ready,
  input wire z1_element_ready,
  input wire z2_element_ready,
  input wire z3_element_ready
);

  assign write_elements = z0_element_ready || z1_element_ready || z2_element_ready || z3_element_ready;

  wire [3:0] z0_cache_address;
  wire [15:0] z0_cache_element;
  four_bit_counter c0(.clock(clock), .clear(clear), .increment(z0_element_ready), .counter(z0_cache_address), .last_value());
  z_vector_cache z0(.clock(clock), .address(z0_cache_address), .write(write_elements), .vector_write_element(z0_element), .vector_read_element(z0_cache_element));

  wire [3:0] z1_cache_address;
  wire [15:0] z1_cache_element;
  four_bit_counter c1(.clock(clock), .clear(clear), .increment(z1_element_ready), .counter(z1_cache_address), .last_value());
  z_vector_cache z1(.clock(clock), .address(z1_cache_address), .write(write_elements), .vector_write_element(z1_element), .vector_read_element(z1_cache_element));

  wire [3:0] z2_cache_address;
  wire [15:0] z2_cache_element;
  four_bit_counter c2(.clock(clock), .clear(clear), .increment(z2_element_ready), .counter(z2_cache_address), .last_value());
  z_vector_cache z2(.clock(clock), .address(z2_cache_address), .write(write_elements), .vector_write_element(z2_element), .vector_read_element(z2_cache_element));

  wire [3:0] z3_cache_address;
  wire [15:0] z3_cache_element;
  four_bit_counter c3(.clock(clock), .clear(clear), .increment(z3_element_ready), .counter(z3_cache_address), .last_value());
  z_vector_cache z3(.clock(clock), .address(z3_cache_address), .write(write_elements), .vector_write_element(z3_element), .vector_read_element(z3_cache_element));

endmodule
