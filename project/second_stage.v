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
  input wire z3_element_ready,

  output wire m_element_requested,
  input wire m_element_ready,
  input wire [15:0] m_element,
  input wire last_m_element,

  output wire [15:0] output_ram_data,
  output wire [2:0] output_ram_address,
  output wire output_ram_write,
  output wire output_ram_enable,

  output wire finished
);

  wire write_elements;
  assign write_elements = z0_element_ready || z1_element_ready || z2_element_ready || z3_element_ready;

  wire [3:0] z0_cache_address;
  wire [3:0] z1_cache_address;
  wire [3:0] z2_cache_address;
  wire [3:0] z3_cache_address;

  wire [3:0] z0_store_address;
  wire [3:0] z1_store_address;
  wire [3:0] z2_store_address;
  wire [3:0] z3_store_address;

  wire [15:0] z0_cache_element;
  wire [15:0] z1_cache_element;
  wire [15:0] z2_cache_element;
  wire [15:0] z3_cache_element;

  wire [3:0] cache_read_address;
  reg final_m_element;
  wire finishing_cache_index;

  wire [1:0] selected_cache;
  wire last_cache;

  reg start_dotproduct;
  reg fetching_z;
  reg z_element_ready;
  reg [15:0] z_element;

  reg finishing_supply;

  wire increment_cache;
  assign increment_cache = finishing_cache_index && final_m_element;
  assign m_element_requested = write_elements;

  assign z0_cache_address = fetching_z ? cache_read_address : z0_store_address;
  assign z1_cache_address = fetching_z ? cache_read_address : z1_store_address;
  assign z2_cache_address = fetching_z ? cache_read_address : z2_store_address;
  assign z3_cache_address = fetching_z ? cache_read_address : z3_store_address;


  four_bit_counter c0(.clock(clock), .clear(clear), .increment(z0_element_ready), .counter(z0_store_address), .last_value());
  z_vector_cache z0(.clock(clock), .address(z0_cache_address), .write(write_elements), .vector_write_element(z0_element), .vector_read_element(z0_cache_element));

  four_bit_counter c1(.clock(clock), .clear(clear), .increment(z1_element_ready), .counter(z1_store_address), .last_value());
  z_vector_cache z1(.clock(clock), .address(z1_cache_address), .write(write_elements), .vector_write_element(z1_element), .vector_read_element(z1_cache_element));

  four_bit_counter c2(.clock(clock), .clear(clear), .increment(z2_element_ready), .counter(z2_store_address), .last_value());
  z_vector_cache z2(.clock(clock), .address(z2_cache_address), .write(write_elements), .vector_write_element(z2_element), .vector_read_element(z2_cache_element));

  four_bit_counter c3(.clock(clock), .clear(clear), .increment(z3_element_ready), .counter(z3_store_address), .last_value());
  z_vector_cache z3(.clock(clock), .address(z3_cache_address), .write(write_elements), .vector_write_element(z3_element), .vector_read_element(z3_cache_element));

  four_bit_counter c4(.clock(clock), .clear(clear), .increment(final_m_element), .counter(cache_read_address), .last_value(finishing_cache_index));

  two_bit_counter c5(.clock(clock), .clear(clear), .increment(increment_cache), .counter(selected_cache), .last_value(last_cache));

  output_memory_manager m0(.clock(clock), .clear(clear), .en(en), .active_z(z_element), .active_m(m_element), .next_element(m_element_ready), .last_element(finishing_supply), .output_ram_address(output_ram_address), .output_ram_data(output_ram_data), .output_ram_enable(output_ram_enable), .output_ram_write(output_ram_write), .finished(finished));

  always @(posedge clock) begin
    start_dotproduct <= clear ? 1'b0 : write_elements;
    fetching_z <= clear ? 1'b0 : start_dotproduct;
    z_element_ready <= clear ? 1'b0 : fetching_z;
    final_m_element <= clear ? 1'b0 : last_m_element;
    finishing_supply <= clear ? 1'b0 : last_cache && finishing_cache_index;

    case (selected_cache)
      2'b00: z_element <= fetching_z ? z0_cache_element : z_element;
      2'b01: z_element <= fetching_z ? z1_cache_element : z_element;
      2'b10: z_element <= fetching_z ? z2_cache_element : z_element;
      2'b11: z_element <= fetching_z ? z3_cache_element : z_element;
    endcase
  end

endmodule
