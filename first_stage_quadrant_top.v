module first_stage_quadrant_top(
  input wire clock,
  input wire clear,
  input wire en,
  input wire [1:0] quadrant,
  input wire [15:0] b_element,
  output wire [8:0] b_element_address,
  output wire b_element_requested,
  output wire [11:0] input_address,
  output wire input_address_ready
  );

  wire new_row, new_vector;
  wire [3:0] element_index;
  element_index_counter c0(.en(en), .clear(clear), .clock(clock), .element_index(element_index), .new_row(new_row), .new_vector(new_vector));

  wire [3:0] column_index;
  wire new_quadrant_row;
  column_index_counter c1(.en(en), .clear(clear), .clock(clock), .new_row(new_row), .new_vector(new_vector), .quadrant_lsb(quadrant[0]), .column_index(column_index), .new_quadrant_row(new_quadrant_row));

  wire [3:0] row_index;
  wire new_layer;
  row_index_counter c2(.en(en), .clear(clear), .clock(clock), .new_row(new_row), .new_vector(new_vector), .new_quadrant_row(new_quadrant_row), .quadrant_msb(quadrant[1]), .row_index(row_index), .new_layer(new_layer));

  wire [1:0] vector_index;
  vector_index_counter c3(.en(en), .clear(clear), .clock(clock), .new_vector(new_vector), .vector_index(vector_index));


endmodule
