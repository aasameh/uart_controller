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

    // Status outputs from RX/TX
    output logic dr,
    output logic thre,
    output logic temt,
    output logic framing_err,
    output logic parity_err,
    output logic break_int
);

    // Config outputs to RX/TX
    logic tx_busy;
    logic tx_start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
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
    

    assign tx_start_tx   = (!tx_busy) && (!tx_fifo_empty) && (divisor != 0);
    assign tx_fifo_push  = tx_start;
    assign tx_fifo_pop   = tx_start_tx;
    assign tx_fifo_clear = 1'b0;

    assign thre = tx_fifo_empty;
    assign temt = tx_fifo_empty && !tx_busy;

    uart_fifo tx_fifo (
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
        .rx_data(rx_data),
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
        .stop_bits(stop_bits)
    );

    uart_rx rx (
        .clk(clk),
        .rst_n(rst_n),
        .divisor(divisor),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .stop_bits(stop_bits),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .dr(dr),
        .framing_err(framing_err),
        .parity_err(parity_err),
        .break_int(break_int)
    );

    uart_tx tx (
        .clk(clk),
        .rst_n(rst_n),
        .divisor(divisor),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .stop_bits(stop_bits),
        // tx_data and tx_start would come from a higher-level module or testbench
        .tx_data(tx_fifo_dout),
        .tx_start(tx_start_tx),
        .tx_out(tx_out),
        .tx_busy(tx_busy),
        .thre(thre_tx)
    );


endmodule : uart_top