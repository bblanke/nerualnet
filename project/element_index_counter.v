module element_index_counter(
   input wire en,
   input wire clear,
   input wire clock,

   output reg [3:0] element_index,
   output wire new_vector
  );

  assign new_vector = element_index[3];

  always @(posedge clock) begin
    casex ({clear, new_vector, en})
      3'b000: element_index <= element_index;
      3'b001: element_index <= element_index + 4'b0001;
      3'b01x: element_index <= 4'b0000;
      3'b1xx: element_index <= 4'b0000;
    endcase
  end

endmodule
