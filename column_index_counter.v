module column_index_counter(
    input wire en,
    input wire clear,
    input wire clock,
    output reg [1:0] column_index,
    output wire will_reset
  );

  assign will_reset = (column_index == 2'b10);
  assign clear_counter = clear || will_reset;

  always @(posedge clock) begin
    case ({clear_counter, en})
      2'b00: column_index <= column_index;
      2'b01: column_index <= column_index + 4'b0001;
      2'b1x: column_index <= 2'b00;
      default: column_index <= 2'b00;
    endcase
  end


endmodule
