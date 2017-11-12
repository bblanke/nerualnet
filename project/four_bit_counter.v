module four_bit_counter(
  input wire clock,
  input wire clear,
  input wire increment,
  output reg [3:0] counter,
  output wire last_value
  );

  always @(posedge clock) begin
    casex ({clear, increment})
      2'b00: counter <= counter;
      2'b01: counter <= counter + 4'b0001;
      2'b1x: counter <= 4'b0000;
    endcase
  end

  assign last_value = (counter == 4'b1111);

endmodule
