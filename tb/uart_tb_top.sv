import uvm_pkg::*;
`include "uvm_macros.svh"
import uart_pkg::*;
import uart_verif_pkg::*;

module uart_tb_top;

  // Clock generation
  logic clk, rst_n;
  initial clk = 0;
  always #5 clk = ~clk;  // 100MHz

  // Interface instance
  uart_if uart_vif(.clk(clk), .rst_n(rst_n));

  // DUT instance
  uart_top dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .addr       (uart_vif.addr),
    .wdata      (uart_vif.wdata),
    .wr_en      (uart_vif.wr_en),
    .rd_en      (uart_vif.rd_en),
    .rdata      (uart_vif.rdata),
    .rx_in      (uart_vif.rx_in),
    .tx_out     (uart_vif.tx_out),
    .dtr        (uart_vif.dtr),
    .rts        (uart_vif.rts),
    .out1       (uart_vif.out1),
    .out2       (uart_vif.out2),
    .cts_in     (uart_vif.cts_in),
    .dsr_in     (uart_vif.dsr_in),
    .ri_in      (uart_vif.ri_in),
    .dcd_in     (uart_vif.dcd_in),
    .thre       (uart_vif.thre),
    .temt       (uart_vif.temt),
    .dr         (uart_vif.dr),
    .framing_err(uart_vif.framing_err),
    .parity_err (uart_vif.parity_err),
    .irq        (uart_vif.irq),
    .break_int  (uart_vif.break_int)
  );
  

  // Connect divisor for monitor timing
  assign uart_vif.divisor = dut.divisor;
  assign uart_vif.data_bits = dut.data_bits;
  assign uart_vif.parity_en = dut.parity_en;
  assign uart_vif.parity_type = dut.parity_type;
  assign uart_vif.stop_bits = dut.stop_bits;
  assign uart_vif.tx_start = dut.tx_start;
  assign uart_vif.tx_data  = dut.tx_data;
  assign uart_vif.tx_busy  = dut.tx_busy;

  initial begin
    uart_vif.cts_in = 1'b0;
    uart_vif.dsr_in = 1'b0;
    uart_vif.ri_in  = 1'b0;
    uart_vif.dcd_in = 1'b0;
  end

//   bind uart_top uart_assertions assertions_inst (
//     .clk(clk), .rst_n(rst_n), .tx_out(tx_out),
//     .tx_busy(tx_busy), .temt(temt), .thre(thre), .divisor(divisor)
//   );

//   bind uart_rx uart_rx_assertions rx_assert_inst (
//     .clk(clk), .rst_n(rst_n), .rx_in(rx_in), .state(state),
//     .bit_cnt(bit_cnt), .data_bits(data_bits),
//     .parity_en(parity_en), .parity_type(parity_type)
//   );

//   bind uart_tx uart_tx_assertions tx_assert_inst (
//     .clk(clk), .rst_n(rst_n), .state(state), .bit_cnt(bit_cnt),
//     .data_bits(data_bits), .tx_out(tx_out), .tx_busy(tx_busy),
//     .thre(thre), .divisor(divisor), .parity_en(parity_en),
//     .parity_type(parity_type), .stop_bits(stop_bits),
//     .tx_data(tx_data), .tx_start(tx_start)
//   );


  initial begin
    uvm_config_db#(virtual uart_if)::set(null, "uvm_test_top.env.agent", "vif", uart_vif);
    run_test("uart_test");
  end
  initial begin
    rst_n = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
  end

endmodule