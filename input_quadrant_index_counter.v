module input_quadrant_index_counter(
  input wire en,
  input wire clock,
  input wire clear,
  output reg [5:0] counter
  );

  always @(posedge clock) begin
    casex ({clear, en})
      2'b00: counter <= counter;
      2'b01: counter <= counter + 6'b000001;
      2'b1x: counter <= 6'b0;
      default: counter <= 6'b0;
    endcase
  end

endmodule
