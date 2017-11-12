// synopsys translate_off
`include "/afs/eos.ncsu.edu/dist/synopsys2013/syn/dw/sim_ver/DW02_mac.v"
// synopsys translate_on

module MyDesign (
  //---------------------------------------------------------------------------
  // Control
  //
  output wire                  dut__xxx__finish   ,
  input  wire                 xxx__dut__go       ,

  //---------------------------------------------------------------------------
  // b-vector memory
  //
  output wire  [ 9:0]          dut__bvm__address  ,
  output wire                  dut__bvm__enable   ,
  output wire                  dut__bvm__write    ,
  output wire [15:0]          dut__bvm__data     ,  // write data
  input  wire [15:0]          bvm__dut__data     ,  // read data

  //---------------------------------------------------------------------------
  // Input data memory
  //
  output wire  [ 8:0]          dut__dim__address  ,
  output wire                  dut__dim__enable   ,
  output wire                  dut__dim__write    ,
  output wire [15:0]          dut__dim__data     ,  // write data
  input  wire [15:0]          dim__dut__data     ,  // read data


  //---------------------------------------------------------------------------
  // Output data memory
  //
  output wire  [ 2:0]          dut__dom__address  ,
  output wire  [15:0]          dut__dom__data     ,  // write data
  output wire                  dut__dom__enable   ,
  output wire                  dut__dom__write    ,


  //-------------------------------
  // General
  //
  input  wire                 clk             ,
  input  wire                 reset
  );

  wire global_enable;
  wire finished;
  assign dut__xxx__finish = finished;
  enable_state_controller m0(.clear(reset), .clock(clk), .go(xxx__dut__go), .finish(finished), .enable(global_enable));

  wire b_element_ready;
  wire [15:0] b0_element;
  wire [15:0] b1_element;
  wire [15:0] b2_element;
  wire [15:0] b3_element;
  wire b0_cached;
  wire b1_cached;
  wire b2_cached;
  wire b3_cached;
  wire last_element;

  wire m_element_requested;
  wire m_element_ready;
  wire [15:0] m_element;
  wire last_m_element;
  filter_memory_manager m1(.en(global_enable), .clear(reset), .clock(clk), .vector_element(bvm__dut__data), .vector_memory_address(dut__bvm__address), .memory_enable(dut__bvm__enable), .memory_write(dut__bvm__write), .filter_write_element(dut__bvm__data), .b_element_ready(b_element_ready), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b0_cached(b0_cached), .b1_cached(b1_cached), .b2_cached(b2_cached), .b3_cached(b3_cached), .last_element(last_element), .m_element_requested(m_element_requested), .m_element_ready(m_element_ready), .m_element(m_element), .last_m_element(last_m_element));

  wire a_element_ready;
  wire [15:0] a0_element;
  wire [15:0] a1_element;
  wire [15:0] a2_element;
  wire [15:0] a3_element;
  input_memory_manager m2(.en(global_enable), .clear(reset), .clock(clk), .vector_element(dim__dut__data), .vector_memory_address(dut__dim__address), .memory_enable(dut__dim__enable), .memory_write(dut__dim__write), .input_write_element(dut__dim__data), .a_element_ready(a_element_ready), .a0_element(a0_element), .a1_element(a1_element), .a2_element(a2_element), .a3_element(a3_element));


  wire [15:0] z0_element;
  wire z0_element_ready;
  wire [1:0] quadrant_0;
  assign quadrant_0 = 2'b00;
  first_stage_quadrant q00(.clock(clk), .clear(reset), .go(xxx__dut__go), .last_element(last_element), .quadrant(quadrant_0), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b_element_ready(b_element_ready), .a0_element(a0_element), .a1_element(a1_element), .a2_element(a2_element), .a3_element(a3_element), .a_element_ready(a_element_ready), .z_element(z0_element), .z_element_ready(z0_element_ready));

  wire [15:0] z1_element;
  wire z1_element_ready;
  wire [1:0] quadrant_1;
  assign quadrant_1 = 2'b01;
  first_stage_quadrant q01(.clock(clk), .clear(reset), .go(b0_cached), .last_element(last_element), .quadrant(quadrant_1), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b_element_ready(b_element_ready), .a0_element(a0_element), .a1_element(a1_element), .a2_element(a2_element), .a3_element(a3_element), .a_element_ready(a_element_ready), .z_element(z1_element), .z_element_ready(z1_element_ready));

  wire [15:0] z2_element;
  wire z2_element_ready;
  wire [1:0] quadrant_2;
  assign quadrant_2 = 2'b10;
  first_stage_quadrant q10(.clock(clk), .clear(reset), .go(b1_cached), .last_element(last_element), .quadrant(quadrant_2), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b_element_ready(b_element_ready), .a0_element(a0_element), .a1_element(a1_element), .a2_element(a2_element), .a3_element(a3_element), .a_element_ready(a_element_ready), .z_element(z2_element), .z_element_ready(z2_element_ready));

  wire [15:0] z3_element;
  wire z3_element_ready;
  wire [1:0] quadrant_3;
  assign quadrant_3 = 2'b11;
  first_stage_quadrant q11(.clock(clk), .clear(reset), .go(b2_cached), .last_element(last_element), .quadrant(quadrant_3), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b_element_ready(b_element_ready), .a0_element(a0_element), .a1_element(a1_element), .a2_element(a2_element), .a3_element(a3_element), .a_element_ready(a_element_ready), .z_element(z3_element), .z_element_ready(z3_element_ready));

  second_stage s0(.clock(clk), .clear(reset), .en(global_enable), .z0_element(z0_element), .z1_element(z1_element), .z2_element(z2_element), .z3_element(z3_element), .z0_element_ready(z0_element_ready), .z1_element_ready(z1_element_ready), .z2_element_ready(z2_element_ready), .z3_element_ready(z3_element_ready), .m_element_requested(m_element_requested), .m_element_ready(m_element_ready), .m_element(m_element), .last_m_element(last_m_element), .output_ram_data(dut__dom__data), .output_ram_address(dut__dom__address), .output_ram_write(dut__dom__write), .output_ram_enable(dut__dom__enable), .finished(finished));

  always @(posedge clk) begin
    $display("go: %b, finish: %b, enabled: %b, z0: %h, z1: %h, z ready: %b, output data: %h, output address: %h, write: %b", xxx__dut__go, dut__xxx__finish, global_enable, z0_element, z1_element, z0_element_ready, dut__dom__data, dut__dom__address, dut__dom__write);
  end
endmodule
