module m_vector_manager_tb();

  reg clock;
  reg clear;
  reg en;

  wire [9:0] vector_memory_address;
  wire [15:0] vector_element;
  wire memory_enable;
  wire memory_write;

  reg m_element_requested;
  wire m_element_ready;
  wire [15:0] m_element;

  m_vector_manager DUT(.clock(clock), .clear(clear), .en(en), .vector_element(vector_element), .vector_memory_address(vector_memory_address), .memory_enable(memory_enable), .memory_write(memory_write), .m_element_requested(m_element_requested), .m_element_ready(m_element_ready), .m_element(m_element));

  initial begin
    $monitor("clock: %b, requested: %b, enabled: %b, address: %h, data: %h, ready: %b, layer: %b, increment: %b, major: %b, minor: %b", clock, m_element_requested, DUT.enable, vector_memory_address, m_element, m_element_ready, DUT.layer, DUT.increment_layer, DUT.major_quadrant, DUT.minor_quadrant);
    clock = 1'b0;
    clear = 1'b0;
    en = 1'b0;
    #10
    clear = 1'b1;
    #10
    clear = 1'b0;
    #10
    en = 1'b1;
    #20
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    m_element_requested = 1'b1;
    #10
    m_element_requested = 1'b0;
    #110
    $finish;
  end

  always #5 clock = ~clock;

endmodule
