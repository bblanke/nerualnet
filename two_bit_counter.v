module two_bit_counter(
  input wire en,
  input wire clock,
  input wire clear,
  input wire increment,
  output reg [1:0] next_value,
  output reg [1:0] counter
  );

  always @(clear, increment) begin
    case ({clear, increment})
      2'b00: next_value = counter;
      2'b01: next_value = counter + 2'b01;
      2'b1x: next_value = 2'b00;
      default: next_value = 2'b00;
    endcase
  end

  always @(posedge clock) begin
    counter <= next_value;
  end

endmodule
