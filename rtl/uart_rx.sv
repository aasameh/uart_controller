import uart_pkg::*;

module uart_rx (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [15:0] divisor,
  input  logic [1:0]  data_bits,
  input  logic        parity_en,
  input  logic        parity_type,
  input  logic        stop_bits,
  input  logic        rx_in,
  output logic [7:0]  rx_data,
  output logic        dr,
  output logic        framing_err,
  output logic        parity_err,
  output logic        break_int
);

  rx_state_t   state;
  logic [15:0] baud_cnt;
  logic [7:0]  shift_reg;
  logic [2:0]  bit_cnt;
  logic [3:0]  sample_cnt;
  logic        sample_tick;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) baud_cnt <= 0;
    else if (divisor == 0) baud_cnt <= 0;
    else if (baud_cnt == (divisor >> 4) - 1) baud_cnt <= 0;
    else baud_cnt <= baud_cnt + 1;
  end
  assign sample_tick = (divisor != 0) && (baud_cnt == (divisor >> 4) - 1);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state       <= RX_IDLE;
      dr          <= 1'b0;
      framing_err <= 1'b0;
      parity_err  <= 1'b0;
      break_int   <= 1'b0;
      rx_data     <= 8'b0;
      bit_cnt     <= 3'b000;
      sample_cnt  <= 4'b0;
      shift_reg   <= 8'b0;
    end else begin
      case (state)

        RX_IDLE: begin
          if (~rx_in) begin
            state       <= RX_START;
            sample_cnt  <= 0;
            dr          <= 1'b0;
            framing_err <= 1'b0;
            parity_err  <= 1'b0;
            break_int   <= 1'b0;
          end
        end

        RX_START: begin
          if (sample_tick) begin
            if (sample_cnt == 7) begin
              state      <= RX_CENTER;
              sample_cnt <= 0;
            end else
              sample_cnt <= sample_cnt + 1;
          end
        end

        RX_CENTER: begin
          if (sample_tick) begin
            if (rx_in == 1'b0) begin
              state      <= RX_DATA;
              sample_cnt <= 0;
              bit_cnt    <= 3'b000;
            end else
              state <= RX_IDLE;
          end
        end

        RX_DATA: begin
          if (sample_tick) begin
            if (sample_cnt == 15) begin
              sample_cnt <= 0;
              shift_reg  <= {rx_in, shift_reg[7:1]};
              bit_cnt    <= bit_cnt + 1;
              if (bit_cnt == data_bits + 3) begin
                state   <= parity_en ? RX_PARITY : RX_STOP;
                bit_cnt <= 3'b000;
              end
            end else
              sample_cnt <= sample_cnt + 1;
          end
        end

        RX_PARITY: begin
          if (sample_tick) begin
            if (sample_cnt == 15) begin
              sample_cnt <= 0;
              state      <= RX_STOP;
              if (rx_in != (parity_type ? ~^shift_reg : ^shift_reg))
                parity_err <= 1'b1;
            end else
              sample_cnt <= sample_cnt + 1;
          end
        end

        RX_STOP: begin
          if (sample_tick) begin
            if (sample_cnt == 15) begin
              sample_cnt <= 0;
              dr         <= 1'b1;
              rx_data    <= shift_reg;
              if (rx_in == 1'b0) begin
                framing_err <= 1'b1;
                if (shift_reg == 8'b0)
                  break_int <= 1'b1;
              end
              if (!stop_bits || bit_cnt == 1) begin
                state   <= RX_IDLE;
                bit_cnt <= 3'b000;
              end else
                bit_cnt <= bit_cnt + 1;
            end else
              sample_cnt <= sample_cnt + 1;
          end
        end

        default: state <= RX_IDLE;

      endcase
    end
  end

endmodule