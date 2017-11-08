module output_memory_manager (
  input wire clock,
  input wire clear,
  input wire en,

  input wire [15:0] active_z,
  input wire [15:0] active_m,
  input wire next_element,
  input wire last_element,

  output reg [2:0] output_ram_address,
  output reg [15:0] output_ram_data,
  output reg output_ram_enable,
  output reg output_ram_write,

  output reg finished
);

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
  reg writing_output;
  reg writing_address;
  always @(posedge clock) begin
    casex ({clear, next_element, selected_w[7]})
      3'b000: selected_w <= selected_w;
      3'b001: selected_w <= selected_w;
      3'b010: selected_w <= selected_w << 1'b1;
      3'b011: selected_w <= 8'h01;
      3'b1xx: selected_w <= 8'h01;
      default: selected_w <= 8'h01;
    endcase
    writing_output <= clear ? 1'b0 : last_element;
    writing_address <= clear ? 1'b0 : writing_output;
    output_ram_write <= clear ? 1'b0 : writing_output && en;
    output_ram_address <= clear ? 3'b000 : (writing_address ? output_ram_address + 3'b001 : output_ram_address);
    finished <= clear ? 1'b0 : (output_ram_address == 3'b111 ? 1'b1 : finished);

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

  always @(output_ram_address, w0, w1, w2, w3, w4, w5, w6, w7) begin
    case(output_ram_address)
      3'b000: output_ram_data = w0;
      3'b001: output_ram_data = w1;
      3'b010: output_ram_data = w2;
      3'b011: output_ram_data = w3;
      3'b100: output_ram_data = w4;
      3'b101: output_ram_data = w5;
      3'b110: output_ram_data = w6;
      3'b111: output_ram_data = w7;
      default: output_ram_data = 16'b0;
    endcase
  end


endmodule
