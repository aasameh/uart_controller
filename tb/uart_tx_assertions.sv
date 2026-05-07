module uart_tx_assertions (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [15:0] divisor,
  input  logic [1:0]  data_bits,
  input  logic        parity_en,
  input  logic        parity_type,
  input  logic        stop_bits,
  input  logic [7:0]  tx_data,
  input  logic        tx_start,
  input  logic        tx_out,
  input  logic        tx_busy,
  input  logic        thre,
  input logic [2:0]  state,
  input logic [2:0]  bit_cnt
);

  import uart_pkg::*;

  property bit_cnt_valid;
    @(posedge clk) disable iff (!rst_n)
    state == TX_DATA |-> (bit_cnt <= data_bits + 3);
  endproperty
  assert property (bit_cnt_valid)
    else $error("SVA FAIL: bit_cnt exceeded data_bits in TX_DATA state");

  property tx_busy_valid;
    @(posedge clk) disable iff (!rst_n)
    $fell(tx_busy) |-> (tx_out == 1'b1);
    endproperty
  assert property (tx_busy_valid)
    else $error("SVA FAIL: tx_busy is not valid in TX_DATA state");

endmodule