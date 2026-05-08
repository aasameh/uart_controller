module uart_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic [WIDTH-1:0]   data_in,
    input  logic               push,
    input  logic               pop,
    input  logic               clear,
    output logic [WIDTH-1:0]   data_out,
    output logic               empty,
    output logic               full,
    output logic [$clog2(DEPTH+1)-1:0] count
);

    localparam int ADDR_W  = $clog2(DEPTH);
    localparam int COUNT_W = $clog2(DEPTH+1);

    logic [WIDTH-1:0] fifo [0:DEPTH-1];
    logic [ADDR_W-1:0] head, tail;
    logic              do_push;
    logic              do_pop;

    assign do_pop  = pop && !empty;
    assign do_push = push && (!full || do_pop);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            head <= 0;
            tail <= 0;
            count <= 0;
        end else if (clear) begin
            head <= 0;
            tail <= 0;
            count <= 0;
        end else begin
            case ({do_push, do_pop})
                2'b10: begin
                    fifo[tail] <= data_in;
                    tail <= tail + 1;
                    count <= count + 1;
                end
                2'b01: begin
                    head <= head + 1;
                    count <= count - 1;
                end
                2'b11: begin
                    fifo[tail] <= data_in;
                    tail <= tail + 1;
                    head <= head + 1;
                end
                default: ;
            endcase
        end
    end

    assign data_out = empty ? {WIDTH{1'b0}} : fifo[head];
    assign empty = (count == COUNT_W'(0));
    assign full = (count == COUNT_W'(DEPTH));

endmodule