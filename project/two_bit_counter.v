module two_bit_counter(
  input wire clock,
  input wire clear,
  input wire increment,
  output reg [1:0] counter,
  output wire last_value
  );

  always @(posedge clock) begin
    casex ({clear, increment})
      2'b00: counter <= counter;
      2'b01: counter <= counter + 2'b01;
      2'b1x: counter <= 2'b00;
    endcase
  end

  assign last_value = (counter == 2'b11);

endmodule
