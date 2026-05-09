module uart_regs (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [2:0]  addr,
  input  logic [7:0]  wdata,
  input  logic        wr_en,
  input  logic        rd_en,
  output logic [7:0]  rdata,
  output logic        irq,

  // Status inputs from TX/RX
  input  logic        dr,
  input  logic        thre,
  input  logic        temt,
  input  logic        framing_err,
  input  logic        parity_err,
  input  logic        break_int,
  input  logic [7:0]  rx_data,
  input  logic        tx_fifo_full,
  input  logic        oe_set,
  input  logic        err_set,
  input logic [7:0]   rx_fifo_data,

  // modem control/status
  output logic dtr,
  output logic rts,
  output logic out1,
  output logic out2,
  output logic loopback_en,
  input logic cts_in,
  input logic dsr_in,
  input logic ri_in,
  input logic dcd_in,

  // Config outputs to TX/RX
  output logic       tx_start,
  output logic [7:0] tx_data,
  output logic [15:0] divisor,
  output logic [1:0]  data_bits,
  output logic        parity_en,
  output logic        parity_type,
  output logic        stop_bits,
  output logic        rx_fifo_pop,
  output logic        tx_fifo_clear,
  output logic        rx_fifo_clear
);

  // Internal registers
  logic [7:0]  lcr;        // Line Control Register
  logic [7:0]  dll;        // Divisor Latch Low
  logic [7:0]  dlh;        // Divisor Latch High
  logic [15:0] divisor_reg;
  logic        oe;         // Overrun Error — latched internally
  logic        err_pending;
  logic [7:0]  fcr;        // FIFO Control Register
  logic [7:0]  ier;        // Interrupt Enable Register
  logic [7:0]  mcr_reg;        // Modem Control Register (loopback only)
  logic [3:0]  msr_inputs, msr_prev, msr_delta;
  logic [3:0]  new_inputs;
  logic [2:0]  int_id;
  logic        int_pending;
  logic        line_status_irq;
  logic        recv_data_irq;
  logic        thre_irq;
  logic        modem_irq;
  
  wire dlab = lcr[7];

  assign divisor    = divisor_reg;
  assign data_bits  = lcr[1:0];
  assign stop_bits  = lcr[2];
  assign parity_en  = lcr[3];
  assign parity_type = lcr[4];  // 0=odd, 1=even
  assign dtr = mcr_reg[0];
  assign rts = mcr_reg[1];
  assign out1 = mcr_reg[2];
  assign out2 = mcr_reg[3];
  assign loopback_en = mcr_reg[4];

  // Interrupt priority: line status > received data > THRE > modem status
  // IIR: bit0=0 when any interrupt is pending, 1 when none.
  always_comb begin
    line_status_irq = ier[2] && (oe | err_pending);
    recv_data_irq   = ier[0] && dr;
    thre_irq        = ier[1] && thre;
    modem_irq       = ier[3] && (|msr_delta);

    int_pending = 1'b0;
    int_id = 3'b000;

    if (line_status_irq) begin
      int_pending = 1'b1;
      int_id = 3'b011;
    end else if (recv_data_irq) begin
      int_pending = 1'b1;
      int_id = 3'b010;
    end else if (thre_irq) begin
      int_pending = 1'b1;
      int_id = 3'b001;
    end else if (modem_irq) begin
      int_pending = 1'b1;
      int_id = 3'b000;
    end
  end

  // Register IRQ to ensure a defined value after reset and avoid X propagation
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      irq <= 1'b0;
    else
      irq <= int_pending;
  end

  // OE detection: set when RX FIFO is full and a new character arrives
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      oe      <= 1'b0;
    end else begin
      if (oe_set)
        oe <= 1'b1;
      // Clear OE when LSR is read
      else if (rd_en && addr == 3'h5)
        oe <= 1'b0;
    end
  end

  // Error indicator latch (bit7): set on any error push, clear on LSR read
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      err_pending <= 1'b0;
    end else begin
      if (err_set)
        err_pending <= 1'b1;
      else if (rd_en && addr == 3'h5)
        err_pending <= 1'b0;
    end
  end

  // LSR assembled from status signals — read only
  // [7]=ERR [6]=TEMT [5]=THRE [4]=BI [3]=FE [2]=PE [1]=OE [0]=DR
  wire err_ind = oe | err_pending | parity_err | framing_err | break_int;
  wire [7:0] lsr = {err_ind, temt, thre, break_int, framing_err, parity_err, oe, dr};

  // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lcr      <= 8'h03;
      dll      <= 8'd0;
      dlh      <= 8'h00;
      divisor_reg <= 16'h0000;
      fcr      <= 8'hC0;
      ier      <= 8'h00;
      mcr_reg      <= 8'h00;
      msr_inputs <= 4'b0000;
      msr_prev   <= 4'b0000;
      msr_delta <= 4'b0000;
      tx_data  <= 8'h00;
      tx_start <= 1'b0;
      rx_fifo_pop   <= 1'b0;
      tx_fifo_clear <= 1'b0;
      rx_fifo_clear <= 1'b0;
    end else begin
        tx_start <= 1'b0;
        rx_fifo_pop   <= 1'b0;
        tx_fifo_clear <= 1'b0;
        rx_fifo_clear <= 1'b0;
        if (wr_en) begin
        case (addr)
        3'h0: if (!dlab) begin
                  if (!tx_fifo_full) begin
                    tx_data <= wdata;
                    tx_start <= 1'b1;
                  end
                end else begin
                  dll <= wdata;
                  divisor_reg <= {dlh, wdata};
                end
            3'h1: if (dlab) dlh <= wdata;
              else ier <= {4'b0000, wdata[3:0]};
            3'h2: if (!dlab) begin
                    fcr <= wdata;
                    if (wdata[1]) rx_fifo_clear <= 1'b1;
                    if (wdata[2]) tx_fifo_clear <= 1'b1;
                  end
            3'h3: lcr <= wdata;
            3'h4: if   (!dlab) mcr_reg <= wdata;
            default: ;
        endcase
        end
        if (rd_en && addr == 3'h0 && !dlab && dr)
          rx_fifo_pop <= 1'b1;
    end
    end



  // Read logic
  always_comb begin
    rdata = 8'h00;
    if (rd_en) begin
      case (addr)
        3'h0: rdata = dlab ? dll : rx_fifo_data;  // RBR or DLL
        3'h1: rdata = dlab ? dlh : ier;  // IER
        3'h3: rdata = lcr;
        3'h2: rdata = {2'b11, 2'b00, int_id, ~int_pending}; // IIR
        3'h4: rdata = mcr_reg;
        3'h5: rdata = lsr;
        // MSR: [7]=DCD [6]=RI [5]=DSR [4]=CTS [3]=DDCD [2]=TERI [1]=DDSR [0]=DCTS
        3'h6: rdata = { msr_inputs[3], msr_inputs[2], msr_inputs[1], msr_inputs[0],
                        msr_delta[3],  msr_delta[2],  msr_delta[1],  msr_delta[0] };
        default: rdata = 8'h00;
      endcase
    end
  end

  // Sample MSR inputs, latch deltas, and clear deltas synchronously on MSR read
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      msr_inputs <= 4'b0;
      msr_prev   <= 4'b0;
      msr_delta  <= 4'b0;
    end else begin
      new_inputs = {dcd_in, ri_in, dsr_in, cts_in};
      msr_delta <= msr_delta | (new_inputs ^ msr_prev);
      msr_prev  <= new_inputs;
      msr_inputs<= new_inputs;
      // clear delta bits synchronously when MSR is read (addr 3'h6)
      if (rd_en && addr == 3'h6)
        msr_delta <= 4'b0;
    end
  end

endmodule