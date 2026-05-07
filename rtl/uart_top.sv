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

    logic thr_full;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)        thr_full <= 1'b0;
        else if (tx_start) thr_full <= 1'b1;
        else if (tx_busy) thr_full <= 1'b0;
    end
    assign temt = ~tx_busy & ~thr_full;

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
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_out(tx_out),
        .tx_busy(tx_busy),
        .thre(thre)
    );


endmodule : uart_top