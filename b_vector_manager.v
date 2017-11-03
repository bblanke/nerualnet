module b_vector_manager(
    input wire en,
    input wire clear,
    input wire clock,
    input wire [1:0] vector_index,
    input wire [3:0] element_index,
    input wire [15:0] external_b_element,
    output wire external_b_requested,
    output wire [8:0] external_b_address,
    output reg [15:0] b_element,
    output wire b_element_ready
  );

  assign external_b_requested = (~vector_index[1]) && (~vector_index[0]);
  assign external_b_address = {1'b0,4'b0,element_index};

  wire [15:0] internal_b_element;

  always @ (posedge clock) begin
    b_element <= external_b_requested ? external_b_element : internal_b_element;
  end

endmodule
