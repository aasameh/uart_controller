module uart_rx_assertions (
  input logic        clk,
  input logic        rst_n,
  input logic        rx_in,
  input logic [2:0]  state,
  input logic [2:0]  bit_cnt,
  input logic [1:0]  data_bits,
  input logic        parity_en,
  input logic        parity_type
);
  import uart_pkg::*;

  property start_state_rx_in_low;
    @(posedge clk) disable iff (!rst_n)
    state == RX_START |-> (rx_in == 0);
  endproperty
  assert property (start_state_rx_in_low)
    else $error("SVA FAIL: rx_in not low in RX_START state");

  property data_state_bit_cnt_valid;
    @(posedge clk) disable iff (!rst_n)
    state == RX_DATA |-> (bit_cnt <= data_bits + 3);
  endproperty
  assert property (data_state_bit_cnt_valid)
    else $error("SVA FAIL: bit_cnt exceeded data_bits in RX_DATA state");

  property parity_type_valid;
    @(posedge clk) disable iff (!rst_n)
    (state == RX_PARITY && parity_en) |-> (parity_type == 0 || parity_type == 1);
  endproperty
  assert property (parity_type_valid)
    else $error("SVA FAIL: invalid parity_type in RX_PARITY state");

endmodule