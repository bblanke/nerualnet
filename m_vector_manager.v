module m_vector_manager(
    input wire clock,
    input wire clear,
    input wire en,

    input wire [15:0] vector_element,
    output reg [9:0] vector_memory_address,
    output reg memory_enable,
    output wire memory_write,

    input wire m_element_requested,
    output reg m_element_ready,
    output reg [15:0] m_element
  );

  wire filter_vector_index_resetting;

  wire enable;
  enable_state_controller c0(.clock(clock), .clear(clear), .go(m_element_requested), .finish(filter_vector_index_resetting), .enable(enable));

  wire [1:0] layer;
  assign increment_layer = enable && filter_vector_index_resetting;
  wire new_layer;
  two_bit_counter c1(.clock(clock), .clear(clear), .increment(increment_layer), .counter(layer), .last_value(new_layer));

  wire [1:0] minor_quadrant;
  assign increment_minor_quadrant = enable && increment_layer && new_layer;
  wire new_minor_quadrant;
  two_bit_counter c2(.clock(clock), .clear(clear), .increment(increment_minor_quadrant), .counter(minor_quadrant), .last_value(new_minor_quadrant));

  wire [1:0] major_quadrant;
  assign increment_major_quadrant = enable && new_minor_quadrant && increment_minor_quadrant;
  wire new_major_quadrant;
  two_bit_counter c3(.clock(clock), .clear(clear), .increment(increment_major_quadrant), .counter(major_quadrant), .last_value(new_major_quadrant));

  wire [3:0] col;
  assign col = {major_quadrant[1], minor_quadrant[1], major_quadrant[0], minor_quadrant[0]};

  reg [5:0] row;
  reg [2:0] filter_vector_index;
  assign filter_vector_index_resetting = & filter_vector_index;
  reg address_set;
  always @(posedge clock) begin
    filter_vector_index <= clear ? 3'b000 : (enable ? filter_vector_index + 3'b001 : filter_vector_index);
    row <= (clear || filter_vector_index_resetting || m_element_requested) ? 6'b000100 + {4'h0, layer} : ( enable ? row + 6'b000100 : row );
    address_set <= enable;
    m_element_ready <= address_set;
    vector_memory_address <= {row, col};
  end



endmodule
