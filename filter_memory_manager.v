module filter_memory_manager(
  input wire en,
  input wire clear,
  input wire clock,

  // Interact with the memory
  input wire [15:0] vector_element,
  output reg [8:0] vector_memory_address,
  output reg memory_enable,
  output wire memory_write,

  // Interact with the other internal modules
  output reg b_elements_ready,
  output reg [15:0] b0_element,
  output reg [15:0] b1_element,
  output reg [15:0] b2_element,
  output reg [15:0] b3_element
  );

  assign memory_write = 1'b0;
  reg new_element_ready;

  reg b0_cached;
  reg b1_cached;
  reg b2_cached;
  reg b3_cached;

  reg b0_finishing;
  reg b1_finishing;
  reg b2_finishing;
  reg b3_finishing;

  reg [3:0] vector_cache_address;

  assign all_b_vectors_cached = b0_cached && b1_cached && b2_cached && b3_cached;

  // Counter to loop through the currently selected element
  wire [3:0] element_index;
  wire new_vector;
  element_index_counter c0(.en(en), .clock(clock), .clear(clear), .element_index(element_index), .new_row(), .new_vector(new_vector));

  // Counter to loop through the currently selected vector
  wire [1:0] vector_index;
  assign reset_vector_index = (vector_index == 2'b11 && new_vector);
  two_bit_counter c1(.en(en), .clock(clock), .clear(reset_vector_index), .increment(new_vector), .counter(vector_index));

  reg write_b0;
  wire [15:0] cached_b0;
  b_vector_cache b0(.clock(clock), .address(vector_cache_address), .write(write_b0), .vector_write_element(vector_element), .vector_read_element(cached_b0));

  reg write_b1;
  wire [15:0] cached_b1;
  b_vector_cache b1(.clock(clock), .address(vector_cache_address), .write(write_b1), .vector_write_element(vector_element), .vector_read_element(cached_b1));

  reg write_b2;
  wire [15:0] cached_b2;
  b_vector_cache b2(.clock(clock), .address(vector_cache_address), .write(write_b2), .vector_write_element(vector_element), .vector_read_element(cached_b2));

  reg write_b3;
  wire [15:0] cached_b3;
  b_vector_cache b3(.clock(clock), .address(vector_cache_address), .write(write_b3), .vector_write_element(vector_element), .vector_read_element(cached_b3));

  always @(posedge clock) begin
    memory_enable <= en ? 1'b1 : 1'b0;
    vector_memory_address <= all_b_vectors_cached ? 9'b0 : {1'b0, vector_index, element_index};
    vector_cache_address <= element_index;

    b0_finishing <= clear ? 1'b0 : (vector_index == 2'b00 && new_vector);
    b1_finishing <= clear ? 1'b0 : (vector_index == 2'b01 && new_vector);
    b2_finishing <= clear ? 1'b0 : (vector_index == 2'b10 && new_vector);
    b3_finishing <= clear ? 1'b0 : (vector_index == 2'b11 && new_vector);

    b0_cached <= clear ? 1'b0 : (b0_finishing ? 1'b1 : b0_cached);
    b1_cached <= clear ? 1'b0 : (b1_finishing ? 1'b1 : b1_cached);
    b2_cached <= clear ? 1'b0 : (b2_finishing ? 1'b1 : b2_cached);
    b3_cached <= clear ? 1'b0 : (b3_finishing ? 1'b1 : b3_cached);

    write_b0 <= en && ~b0_cached;
    write_b1 <= en && ~b1_cached;
    write_b2 <= en && ~b2_cached;
    write_b3 <= en && ~b3_cached;

    b0_element <= b0_cached ? cached_b0 : vector_element;
    b1_element <= b1_cached ? cached_b1 : vector_element;
    b2_element <= b2_cached ? cached_b2 : vector_element;
    b3_element <= b3_cached ? cached_b3 : vector_element;

    new_element_ready <= clear ? 1'b0 : en;
    b_elements_ready <= new_element_ready ? 1'b1 : 1'b0;
  end

endmodule
