interface uart_if (input logic clk, rst_n);
  // CPU bus
  logic [2:0]  addr;
  logic [7:0]  wdata;
  logic        wr_en;
  logic        rd_en;
  logic [7:0]  rdata;

  // Config
  logic [1:0]  data_bits;
  logic        parity_en;
  logic        parity_type;
  logic        stop_bits;
  wire [15:0] divisor;

  // TX/RX
  logic [7:0]  tx_data;
  logic        tx_start;
  logic        tx_out;
  logic        tx_busy;
  logic        temt;
  logic        rx_in;
  logic        irq;

  // Modem
  logic        dtr;
  logic        rts;
  logic        out1;
  logic        out2;
  logic        cts_in;
  logic        dsr_in;
  logic        ri_in;
  logic        dcd_in;

  // Status
  logic        dr;
  logic        thre;
  logic        framing_err;
  logic        parity_err;
  logic        break_int;
endinterface