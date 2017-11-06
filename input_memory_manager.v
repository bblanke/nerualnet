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
  output reg [15:0] a3_element
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

  reg [3:0] vector_cache_address;

  wire [1:0] major_quadrant;
  assign change_major_quadrant = row_counter_on_last_value && will_restart_column_counter;
  wire major_counter_on_last_value;
  two_bit_counter major_counter(.clear(clear), .clock(clock), .increment(change_major_quadrant), .last_value(major_counter_on_last_value), .counter(major_quadrant));

  wire [1:0] minor_quadrant;
  assign change_minor_quadrant = change_major_quadrant && major_counter_on_last_value;
  // TODO:
  // Can use the last value of this and major_counter_on_last_value to determine when all of the lasyer one counting is done
  two_bit_counter minor_counter(.clear(clear), .clock(clock), .increment(change_minor_quadrant), .last_value(), .counter(minor_quadrant));

  wire [1:0] column_index;
  wire will_restart_column_counter;
  column_index_counter column_counter(.clear(clear), .clock(clock), .en(en), .will_reset(will_restart_column_counter), .column_index(column_index));

  wire [1:0] row_index;
  wire row_counter_on_last_value;
  row_index_counter row_counter(.clear(clear), .clock(clock), .increment(will_restart_column_counter), .last_value(row_counter_on_last_value), .row_index(row_index));

  wire [3:0] element_index;
  wire new_vector;
  element_index_counter cache_counter(.en(en), .clock(clock), .clear(clear), .element_index(element_index), .new_vector(new_vector));

  wire write_a0;
  wire [15:0] cached_a0;
  vector_cache b0(.clock(clock), .address(vector_cache_address), .write(write_a0), .vector_write_element(vector_element), .vector_read_element(cached_a0));

  wire write_a1;
  wire [15:0] cached_a1;
  vector_cache b1(.clock(clock), .address(vector_cache_address), .write(write_a1), .vector_write_element(vector_element), .vector_read_element(cached_a1));

  wire write_a2;
  wire [15:0] cached_a2;
  vector_cache b2(.clock(clock), .address(vector_cache_address), .write(write_a2), .vector_write_element(vector_element), .vector_read_element(cached_a2));

  wire write_a3;
  wire [15:0] cached_a3;
  vector_cache b3(.clock(clock), .address(vector_cache_address), .write(write_a3), .vector_write_element(vector_element), .vector_read_element(cached_a3));

  always @(posedge clock) begin
    memory_enable <= en ? 1'b1 : 1'b0;
    vector_memory_address <= {1'b0, row, column};
    vector_cache_address <= element_index;

    a0_finishing <= (major_quadrant == 2'b00 && change_major_quadrant);
    a1_finishing <= (major_quadrant == 2'b01 && change_major_quadrant);
    a2_finishing <= (major_quadrant == 2'b10 && change_major_quadrant);
    a3_finishing <= (major_quadrant == 2'b11 && change_major_quadrant);

    a0_cached <= (clear || a3_finishing) ? 1'b0 : (a0_finishing ? 1'b1 : a0_cached);
    a1_cached <= (clear || a0_finishing) ? 1'b0 : (a1_finishing ? 1'b1 : a1_cached);
    a2_cached <= (clear || a1_finishing) ? 1'b0 : (a2_finishing ? 1'b1 : a2_cached);
    a3_cached <= (clear || a2_finishing) ? 1'b0 : (a3_finishing ? 1'b1 : a3_cached);

    a0_element <= a0_cached ? cached_a0 : vector_element;
    a1_element <= a1_cached ? cached_a1 : vector_element;
    a2_element <= a2_cached ? cached_a2 : vector_element;
    a3_element <= a3_cached ? cached_a3 : vector_element;

    new_element_ready <= clear ? 1'b0 : en;
    a_element_ready <= new_element_ready ? 1'b1 : 1'b0;
  end

  reg [3:0] column_base;
  reg [3:0] row_base;

  always @ (major_quadrant, minor_quadrant) begin
    case ({major_quadrant[0], minor_quadrant[0]})
      2'b00: column_base = 4'b0000;
      2'b01: column_base = 4'b0011;
      2'b10: column_base = 4'b0110;
      2'b11: column_base = 4'b1001;
      default: column_base = 4'b0000;
    endcase
    case ({major_quadrant[1], minor_quadrant[1]})
      2'b00: row_base = 4'b0000;
      2'b01: row_base = 4'b0011;
      2'b10: row_base = 4'b0110;
      2'b11: row_base = 4'b1001;
    endcase
  end

  wire [3:0] column;
  wire [3:0] row;

  assign column = column_base + {2'b00, column_index};
  assign row = row_base + {2'b00, row_index};

  assign write_a0 = en && ~a0_cached;
  assign write_a1 = en && ~a1_cached;
  assign write_a2 = en && ~a2_cached;
  assign write_a3 = en && ~a3_cached;

endmodule
