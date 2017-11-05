module input_memory_manager(
  input wire en,
  input wire clear,
  input wire clock,

  // Interact with the memory
  input wire [15:0] vector_element,
  output reg [8:0] vector_memory_address,
  output reg memory_enable,
  output wire memory_write,

  // Interact with the other internal modules
  output reg a_element_ready,
  output reg [15:0] a0_element,
  output reg [15:0] a1_element,
  output reg [15:0] a2_element,
  output reg [15:0] a3_element,

  output wire vector_restarting
  );

  assign memory_write = 1'b0;
  reg new_element_ready;

  reg a0_cached;
  reg a1_cached;
  reg a2_cached;
  reg a3_cached;

  reg a0_finishing;
  reg a1_finishing;
  reg a2_finishing;
  reg a3_finishing;

  reg [5:0] vector_cache_address;

  wire new_quadrant;
  wire [1:0] current_quadrant;
  wire [1:0] next_quadrant;
  two_bit_counter c0(.clear(clear), .clock(clock), .increment(new_quadrant), .next_value(next_quadrant), .counter(current_quadrant));

  wire new_row, new_vector;
  wire [3:0] element_index;
  element_index_counter c1(.en(en), .clear(clear), .clock(clock), .element_index(element_index), .new_row(new_row), .new_vector(new_vector));

  wire [3:0] column_index;
  wire new_quadrant_row;
  column_index_counter c2(.en(en), .clear(clear), .clock(clock), .new_row(new_row), .new_vector(new_vector), .quadrant_lsb(next_quadrant[0]), .column_index(column_index), .new_quadrant_row(new_quadrant_row));

  wire [3:0] row_index;
  row_index_counter c3(.en(en), .clear(clear), .clock(clock), .new_row(new_row), .new_vector(new_vector), .new_quadrant_row(new_quadrant_row), .quadrant_msb(next_quadrant[1]), .row_index(row_index), .new_layer(new_quadrant));

  wire [5:0] input_quadrant_index;
  assign restart_input_quadrant_index_counter = clear || (input_quadrant_index == 6'b100011);
  input_quadrant_index_counter c4(.en(en), .clear(restart_input_quadrant_index_counter), .clock(clock), .counter(input_quadrant_index));

  wire write_a0;
  wire [15:0] cached_a0;
  a_vector_cache b0(.clock(clock), .address(vector_cache_address), .write(write_a0), .vector_write_element(vector_element), .vector_read_element(cached_a0));

  wire write_a1;
  wire [15:0] cached_a1;
  a_vector_cache b1(.clock(clock), .address(vector_cache_address), .write(write_a1), .vector_write_element(vector_element), .vector_read_element(cached_a1));

  wire write_a2;
  wire [15:0] cached_a2;
  a_vector_cache b2(.clock(clock), .address(vector_cache_address), .write(write_a2), .vector_write_element(vector_element), .vector_read_element(cached_a2));

  wire write_a3;
  wire [15:0] cached_a3;
  a_vector_cache b3(.clock(clock), .address(vector_cache_address), .write(write_a3), .vector_write_element(vector_element), .vector_read_element(cached_a3));

  always @(posedge clock) begin
    memory_enable <= en ? 1'b1 : 1'b0;
    vector_memory_address <= {1'b0, row_index, column_index};
    vector_cache_address <= input_quadrant_index;

    a0_finishing <= clear ? 1'b0 : (current_quadrant == 2'b00 && new_quadrant);
    a1_finishing <= clear ? 1'b0 : (current_quadrant == 2'b01 && new_quadrant);
    a2_finishing <= clear ? 1'b0 : (current_quadrant == 2'b10 && new_quadrant);
    a3_finishing <= clear ? 1'b0 : (current_quadrant == 2'b11 && new_quadrant);

    a0_cached <= clear ? 1'b0 : (a0_finishing ? 1'b1 : a0_cached);
    a1_cached <= clear ? 1'b0 : (a1_finishing ? 1'b1 : a1_cached);
    a2_cached <= clear ? 1'b0 : (a2_finishing ? 1'b1 : a2_cached);
    a3_cached <= clear ? 1'b0 : (a3_finishing ? 1'b1 : a3_cached);

    a0_element <= a0_cached ? cached_a0 : vector_element;
    a1_element <= a1_cached ? cached_a1 : vector_element;
    a2_element <= a2_cached ? cached_a2 : vector_element;
    a3_element <= a3_cached ? cached_a3 : vector_element;

    new_element_ready <= clear ? 1'b0 : en;
    a_element_ready <= new_element_ready ? 1'b1 : 1'b0;
  end

  assign vector_restarting = a0_finishing || a1_finishing || a2_finishing || a3_finishing;

  assign write_a0 = en && ~a0_cached;
  assign write_a1 = en && ~a1_cached;
  assign write_a2 = en && ~a2_cached;
  assign write_a3 = en && ~a3_cached;

endmodule
