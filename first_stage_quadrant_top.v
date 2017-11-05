module first_stage_quadrant_top(
  input wire clock,
  input wire clear,
  input wire go,
  input wire [15:0] b0_element,
  input wire [15:0] b1_element,
  input wire [15:0] b2_element,
  input wire [15:0] b3_element,
  input wire b_element_ready,
  input wire [15:0] a0_element,
  input wire [15:0] a1_element,
  input wire [15:0] a2_element,
  input wire [15:0] a3_element,
  input wire a_element_ready,
  input wire vector_finishing,
  output wire [15:0] z_vector,
  output wire z_vector_ready,
  output wire finished
  );

  wire enable;
  enable_state_controller c0(.clock(clock), .clear(clear), .go(go), .finish(), .enable(enable));

  wire [1:0] active_layer;
  two_bit_counter c1(.clock(clock), .clear(clear), .increment(vector_finishing), .next_value(), .counter(active_layer));

  reg [31:0] c;
  assign clear_c = clear || vector_finishing;
  always @(posedge clock) begin
    c <= clear_c ? 32'b0 : c + 1'b1;
  end

endmodule
