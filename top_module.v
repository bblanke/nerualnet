module top_module(
  //---------------------------------------------------------------------------
  // Control
  //
  output reg                  dut__xxx__finish   ,
  input  wire                 xxx__dut__go       ,

  //---------------------------------------------------------------------------
  // b-vector memory
  //
  output wire  [ 8:0]          dut__bvm__address  ,
  output wire                  dut__bvm__enable   ,
  output wire                  dut__bvm__write    ,
  output wire  [15:0]          dut__bvm__data     ,  // write data
  input  wire [15:0]          bvm__dut__data     ,  // read data

  //---------------------------------------------------------------------------
  // Input data memory
  //
  output wire  [ 8:0]          dut__dim__address  ,
  output wire                  dut__dim__enable   ,
  output wire                  dut__dim__write    ,
  output wire  [15:0]          dut__dim__data     ,  // write data
  input  wire [15:0]          dim__dut__data     ,  // read data


  //---------------------------------------------------------------------------
  // Output data memory
  //
  output reg  [ 2:0]          dut__dom__address  ,
  output reg  [15:0]          dut__dom__data     ,  // write data
  output reg                  dut__dom__enable   ,
  output reg                  dut__dom__write    ,


  //-------------------------------
  // General
  //
  input  wire                 clk             ,
  input  wire                 reset
  );

  wire global_enable;
  global_state m0(.clear(reset), .clock(clk), .go(xxx__dut__go), .finish(), .global_enable(global_enable));

  wire b_elements_ready;
  wire [15:0] b0_element;
  wire [15:0] b1_element;
  wire [15:0] b2_element;
  wire [15:0] b3_element;
  filter_memory_manager m1(.en(global_enable), .clear(reset), .clock(clk), .vector_element(bvm__dut__data), .vector_memory_address(dut__bvm__address), .memory_enable(dut__bvm__enable), .memory_write(dut__bvm__write), .b_elements_ready(b_elements_ready), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element));

endmodule
