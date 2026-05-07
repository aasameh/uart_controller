import uart_pkg::*;

module uart_tx (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [15:0] divisor,
  input  logic [1:0]  data_bits,
  input  logic        parity_en,
  input  logic        parity_type,
  input  logic        stop_bits,
  input  logic [7:0]  tx_data,
  input  logic        tx_start,
  output logic        tx_out,
  output logic        tx_busy,
  output logic        thre
);

  tx_state_t   state;
  logic [15:0] baud_cnt;
  logic        baud_tick;
  logic [7:0]  shift_reg;
  logic [2:0]  bit_cnt;
  logic        parity_bit;

  // Baud generator
  always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
          baud_cnt <= 0;
      else if (divisor == 0)
        baud_cnt <= 0;
      else if (state == TX_IDLE)
        baud_cnt <= 0;
      else if (baud_cnt == divisor - 1)
          baud_cnt <= 0;
      else
          baud_cnt <= baud_cnt + 1;
    end

    assign baud_tick = (divisor != 0) && (baud_cnt == divisor - 1);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= TX_IDLE;
      tx_out     <= 1'b1;
      tx_busy    <= 1'b0;
      thre       <= 1'b1;
      shift_reg  <= 8'b0;
      bit_cnt    <= 3'b000;
      parity_bit <= 1'b0;
    end else begin
      case (state)

        TX_IDLE: begin
          tx_out  <= 1'b1;
          tx_busy <= 1'b0;
          if (tx_start && (divisor != 0)) begin
            shift_reg  <= tx_data;
            parity_bit <= parity_type ? ~^tx_data : ^tx_data;
            state      <= TX_START;
          end
        end

        TX_START: begin
          tx_out  <= 1'b0;
          tx_busy <= 1'b1;
          if (baud_tick) begin
            tx_out  <= shift_reg[0];
            state   <= TX_DATA;
            bit_cnt <= 3'b000;
          end
        end

        TX_DATA: begin
          thre <= 1'b1;
          if (baud_tick) begin
            shift_reg <= shift_reg >> 1;
            bit_cnt   <= bit_cnt + 1;
            if (bit_cnt == data_bits + 4) begin
              tx_out <= parity_en ? parity_bit : 1'b1;
              state  <= parity_en ? TX_PARITY : TX_STOP;
              bit_cnt <= 3'b000;
            end else begin
              tx_out <= shift_reg[1];
            end
          end
        end

        TX_PARITY: begin
          tx_out <= parity_bit;
          if (baud_tick) begin
            bit_cnt <= 3'b000;
            state   <= TX_STOP;
          end
        end

        TX_STOP: begin
          tx_out <= 1'b1;
          if (baud_tick) begin
            bit_cnt <= bit_cnt + 1;
            if (!stop_bits || bit_cnt == 1) begin
              state   <= TX_IDLE;
              tx_busy <= 1'b0;
              thre    <= 1'b1;
            end
          end
        end

        default: state <= TX_IDLE;

      endcase
    end
  end

endmodule