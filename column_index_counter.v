module column_index_counter(
    input wire en,
    input wire clear,
    input wire clock,
    input wire new_row,
    input wire new_vector,
    input wire quadrant_lsb,
    output reg [3:0] column_index,
    output wire new_quadrant_row
  );

  //wire [3:0] enabled_column_index;
  //assign enabled_column_index = column_index;
  assign new_quadrant_row = new_vector && ((column_index == 4'b0101) || (column_index == 4'b1011));

  // Finding the base_column_index:
  // assuming the quadrants of the first stage are numbered as follows:
  //  __ __
  // |00|01|
  // |10|11|
  //
  // Then the lsb of the quadrant number determines whether or not to start counting
  // columns at 0 or 6
  wire [3:0] base_column_index;
  assign base_column_index = quadrant_lsb ? 4'b0110 : 4'b0000;

  assign clear_counter = new_quadrant_row || clear; // clears the counter to its start position
  assign restart_counter = new_row && ~new_vector; // only want to restart (move back by 3) if there's a new row but not a new vector ready

  always @(posedge clock) begin
    case ({clear_counter,restart_counter})
      2'b00: column_index <= column_index + 4'b0001;
      2'b01: column_index <= column_index - 4'b0010;
      2'b1x: column_index <= base_column_index;
      default: column_index <= base_column_index;
    endcase
  end


endmodule
