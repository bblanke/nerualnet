module global_state (
  input wire clear,
  input wire clock,
  input wire go,
  input wire finish,
  output reg global_enable
);

  always @(posedge clock) begin
    casex({clear, finish, go})
      3'b000: global_enable <= global_enable;
      3'b001: global_enable <= 1'b1;
      3'b01x: global_enable <= 1'b0;
      3'b1xx: global_enable <= 1'b0;
    endcase
  end

endmodule
