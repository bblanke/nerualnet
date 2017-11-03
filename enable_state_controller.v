module enable_state_controller (
  input wire clear,
  input wire clock,
  input wire go,
  input wire finish,
  output reg enable
);

  always @(posedge clock) begin
    casex({clear, finish, go})
      3'b000: enable <= enable;
      3'b001: enable <= 1'b1;
      3'b01x: enable <= 1'b0;
      3'b1xx: enable <= 1'b0;
    endcase
  end

endmodule
