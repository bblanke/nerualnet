module top_module_tb();

  reg go;
  wire finish;

  wire [8:0] filter_ram_address;
  wire filter_ram_enable;
  wire filter_ram_write;
  wire [15:0] filter_ram__write_data;
  wire [15:0] filter_ram_read_data;

  wire [8:0] input_ram_address;
  wire input_ram_enable;
  wire input_ram_write;
  wire [15:0] input_ram_write_data;
  wire [15:0] input_ram_read_data;

  wire [2:0] output_ram_address;
  wire [15:0] output_ram_data;
  wire output_ram_enable;
  wire output_ram_write;

  reg clock;
  reg reset;

  top_module DUT(.clk(clock), .reset(reset), .dut__xxx__finish(finish), .xxx__dut__go(go), .dut__bvm__address(filter_ram_address), .dut__bvm__enable(filter_ram_enable), .dut__bvm__write(filter_ram_write), .dut__bvm__data(filter_ram__write_data), .bvm__dut__data(filter_ram_read_data), .dut__dim__address(input_ram_address), .dut__dim__enable(input_ram_enable), .dut__dim__write(input_ram_write), .dut__dim__data(input_ram_write_data), .dim__dut__data(input_ram_read_data), .dut__dom__address(output_ram_address), .dut__dom__data(output_ram_data), .dut__dom__enable(output_ram_enable), .dut__dom__write(output_ram_write));

  filter_ram m0(.clock(clock), .enable(filter_ram_enable), .address(filter_ram_address), .read_data(filter_ram_read_data), .write(filter_ram_write), .write_data(filter_ram__write_data));

  initial begin
    $monitor("clock: %b, element index: %h, b0: %h, b1: %h, b2: %h, b3: %h, new: %b, b0 cache: %b", clock, filter_ram_address, DUT.b0_element, DUT.b1_element, DUT.b2_element, DUT.b3_element, DUT.m1.new_vector, DUT.m1.b0_cached);
    clock = 1'b0;
    go = 1'b0;
    #10
    reset = 1'b1;
    #10
    reset = 1'b0;
    #50
    go = 1'b1;
    #10
    go = 1'b0;
    #640
    $finish;
  end

  always #5 clock = ~clock;

endmodule