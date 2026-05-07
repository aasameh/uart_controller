module uart_assertions(
  input logic clk,
  input logic rst_n,
  input logic tx_out,
  input logic tx_busy,
  input logic temt,
  input logic thre,
  input logic [15:0] divisor
);

  import uart_pkg::*;

  // Assertion: When tx_out goes low, it must stay low for at least one full baud period
  property tx_out_low_duration;
    @(posedge clk) disable iff (!rst_n)
    (tx_out == 0) |-> ##[1:$] (tx_out == 0);
  endproperty
  assert property (tx_out_low_duration) else $error("Assertion failed: When tx_out goes low, it must stay low for at least one full baud period");

  // Assertion: If TEMT is high, then THRE must also be high
  property temt_thre_consistency;
        @(posedge clk) disable iff (!rst_n)
        temt |-> thre;
  endproperty
  assert property (temt_thre_consistency) else $error("Assertion failed: If TEMT is high, then THRE must also be high");
  
  endmodule