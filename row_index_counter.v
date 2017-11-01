module row_index_counter(
  input wire en,
  input wire clear,
  input wire clock,
  input wire new_row,
  input wire new_vector,
  input wire new_quadrant_row,
  input wire quadrant_msb,
  output reg [3:0] row_index,
  output wire new_layer
);

  assign new_layer = new_quadrant_row && ((row_index == 4'b0101) || (row_index == 4'b1011));

  assign restart_counter = new_vector && ~new_quadrant_row;
  assign clear_counter = clear || new_layer;

  wire [3:0] base_row_index;
  assign base_row_index = quadrant_msb ? 4'b0110 : 4'b0000;

  wire [3:0] restarted_row_index;
  assign restarted_row_index = row_index - 4'b0010;

  assign increment_row = new_row || new_quadrant_row;

  always @ (posedge clock) begin
    case({clear_counter,restart_counter, increment_row})
      3'b000: row_index <= row_index;
      3'b001: row_index <= row_index + 4'b0001;
      3'b010: row_index <= restarted_row_index;
      3'b011: row_index <= restarted_row_index;
      3'b100: row_index <= base_row_index;
      3'b101: row_index <= base_row_index;
      3'b110: row_index <= base_row_index;
      3'b111: row_index <= base_row_index;
      default: row_index <= base_row_index;
    endcase
  end

endmodule
