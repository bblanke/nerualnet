module first_stage_quadrant_top_tb();

  reg en, clear, clock;
  reg [1:0] quadrant;
  wire [7:0] filter_address;
  wire filter_address_ready;
  wire [11:0] input_address;
  wire input_address_ready;

  first_stage_quadrant_top DUT(.en(en), .clear(clear), .clock(clock), .quadrant(quadrant), .filter_address(filter_address), .filter_address_ready(filter_address_ready), .input_address(input_address), .input_address_ready(input_address_ready));

  initial begin
    $monitor("clock: %b\tclear: %b\ten: %b\tfilter_address: %h\tinput_address: %h", clock, clear, en, filter_address, input_address);
    clock = 1'b0;
    clear = 1'b0;
    quadrant = 2'b10;
    en = 1'b0;
    #10
    clear = 1'b1;
    #10
    clear = 1'b0;
    #10
    en = 1'b1;
    #1440
    $finish;
  end

  always #5 clock = ~clock;

endmodule
