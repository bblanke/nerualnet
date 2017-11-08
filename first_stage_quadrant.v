module first_stage_quadrant(
  input wire clock,
  input wire clear,
  input wire go,

  input wire last_element,
  input wire [1:0] quadrant,

  input wire signed [15:0] b0_element,
  input wire signed [15:0] b1_element,
  input wire signed [15:0] b2_element,
  input wire signed [15:0] b3_element,
  input wire b_element_ready,

  input wire signed [15:0] a0_element,
  input wire signed [15:0] a1_element,
  input wire signed [15:0] a2_element,
  input wire signed [15:0] a3_element,
  input wire a_element_ready,

  output reg [15:0] z_element,
  output reg z_element_ready
  );

  wire enable;
  enable_state_controller c0(.clock(clock), .clear(clear), .go(go), .finish(), .enable(enable));

  wire [1:0] active_layer;
  assign next_layer = enable && last_element;
  two_bit_counter c1(.clock(clock), .clear(clear), .increment(next_layer), .counter(active_layer));

  reg [15:0] selected_b;
  always @(active_layer, b0_element, b1_element, b2_element, b3_element) begin
    case (active_layer)
      2'b00: selected_b = b0_element;
      2'b01: selected_b = b1_element;
      2'b10: selected_b = b2_element;
      2'b11: selected_b = b3_element;
      default: selected_b = b0_element;
    endcase
  end

  reg [15:0] selected_a;
  always @(quadrant, a0_element, a1_element, a2_element, a3_element) begin
    case (quadrant)
      2'b00: selected_a = a0_element;
      2'b01: selected_a = a1_element;
      2'b10: selected_a = a2_element;
      2'b11: selected_a = a3_element;
      default: selected_a = a0_element;
    endcase
  end

  reg [31:0] d;
  wire [31:0] mac;
  wire [31:0] c;
  assign should_accumulate = b_element_ready && enable && ~vector_finishing;
  assign c = should_accumulate ? d : 32'b0;
  assign tc = 1'b1;
  dotproduct_mock m0(.a(selected_a), .b(selected_b), .c(c), .tc(tc), .mac(mac));


  reg vector_finishing;
  always @(posedge clock) begin
    d <= clear || ~b_element_ready ? 32'b0 : mac;
    vector_finishing <= clear ? 1'b0 : last_element && enable;

    z_element <= clear ? 16'b0 : d[15:0];
    z_element_ready <= clear ? 1'b0 : vector_finishing;
  end

endmodule
