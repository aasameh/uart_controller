module uart_top (
    input logic clk,
    input logic rst_n,
    input logic [2:0] addr,
    input logic [7:0] wdata,
    input logic wr_en,
    input logic rd_en,
    input logic rx_in,
    output logic [7:0] rdata,
    output logic tx_out,
    // Modem control/status
    output logic dtr,
    output logic rts,
    output logic out1,
    output logic out2,
    input  logic cts_in,
    input  logic dsr_in,
    input  logic ri_in,
    input  logic dcd_in,

    // Status outputs from RX/TX
    output logic dr,
    output logic thre,
    output logic temt,
    output logic framing_err,
    output logic parity_err,
    output logic irq,
    output logic break_int
);

    // Config outputs to RX/TX
    logic tx_busy;
    logic tx_start;
    logic [7:0] tx_data;
    // raw RX signals (from uart_rx) vs FIFO/top-level signals
    logic [7:0] rx_raw_data;
    logic       rx_raw_dr;
    logic       rx_raw_parity_err;
    logic       rx_raw_framing_err;
    logic       rx_raw_break_int;
    logic [15:0] divisor;
    logic [1:0] data_bits;
    logic parity_en;
    logic parity_type;
    logic stop_bits;
    logic tx_start_tx;
    logic thre_tx;

    logic [7:0] tx_fifo_dout;
    logic [4:0] tx_fifo_count;
    logic       tx_fifo_empty;
    logic       tx_fifo_full;
    logic       tx_fifo_push;
    logic       tx_fifo_pop;
    logic       tx_fifo_clear;

    logic [10:0] rx_fifo_in;
    logic [10:0] rx_fifo_dout;
    logic [4:0]  rx_fifo_count;
    logic        rx_fifo_empty;
    logic        rx_fifo_full;
    logic        rx_fifo_push;
    logic        rx_fifo_pop;
    logic        rx_fifo_clear;
    
    logic [7:0]  rx_fifo_data;
    logic        rx_fifo_pe;
    logic        rx_fifo_fe;
    logic        rx_fifo_bi;
    logic        cts_meta, cts_sync;
    logic        dsr_meta, dsr_sync;
    logic        ri_meta,  ri_sync;
    logic        dcd_meta, dcd_sync;

    // TX FIFO controls
    assign tx_start_tx   = (!tx_busy) && (!tx_fifo_empty) && (divisor != 0);
    assign tx_fifo_push  = tx_start;
    assign tx_fifo_pop   = tx_start_tx;

    assign thre = tx_fifo_empty;
    assign temt = tx_fifo_empty && !tx_busy;

    // RX: use raw rx signals from uart_rx to push into FIFO
    assign rx_fifo_push = rx_raw_dr && !rx_fifo_full;
    assign rx_fifo_in = {rx_raw_break_int, rx_raw_framing_err, rx_raw_parity_err, rx_raw_data};

    // Overrun and error signaling for regs
    logic oe_set;
    logic err_set;
    assign oe_set = rx_raw_dr && rx_fifo_full; // new char while FIFO full
    assign err_set = rx_fifo_push && (rx_raw_parity_err || rx_raw_framing_err || rx_raw_break_int);

    // Unpack FIFO top for status/LSR
    assign rx_fifo_data = rx_fifo_dout[7:0];
    assign rx_fifo_pe   = rx_fifo_dout[8];
    assign rx_fifo_fe   = rx_fifo_dout[9];
    assign rx_fifo_bi   = rx_fifo_dout[10];

    // Export FIFO-level DR and error outputs
    assign dr           = !rx_fifo_empty;
    assign framing_err  = rx_fifo_fe;
    assign parity_err   = rx_fifo_pe;
    assign break_int    = rx_fifo_bi;

    uart_fifo #(.WIDTH(8), .DEPTH(16)) tx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_data),
        .push(tx_fifo_push),
        .pop(tx_fifo_pop),
        .clear(tx_fifo_clear),
        .data_out(tx_fifo_dout),
        .empty(tx_fifo_empty),
        .full(tx_fifo_full),
        .count(tx_fifo_count)
    );

    uart_fifo #(.WIDTH(11), .DEPTH(16)) rx_fifo(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(rx_fifo_in),
        .push(rx_fifo_push),
        .pop(rx_fifo_pop),
        .clear(rx_fifo_clear),
        .data_out(rx_fifo_dout),
        .empty(rx_fifo_empty),
        .full(rx_fifo_full),
        .count(rx_fifo_count)
    );



    // regs: connect FIFO control/status and raw RX info
    logic loopback_en;

    // Synchronize external modem inputs, then optionally loop them back from outputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cts_meta <= 1'b0;
            cts_sync <= 1'b0;
            dsr_meta <= 1'b0;
            dsr_sync <= 1'b0;
            ri_meta   <= 1'b0;
            ri_sync   <= 1'b0;
            dcd_meta  <= 1'b0;
            dcd_sync  <= 1'b0;
        end else begin
            cts_meta <= cts_in;
            cts_sync <= cts_meta;
            dsr_meta <= dsr_in;
            dsr_sync <= dsr_meta;
            ri_meta   <= ri_in;
            ri_sync   <= ri_meta;
            dcd_meta  <= dcd_in;
            dcd_sync  <= dcd_meta;
        end
    end

    wire modem_cts = loopback_en ? rts  : cts_sync;
    wire modem_dsr = loopback_en ? dtr  : dsr_sync;
    wire modem_ri  = loopback_en ? out1 : ri_sync;
    wire modem_dcd = loopback_en ? out2 : dcd_sync;

    uart_regs regs (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .wdata(wdata),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .rdata(rdata),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .rx_data(rx_raw_data),
        .dr(dr),
        .thre(thre),
        .temt(temt),
        .framing_err(framing_err),
        .parity_err(parity_err),
        .break_int(break_int),
        .divisor(divisor),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .stop_bits(stop_bits),
        .tx_fifo_full(tx_fifo_full),
        .oe_set(oe_set),
        .err_set(err_set),
        .rx_fifo_data(rx_fifo_data),
        .rx_fifo_pop(rx_fifo_pop),
        .tx_fifo_clear(tx_fifo_clear),
        .rx_fifo_clear(rx_fifo_clear),
        .irq(irq),
        .dtr(dtr),
        .rts(rts),
        .out1(out1),
        .out2(out2),
        .loopback_en(loopback_en),
        .cts_in(modem_cts),
        .dsr_in(modem_dsr),
        .ri_in(modem_ri),
        .dcd_in(modem_dcd)
    );

    uart_rx rx (
        .clk(clk),
        .rst_n(rst_n),
        .divisor(divisor),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .stop_bits(stop_bits),
        .rx_in(loopback_en ? tx_out : rx_in),
        .rx_data(rx_raw_data),
        .dr(rx_raw_dr),
        .framing_err(rx_raw_framing_err),
        .parity_err(rx_raw_parity_err),
        .break_int(rx_raw_break_int)
    );

    uart_tx tx (
        .clk(clk),
        .rst_n(rst_n),
        .divisor(divisor),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .stop_bits(stop_bits),
        .tx_data(tx_fifo_dout),
        .tx_start(tx_start_tx),
        .tx_out(tx_out),
        .tx_busy(tx_busy),
        .thre(thre_tx)
    );


endmodule : uart_top