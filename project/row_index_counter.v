module row_index_counter(
  input wire clear,
  input wire clock,
  input wire increment,
  output reg [1:0] row_index,
  output wire last_value
);

  assign last_value = (row_index == 2'b10);

  always @ (posedge clock) begin
    casex ({clear, increment})
      2'b00: row_index <= row_index;
      2'b01: row_index <= last_value ? 2'b00 : row_index + 2'b01;
      2'b1x: row_index <= 2'b00;
    endcase
  end

endmodule
