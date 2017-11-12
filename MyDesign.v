module b_vector_manager(
  input wire en,
  input wire clear,
  input wire clock,

  // Interact with the memory
  input wire [15:0] vector_element,
  output reg [9:0] vector_memory_address,
  output reg memory_enable,

  // Interact with the other internal modules
  output reg b_element_ready,
  output reg [15:0] b0_element,
  output reg [15:0] b1_element,
  output reg [15:0] b2_element,
  output reg [15:0] b3_element,

  output reg b0_cached,
  output reg b1_cached,
  output reg b2_cached,
  output reg b3_cached,

  output reg last_element
  );

  reg new_element_ready;

  reg b0_finishing;
  reg b1_finishing;
  reg b2_finishing;
  reg b3_finishing;

  reg [3:0] vector_cache_address;

  wire all_b_vectors_cached;

  // Counter to loop through the currently selected element
  wire [3:0] element_index;
  wire [1:0] vector_index;

  wire write_b0;
  wire write_b1;
  wire write_b2;
  wire write_b3;

  wire [15:0] cached_b0;
  wire [15:0] cached_b1;
  wire [15:0] cached_b2;
  wire [15:0] cached_b3;

  wire vector_index_on_last_value;
  wire restart_element_index;
  reg _last_element;

  wire reset_vector_index;

  assign all_b_vectors_cached = b0_cached && b1_cached && b2_cached && b3_cached;

  assign reset_vector_index = clear || (vector_index == 2'b11 && restart_element_index);

  assign write_b0 = en && ~b0_cached;
  assign write_b1 = en && ~b1_cached;
  assign write_b2 = en && ~b2_cached;
  assign write_b3 = en && ~b3_cached;

  element_index_counter c0(.en(en), .clock(clock), .clear(clear), .element_index(element_index), .new_vector(restart_element_index));
  two_bit_counter c1(.clock(clock), .clear(reset_vector_index), .increment(restart_element_index), .counter(vector_index), .last_value(vector_index_on_last_value));

  vector_cache b0(.clock(clock), .address(vector_cache_address), .write(write_b0), .vector_write_element(vector_element), .vector_read_element(cached_b0));
  vector_cache b1(.clock(clock), .address(vector_cache_address), .write(write_b1), .vector_write_element(vector_element), .vector_read_element(cached_b1));
  vector_cache b2(.clock(clock), .address(vector_cache_address), .write(write_b2), .vector_write_element(vector_element), .vector_read_element(cached_b2));
  vector_cache b3(.clock(clock), .address(vector_cache_address), .write(write_b3), .vector_write_element(vector_element), .vector_read_element(cached_b3));

  always @(posedge clock) begin
    memory_enable <= clear ? 1'b0 : en;
    vector_memory_address <= clear ? 10'b0 : (all_b_vectors_cached ? 10'b0 : {4'h0, vector_index, element_index});
    vector_cache_address <= clear ? 1'b0 : element_index;

    _last_element <= clear ? 1'b0 : restart_element_index;
    b0_finishing <= clear ? 1'b0 : (vector_index == 2'b00 && restart_element_index);
    b1_finishing <= clear ? 1'b0 : (vector_index == 2'b01 && restart_element_index);
    b2_finishing <= clear ? 1'b0 : (vector_index == 2'b10 && restart_element_index);
    b3_finishing <= clear ? 1'b0 : (vector_index == 2'b11 && restart_element_index);

    last_element <= clear ? 1'b0 : _last_element;
    b0_cached <= clear ? 1'b0 : (b0_finishing ? 1'b1 : b0_cached);
    b1_cached <= clear ? 1'b0 : (b1_finishing ? 1'b1 : b1_cached);
    b2_cached <= clear ? 1'b0 : (b2_finishing ? 1'b1 : b2_cached);
    b3_cached <= clear ? 1'b0 : (b3_finishing ? 1'b1 : b3_cached);

    b0_element <= clear ? 16'b0 : (b0_cached ? cached_b0 : vector_element);
    b1_element <= clear ? 16'b0 : (b1_cached ? cached_b1 : vector_element);
    b2_element <= clear ? 16'b0 : (b2_cached ? cached_b2 : vector_element);
    b3_element <= clear ? 16'b0 : (b3_cached ? cached_b3 : vector_element);

    new_element_ready <= clear ? 1'b0 : en;
    b_element_ready <= clear ? 1'b0 : (new_element_ready ? 1'b1 : 1'b0);
  end

endmodule
module column_index_counter(
    input wire en,
    input wire clear,
    input wire clock,
    output reg [1:0] column_index,
    output wire will_reset
  );

  wire clear_counter;
  assign will_reset = (column_index == 2'b10);
  assign clear_counter = clear || will_reset;

  always @(posedge clock) begin
    casex ({clear_counter, en})
      2'b00: column_index <= column_index;
      2'b01: column_index <= column_index + 4'b0001;
      2'b1x: column_index <= 2'b00;
    endcase
  end


endmodule
module dotproduct_mock (
  input wire signed [15:0] a,
  input wire signed [15:0] b,
  input wire signed [31:0] c,
  input wire tc,

  output wire signed [31:0] mac
);

  DW02_mac #(16, 16) U1 (.A(a), .B(b), .C(c), .TC(tc), .MAC(mac));
  //assign mac = a + b + c;

endmodule
module element_index_counter(
   input wire en,
   input wire clear,
   input wire clock,

   output reg [3:0] element_index,
   output wire new_vector
  );

  assign new_vector = element_index[3];

  always @(posedge clock) begin
    casex ({clear, new_vector, en})
      3'b000: element_index <= element_index;
      3'b001: element_index <= element_index + 4'b0001;
      3'b01x: element_index <= 4'b0000;
      3'b1xx: element_index <= 4'b0000;
    endcase
  end

endmodule
module enable_state_controller (
  input wire clear,
  input wire clock,
  input wire go,
  input wire finish,
  output reg enable
);

  always @(posedge clock) begin
    casex ({clear, finish, go})
      3'b000: enable <= enable;
      3'b001: enable <= 1'b1;
      3'b01x: enable <= 1'b0;
      3'b1xx: enable <= 1'b0;
    endcase
  end

endmodule
module filter_memory_manager (
  input wire clock,
  input wire clear,
  input wire en,

  input wire [15:0] vector_element,
  output wire [9:0] vector_memory_address,
  output wire memory_enable,
  output reg memory_write,
  output reg [15:0] filter_write_element,

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

  reg state;
  wire [15:0] m_mem_element;
  wire [9:0] m_mem_address;
  wire m_mem_enable;
  wire m_mem_write;
  wire enabled_request;

  assign enabled_request = state && m_element_requested;

  assign vector_memory_address = state ? m_mem_address : b_mem_address;
  assign memory_enable = state ? m_mem_enable : b_mem_enable;
  assign m_mem_element = state ? vector_element : 16'b0;
  assign b_mem_element = state ? 16'b0 : vector_element;

  b_vector_manager m0(.en(en), .clock(clock), .clear(clear), .vector_element(b_mem_element), .vector_memory_address(b_mem_address), .memory_enable(b_mem_enable), .b_element_ready(b_element_ready), .b0_element(b0_element), .b1_element(b1_element), .b2_element(b2_element), .b3_element(b3_element), .b0_cached(b0_cached), .b1_cached(b1_cached), .b2_cached(b2_cached), .b3_cached(b3_cached), .last_element(last_element));
  m_vector_manager m1(.clock(clock), .clear(clear), .en(en), .vector_element(m_mem_element), .vector_memory_address(m_mem_address), .memory_enable(m_mem_enable), .m_element_requested(enabled_request), .m_element_ready(m_element_ready), .m_element(m_element), .last_element(last_m_element));

  // State 0 = B Vector Manager active
  // State 1 = M vector manager active
  always @(posedge clock) begin
    state <= clear ? 1'b0 : b3_cached;
    memory_write <= 1'b0;
    filter_write_element <= 16'b0;
  end

endmodule
module first_stage_quadrant(
  input wire clock,
  input wire clear,
  input wire go,

  input wire last_element,
  input wire [1:0] quadrant,

  input wire signed [15:0] b0_element,
  input wire signed [15:0] b1_element,
  input wire signed [15:0] b2_element,
  input wire signed [15:0] b3_element,
  input wire b_element_ready,

  input wire signed [15:0] a0_element,
  input wire signed [15:0] a1_element,
  input wire signed [15:0] a2_element,
  input wire signed [15:0] a3_element,
  input wire a_element_ready,

  output reg [15:0] z_element,
  output reg z_element_ready
  );

  wire enable;
  wire finish_null;

  wire [1:0] active_layer;
  wire next_layer;
  wire active_layer_on_last_value;

  reg signed [15:0] selected_a;
  reg signed [15:0] selected_b;

  reg [31:0] d;
  wire [31:0] mac;
  wire [31:0] c;
  reg vector_finishing;

  wire should_accumulate;

  wire tc;

  assign next_layer = enable && last_element;

  assign should_accumulate = b_element_ready && enable && ~vector_finishing;
  assign c = should_accumulate ? d : 32'b0;
  assign tc = 1'b1;


  enable_state_controller c0(.clock(clock), .clear(clear), .go(go), .finish(finish_null), .enable(enable));
  two_bit_counter c1(.clock(clock), .clear(clear), .increment(next_layer), .counter(active_layer), .last_value(active_layer_on_last_value));

  dotproduct_mock m0(.a(selected_a), .b(selected_b), .c(c), .tc(tc), .mac(mac));

  always @(active_layer, b0_element, b1_element, b2_element, b3_element) begin
    case (active_layer)
      2'b00: selected_b = b0_element;
      2'b01: selected_b = b1_element;
      2'b10: selected_b = b2_element;
      2'b11: selected_b = b3_element;
    endcase
  end

  always @(quadrant, a0_element, a1_element, a2_element, a3_element) begin
    case (quadrant)
      2'b00: selected_a = a0_element;
      2'b01: selected_a = a1_element;
      2'b10: selected_a = a2_element;
      2'b11: selected_a = a3_element;
    endcase
  end

  always @(posedge clock) begin
    d <= clear || ~b_element_ready ? 32'b0 : mac;
    vector_finishing <= clear ? 1'b0 : last_element && enable;

    z_element <= clear ? 16'b0 : (d[31] ? 16'b0 : d[31:16]);
    z_element_ready <= clear ? 1'b0 : vector_finishing;
  end

endmodule
module four_bit_counter(
  input wire clock,
  input wire clear,
  input wire increment,
  output reg [3:0] counter,
  output wire last_value
  );

  always @(posedge clock) begin
    casex ({clear, increment})
      2'b00: counter <= counter;
      2'b01: counter <= counter + 4'b0001;
      2'b1x: counter <= 4'b0000;
    endcase
  end

  assign last_value = (counter == 4'b1111);

endmodule
module input_memory_manager(
  input wire en,
  input wire clear,
  input wire clock,

  // Interact with the memory
  input wire [15:0] vector_element,
  output reg [15:0] input_write_element,
  output reg [8:0] vector_memory_address,
  output reg memory_enable,
  output reg memory_write,

  // Interact with the other internal modules
  output reg a_element_ready,
  output reg [15:0] a0_element,
  output reg [15:0] a1_element,
  output reg [15:0] a2_element,
  output reg [15:0] a3_element
  );

  reg new_element_ready;

  reg a0_cached;
  reg a1_cached;
  reg a2_cached;
  reg a3_cached;

  reg a0_finishing;
  reg a1_finishing;
  reg a2_finishing;
  reg a3_finishing;

  reg [3:0] vector_cache_address;

  wire [1:0] major_quadrant;
  wire [1:0] minor_quadrant;
  wire [1:0] column_index;
  wire [1:0] row_index;
  wire [3:0] element_index;

  wire major_counter_on_last_value;
  wire will_restart_column_counter;
  wire row_counter_on_last_value;
  wire new_vector;

  wire write_a0;
  wire write_a1;
  wire write_a2;
  wire write_a3;

  wire [15:0] cached_a0;
  wire [15:0] cached_a1;
  wire [15:0] cached_a2;
  wire [15:0] cached_a3;

  wire [3:0] column;
  wire [3:0] row;

  reg [3:0] column_base;
  reg [3:0] row_base;

  wire change_major_quadrant;
  wire change_minor_quadrant;

  wire minor_counter_on_last_value;

  assign column = column_base + {2'b00, column_index};
  assign row = row_base + {2'b00, row_index};

  assign change_major_quadrant = row_counter_on_last_value && will_restart_column_counter;
  assign change_minor_quadrant = change_major_quadrant && major_counter_on_last_value;

  assign write_a0 = en && ~a0_cached;
  assign write_a1 = en && ~a1_cached;
  assign write_a2 = en && ~a2_cached;
  assign write_a3 = en && ~a3_cached;

  two_bit_counter major_counter(.clear(clear), .clock(clock), .increment(change_major_quadrant), .last_value(major_counter_on_last_value), .counter(major_quadrant));
  two_bit_counter minor_counter(.clear(clear), .clock(clock), .increment(change_minor_quadrant), .last_value(minor_counter_on_last_value), .counter(minor_quadrant));
  column_index_counter column_counter(.clear(clear), .clock(clock), .en(en), .will_reset(will_restart_column_counter), .column_index(column_index));
  row_index_counter row_counter(.clear(clear), .clock(clock), .increment(will_restart_column_counter), .last_value(row_counter_on_last_value), .row_index(row_index));
  element_index_counter cache_counter(.en(en), .clock(clock), .clear(clear), .element_index(element_index), .new_vector(new_vector));
  vector_cache b0(.clock(clock), .address(vector_cache_address), .write(write_a0), .vector_write_element(vector_element), .vector_read_element(cached_a0));
  vector_cache b1(.clock(clock), .address(vector_cache_address), .write(write_a1), .vector_write_element(vector_element), .vector_read_element(cached_a1));
  vector_cache b2(.clock(clock), .address(vector_cache_address), .write(write_a2), .vector_write_element(vector_element), .vector_read_element(cached_a2));
  vector_cache b3(.clock(clock), .address(vector_cache_address), .write(write_a3), .vector_write_element(vector_element), .vector_read_element(cached_a3));

  always @(posedge clock) begin
    memory_write <= 1'b0;
    input_write_element <= 16'b0;
    memory_enable <= clear ? 1'b0 : (en ? 1'b1 : 1'b0);
    vector_memory_address <= clear ? 4'b0 : {1'b0, row, column};
    vector_cache_address <= clear ? 1'b0 : element_index;

    a0_finishing <= clear ? 1'b0 : (major_quadrant == 2'b00 && change_major_quadrant);
    a1_finishing <= clear ? 1'b0 : (major_quadrant == 2'b01 && change_major_quadrant);
    a2_finishing <= clear ? 1'b0 : (major_quadrant == 2'b10 && change_major_quadrant);
    a3_finishing <= clear ? 1'b0 : (major_quadrant == 2'b11 && change_major_quadrant);

    a0_cached <= (clear || a3_finishing) ? 1'b0 : (a0_finishing ? 1'b1 : a0_cached);
    a1_cached <= (clear || a0_finishing) ? 1'b0 : (a1_finishing ? 1'b1 : a1_cached);
    a2_cached <= (clear || a1_finishing) ? 1'b0 : (a2_finishing ? 1'b1 : a2_cached);
    a3_cached <= (clear || a2_finishing) ? 1'b0 : (a3_finishing ? 1'b1 : a3_cached);

    a0_element <= clear ? 16'b0 : (a0_cached ? cached_a0 : vector_element);
    a1_element <= clear ? 16'b0 : (a1_cached ? cached_a1 : vector_element);
    a2_element <= clear ? 16'b0 : (a2_cached ? cached_a2 : vector_element);
    a3_element <= clear ? 16'b0 : (a3_cached ? cached_a3 : vector_element);

    new_element_ready <= clear ? 1'b0 : en;
    a_element_ready <= clear ? 1'b0 : (new_element_ready ? 1'b1 : 1'b0);
  end

  always @ (major_quadrant, minor_quadrant) begin
    case ({major_quadrant[0], minor_quadrant[0]})
      2'b00: column_base = 4'b0000;
      2'b01: column_base = 4'b0011;
      2'b10: column_base = 4'b0110;
      2'b11: column_base = 4'b1001;
    endcase
    case ({major_quadrant[1], minor_quadrant[1]})
      2'b00: row_base = 4'b0000;
      2'b01: row_base = 4'b0011;
      2'b10: row_base = 4'b0110;
      2'b11: row_base = 4'b1001;
    endcase
  end

endmodule
module m_vector_manager(
    input wire clock,
    input wire clear,
    input wire en,

    input wire [15:0] vector_element,
    output reg [9:0] vector_memory_address,
    output reg memory_enable,

    input wire m_element_requested,
    output reg m_element_ready,
    output reg [15:0] m_element,
    output wire last_element
  );

  wire filter_vector_index_resetting;

  wire enable;
  enable_state_controller c0(.clock(clock), .clear(clear), .go(m_element_requested), .finish(filter_vector_index_resetting), .enable(enable));

  wire [1:0] layer;
  wire increment_layer;
  assign increment_layer = enable && filter_vector_index_resetting;
  wire new_layer;
  two_bit_counter c1(.clock(clock), .clear(clear), .increment(increment_layer), .counter(layer), .last_value(new_layer));

  wire [1:0] minor_quadrant;
  wire increment_minor_quadrant;
  assign increment_minor_quadrant = enable && increment_layer && new_layer;
  wire new_minor_quadrant;
  two_bit_counter c2(.clock(clock), .clear(clear), .increment(increment_minor_quadrant), .counter(minor_quadrant), .last_value(new_minor_quadrant));

  wire [1:0] major_quadrant;
  wire increment_major_quadrant;
  assign increment_major_quadrant = enable && new_minor_quadrant && increment_minor_quadrant;
  wire new_major_quadrant;
  two_bit_counter c3(.clock(clock), .clear(clear), .increment(increment_major_quadrant), .counter(major_quadrant), .last_value(new_major_quadrant));

  wire [3:0] col;
  assign col = {major_quadrant[1], minor_quadrant[1], major_quadrant[0], minor_quadrant[0]};

  reg [5:0] row;
  reg [2:0] filter_vector_index;
  assign filter_vector_index_resetting = & filter_vector_index;
  assign last_element = filter_vector_index_resetting;
  reg address_set;
  always @(posedge clock) begin
    filter_vector_index <= clear ? 3'b000 : (enable ? filter_vector_index + 3'b001 : filter_vector_index);
    row <= (clear || filter_vector_index_resetting || m_element_requested) ? 6'b000100 + {4'h0, layer} : ( enable ? row + 6'b000100 : row );
    address_set <= clear ? 1'b0 : enable;
    m_element <= clear ? 16'b0 : vector_element;
    m_element_ready <= clear ? 1'b0 : address_set;
    vector_memory_address <= {row, col};
    memory_enable <= clear ? 1'b0 : enable;
  end



endmodule
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

  wire tc;
  assign tc = 1'b1;
  wire [31:0] mac;
  dotproduct_mock m0(.a(active_z), .b(active_m), .c(c), .tc(tc), .mac(mac));

  reg [5:0] finish_counter;
  reg finishing_computation;
  reg writing_output;
  reg writing_address;
  wire [2:0] next_address;
  assign next_address = output_ram_write ? output_ram_address + 3'b001 : 3'b0;
  always @(posedge clock) begin
    casex ({clear, next_element, selected_w[7]})
      3'b000: selected_w <= selected_w;
      3'b001: selected_w <= selected_w;
      3'b010: selected_w <= selected_w << 1'b1;
      3'b011: selected_w <= 8'h01;
      3'b1xx: selected_w <= 8'h01;
    endcase

    finishing_computation <= clear ? 1'b0 : last_element;
    writing_output <= clear ? 1'b0 : finishing_computation;
    writing_address <= clear ? 1'b0 : writing_output;
    output_ram_enable <= clear ? 1'b0 : writing_address && en && ~(&output_ram_address);
    output_ram_write <= clear ? 1'b0 : writing_address && en && ~(&output_ram_address);
    output_ram_address <= clear ? 3'b000 : (writing_address ? next_address : output_ram_address);
    finished <= clear ? 1'b0 : (output_ram_address == 3'b111 ? 1'b1 : finished);

    w0 <= clear ? 31'b0 : (selected_w[0] && next_element ? mac : w0);
    w1 <= clear ? 31'b0 : (selected_w[1] && next_element ? mac : w1);
    w2 <= clear ? 31'b0 : (selected_w[2] && next_element ? mac : w2);
    w3 <= clear ? 31'b0 : (selected_w[3] && next_element ? mac : w3);
    w4 <= clear ? 31'b0 : (selected_w[4] && next_element ? mac : w4);
    w5 <= clear ? 31'b0 : (selected_w[5] && next_element ? mac : w5);
    w6 <= clear ? 31'b0 : (selected_w[6] && next_element ? mac : w6);
    w7 <= clear ? 31'b0 : (selected_w[7] && next_element ? mac : w7);

    case (next_address)
      3'b000: output_ram_data <= w0[31] ? 16'b0 : w0[31:16];
      3'b001: output_ram_data <= w1[31] ? 16'b0 : w1[31:16];
      3'b010: output_ram_data <= w2[31] ? 16'b0 : w2[31:16];
      3'b011: output_ram_data <= w3[31] ? 16'b0 : w3[31:16];
      3'b100: output_ram_data <= w4[31] ? 16'b0 : w4[31:16];
      3'b101: output_ram_data <= w5[31] ? 16'b0 : w5[31:16];
      3'b110: output_ram_data <= w6[31] ? 16'b0 : w6[31:16];
      3'b111: output_ram_data <= w7[31] ? 16'b0 : w7[31:16];
    endcase
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
module row_index_counter(
  input wire clear,
  input wire clock,
  input wire increment,
  output reg [1:0] row_index,
  output wire last_value
);

  assign last_value = (row_index == 2'b10);

  always @ (posedge clock) begin
    casex ({clear, increment})
      2'b00: row_index <= row_index;
      2'b01: row_index <= last_value ? 2'b00 : row_index + 2'b01;
      2'b1x: row_index <= 2'b00;
    endcase
  end

endmodule
module second_stage(
  input wire clock,
  input wire en,
  input wire clear,

  input wire [15:0] z0_element,
  input wire [15:0] z1_element,
  input wire [15:0] z2_element,
  input wire [15:0] z3_element,

  input wire z0_element_ready,
  input wire z1_element_ready,
  input wire z2_element_ready,
  input wire z3_element_ready,

  output wire m_element_requested,
  input wire m_element_ready,
  input wire [15:0] m_element,
  input wire last_m_element,

  output wire [15:0] output_ram_data,
  output wire [2:0] output_ram_address,
  output wire output_ram_write,
  output wire output_ram_enable,

  output wire finished
);

  wire write_elements;
  assign write_elements = z0_element_ready || z1_element_ready || z2_element_ready || z3_element_ready;

  wire [3:0] z0_cache_address;
  wire [3:0] z1_cache_address;
  wire [3:0] z2_cache_address;
  wire [3:0] z3_cache_address;

  wire [3:0] z0_store_address;
  wire [3:0] z1_store_address;
  wire [3:0] z2_store_address;
  wire [3:0] z3_store_address;

  wire [15:0] z0_cache_element;
  wire [15:0] z1_cache_element;
  wire [15:0] z2_cache_element;
  wire [15:0] z3_cache_element;

  wire [3:0] cache_read_address;
  reg final_m_element;
  wire finishing_cache_index;

  wire [1:0] selected_cache;
  wire last_cache;

  reg start_dotproduct;
  reg fetching_z;
  reg z_element_ready;
  reg [15:0] z_element;

  reg finishing_supply;

  wire increment_cache;
  assign increment_cache = finishing_cache_index && final_m_element;
  assign m_element_requested = write_elements;

  assign z0_cache_address = fetching_z ? cache_read_address : z0_store_address;
  assign z1_cache_address = fetching_z ? cache_read_address : z1_store_address;
  assign z2_cache_address = fetching_z ? cache_read_address : z2_store_address;
  assign z3_cache_address = fetching_z ? cache_read_address : z3_store_address;


  four_bit_counter c0(.clock(clock), .clear(clear), .increment(z0_element_ready), .counter(z0_store_address), .last_value());
  z_vector_cache z0(.clock(clock), .address(z0_cache_address), .write(write_elements), .vector_write_element(z0_element), .vector_read_element(z0_cache_element));

  four_bit_counter c1(.clock(clock), .clear(clear), .increment(z1_element_ready), .counter(z1_store_address), .last_value());
  z_vector_cache z1(.clock(clock), .address(z1_cache_address), .write(write_elements), .vector_write_element(z1_element), .vector_read_element(z1_cache_element));

  four_bit_counter c2(.clock(clock), .clear(clear), .increment(z2_element_ready), .counter(z2_store_address), .last_value());
  z_vector_cache z2(.clock(clock), .address(z2_cache_address), .write(write_elements), .vector_write_element(z2_element), .vector_read_element(z2_cache_element));

  four_bit_counter c3(.clock(clock), .clear(clear), .increment(z3_element_ready), .counter(z3_store_address), .last_value());
  z_vector_cache z3(.clock(clock), .address(z3_cache_address), .write(write_elements), .vector_write_element(z3_element), .vector_read_element(z3_cache_element));

  four_bit_counter c4(.clock(clock), .clear(clear), .increment(final_m_element), .counter(cache_read_address), .last_value(finishing_cache_index));

  two_bit_counter c5(.clock(clock), .clear(clear), .increment(increment_cache), .counter(selected_cache), .last_value(last_cache));

  output_memory_manager m0(.clock(clock), .clear(clear), .en(en), .active_z(z_element), .active_m(m_element), .next_element(m_element_ready), .last_element(finishing_supply), .output_ram_address(output_ram_address), .output_ram_data(output_ram_data), .output_ram_enable(output_ram_enable), .output_ram_write(output_ram_write), .finished(finished));

  always @(posedge clock) begin
    start_dotproduct <= clear ? 1'b0 : write_elements;
    fetching_z <= clear ? 1'b0 : start_dotproduct;
    z_element_ready <= clear ? 1'b0 : fetching_z;
    final_m_element <= clear ? 1'b0 : last_m_element;
    finishing_supply <= clear ? 1'b0 : last_cache && finishing_cache_index;

    case (selected_cache)
      2'b00: z_element <= fetching_z ? z0_cache_element : z_element;
      2'b01: z_element <= fetching_z ? z1_cache_element : z_element;
      2'b10: z_element <= fetching_z ? z2_cache_element : z_element;
      2'b11: z_element <= fetching_z ? z3_cache_element : z_element;
    endcase
  end

endmodule
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
module two_bit_counter(
  input wire clock,
  input wire clear,
  input wire increment,
  output reg [1:0] counter,
  output wire last_value
  );

  always @(posedge clock) begin
    casex ({clear, increment})
      2'b00: counter <= counter;
      2'b01: counter <= counter + 2'b01;
      2'b1x: counter <= 2'b00;
    endcase
  end

  assign last_value = (counter == 2'b11);

endmodule
module vector_cache(
  input wire clock,
  input wire [3:0] address,
  input wire write,
  input wire [15:0] vector_write_element,
  output reg [15:0] vector_read_element
);

  reg [15:0] cache [0:8];

  always @ (posedge clock) begin
    cache[address] <= write ? vector_write_element : cache[address];
  end

  always @ ( * ) begin
    vector_read_element = cache[address];
  end

endmodule
module z_vector_cache(
  input wire clock,
  input wire [3:0] address,
  input wire write,
  input wire [15:0] vector_write_element,
  output reg [15:0] vector_read_element
);

  reg [15:0] cache [0:15];

  always @ (posedge clock) begin
    cache[address] <= write ? vector_write_element : cache[address];
  end

  always @ ( * ) begin
    vector_read_element = cache[address];
  end

endmodule
