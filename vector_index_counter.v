module vector_index_counter(
  input wire en,
  input wire clock,
  input wire clear,
  input wire new_vector,
  output wire restart_counter,
  output reg [1:0] vector_index
  );

  assign restart_counter = clear || (vector_index == 2'b11 && new_vector);

  always @(posedge clock) begin
    case ({restart_counter, new_vector})
      2'b00: vector_index <= vector_index;
      2'b01: vector_index <= vector_index + 2'b01;
      2'b1x: vector_index <= 2'b00;
      default: vector_index <= 2'b00;
    endcase
  end

endmodule
