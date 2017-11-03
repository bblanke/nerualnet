module first_stage_quadrant_top_tb();

  reg en, clear, clock;
  reg [1:0] quadrant;
  wire [7:0] filter_address;
  wire b_vector_requested;
  wire [11:0] input_address;
  wire input_address_ready;
  wire [8:0] b_element_address;

  first_stage_quadrant_top DUT(.en(en), .clear(clear), .clock(clock), .quadrant(quadrant), .b_element_address(b_element_address), .b_element_requested(b_element_requested), .input_address(input_address), .input_address_ready(input_address_ready));

  initial begin
    $monitor("clock: %b\tclear: %b\ten: %b\telement counter: %h\trow: %h\tcolumn: %h", clock, clear, en, DUT.element_index, DUT.row_index, DUT.column_index);
    clock = 1'b0;
    clear = 1'b0;
    quadrant = 2'b10;
    en = 1'b0;
    #10
    clear = 1'b1;
    #10
    clear = 1'b0;
    #45
    en = 1'b1;
    #1440
    $finish;
  end

  always #5 clock = ~clock;

endmodule
