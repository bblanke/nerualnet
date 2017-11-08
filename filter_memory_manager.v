module filter_memory_manager (
  input wire clock,
  input wire clear,
  input wire en,

  input wire [15:0] vector_element,
  output wire [9:0] vector_memory_address,
  output wire memory_enable,
  output wire memory_write,

  input wire m_element_requested,
  output wire m_element_ready,
  output wire [15:0] m_element,
  output wire last_m_element,

  output wire b_element_ready,
  output wire [15:0] b0_element,
  output wire [15:0] b1_element,
  output wire [15:0] b2_element,
  output wire [15:0] b3_element,

  output wire b0_cached,
  output wire b1_cached,
  output wire b2_cached,
  output wire b3_cached,

  output wire last_element
);

  wire [15:0] b_mem_element;
  wire [9:0] b_mem_address;
  wire b_mem_enable;
  wire b_mem_write;
  b_vector_manager m0(.en(en), .clock(clock), .clear(clear), .vector_element(b_mem_element), .vector_memory_address(b_mem_address), .memory_enable(b_mem_enable), .memory_write(b_mem_write), .b_element_ready(b_element_ready), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b0_cached(b0_cached), .b1_cached(b1_cached), .b2_cached(b2_cached), .b3_cached(b3_cached), .last_element(last_element));

  wire [15:0] m_mem_element;
  wire [9:0] m_mem_address;
  wire m_mem_enable;
  wire m_mem_write;
  assign enabled_request = state && m_element_requested;
  m_vector_manager m1(.clock(clock), .clear(clear), .en(en), .vector_element(m_mem_element), .vector_memory_address(m_mem_address), .memory_enable(m_mem_enable), .memory_write(m_mem_write), .m_element_requested(enabled_request), .m_element_ready(m_element_ready), .m_element(m_element), .last_element(last_m_element));

  // State 0 = B Vector Manager active
  // State 1 = M vector manager active
  reg state;
  always @(posedge clock) begin
    state <= clear ? 1'b0 : b3_cached;
  end

  assign vector_memory_address = state ? m_mem_address : b_mem_address;
  assign memory_enable = state ? m_mem_enable : b_mem_enable;
  assign memory_write = state ? m_mem_write : b_mem_write;
  assign m_mem_element = state ? vector_element : 16'b0;
  assign b_mem_element = state ? 16'b0 : vector_element;


endmodule
