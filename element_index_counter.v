module element_index_counter(
   input wire en,
   input wire clear,
   input wire clock,
   output reg [3:0] element_index,
   output wire new_row,
   output wire new_vector
  );

  assign new_vector = element_index[3] == 1'b1;
  assign restart_counter = new_vector || clear;

  always @(posedge clock) begin
    element_index <= restart_counter ? 4'b0000 : element_index + 4'b0001;
  end

  assign new_row = (element_index == 4'b0010) || (element_index == 4'b0101);

endmodule
