module output_memory_manager (
  input wire clock,
  input wire clear,
  input wire en,

  input wire [15:0] active_z,
  input wire [15:0] active_m,
  input wire next_element,
  input wire last_element,

  output wire [2:0] output_ram_address,
  output wire [15:0] output_ram_data,
  output wire output_ram_enable,
  output wire output_ram_write
);

  wire accept_supply;
  enable_state_controller c0(.clock(clock), .clear(clear), .go(en), .finish(last_element), .enable(accept_supply));

  reg [31:0] w0;
  reg [31:0] w1;
  reg [31:0] w2;
  reg [31:0] w3;
  reg [31:0] w4;
  reg [31:0] w5;
  reg [31:0] w6;
  reg [31:0] w7;
  reg [7:0] selected_w;

  reg [31:0] c;

  assign tc = 1'b1;
  wire [31:0] mac;
  dotproduct_mock m0(.a(active_z), .b(active_m), .c(c), .tc(tc), .mac(mac));

  reg [5:0] finish_counter;
  always @(posedge clock) begin
    casex ({clear, next_element, selected_w[7]})
      3'b000: selected_w <= selected_w;
      3'b001: selected_w <= selected_w;
      3'b010: selected_w <= selected_w << 1'b1;
      3'b011: selected_w <= 8'h01;
      3'b1xx: selected_w <= 8'h01;
      default: selected_w <= 8'h01;
    endcase

    w0 <= clear ? 31'b0 : (selected_w[0] && next_element ? mac : w0);
    w1 <= clear ? 31'b0 : (selected_w[1] && next_element ? mac : w1);
    w2 <= clear ? 31'b0 : (selected_w[2] && next_element ? mac : w2);
    w3 <= clear ? 31'b0 : (selected_w[3] && next_element ? mac : w3);
    w4 <= clear ? 31'b0 : (selected_w[4] && next_element ? mac : w4);
    w5 <= clear ? 31'b0 : (selected_w[5] && next_element ? mac : w5);
    w6 <= clear ? 31'b0 : (selected_w[6] && next_element ? mac : w6);
    w7 <= clear ? 31'b0 : (selected_w[7] && next_element ? mac : w7);
  end

  always @(selected_w) begin
    case (selected_w)
      8'h01: c = w0;
      8'h02: c = w1;
      8'h04: c = w2;
      8'h08: c = w3;
      8'h10: c = w4;
      8'h20: c = w5;
      8'h40: c = w6;
      8'h80: c = w7;
      default: c = w0;
    endcase
  end


endmodule
