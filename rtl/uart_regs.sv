module uart_regs (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [2:0]  addr,
  input  logic [7:0]  wdata,
  input  logic        wr_en,
  input  logic        rd_en,
  output logic [7:0]  rdata,

  // Status inputs from TX/RX
  input  logic        dr,
  input  logic        thre,
  input  logic        temt,
  input  logic        framing_err,
  input  logic        parity_err,
  input  logic        break_int,
  input logic [7:0] rx_data, 

  // Config outputs to TX/RX
  output logic       tx_start,
  output logic [7:0] tx_data,
  output logic [15:0] divisor,
  output logic [1:0]  data_bits,
  output logic        parity_en,
  output logic        parity_type,
  output logic        stop_bits
);

  // Internal registers
  logic [7:0]  lcr;        // Line Control Register
  logic [7:0]  dll;        // Divisor Latch Low
  logic [7:0]  dlh;        // Divisor Latch High
  logic [15:0] divisor_reg;
  logic        oe;         // Overrun Error — latched internally
  logic        dr_prev;    // Previous DR for edge detection

  wire dlab = lcr[7];
  assign divisor    = divisor_reg;
  assign data_bits  = lcr[1:0];
  assign stop_bits  = lcr[2];
  assign parity_en  = lcr[3];
  assign parity_type = lcr[4];  // 0=odd, 1=even

  // OE detection: dr was already high when new dr arrived
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dr_prev <= 1'b0;
      oe      <= 1'b0;
    end else begin
      dr_prev <= dr;
      // Rising edge of dr while previous dr still set = overrun
      if (dr && dr_prev)
        oe <= 1'b1;
      // Clear OE when LSR is read
      else if (rd_en && addr == 3'h5)
        oe <= 1'b0;
    end
  end

  // LSR assembled from status signals — read only
  // [7]=ERR [6]=TEMT [5]=THRE [4]=BI [3]=FE [2]=PE [1]=OE [0]=DR
  wire err_ind = oe | parity_err | framing_err | break_int;
  wire [7:0] lsr = {err_ind, temt, thre, break_int, framing_err, parity_err, oe, dr};

  // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        // initialize on reset
        // 
    if (!rst_n) begin
        lcr      <= 8'h03;
      dll      <= 8'd0;
      dlh      <= 8'h00;
      divisor_reg <= 16'h0000;
        tx_data  <= 8'h00;
        tx_start <= 1'b0;
    end else begin
        tx_start <= 1'b0;  // default — pulse only on THR write
        if (wr_en) begin
        case (addr)
        3'h0: if (!dlab) begin tx_data <= wdata; tx_start <= 1'b1; end
          else begin
            dll <= wdata;
            divisor_reg <= {dlh, wdata};
          end
            3'h1: if (dlab) dlh <= wdata;
            3'h3: lcr <= wdata;
            default: ;
        endcase
        end
    end
    end

  // Read logic
  always_comb begin
    rdata = 8'h00;
    if (rd_en) begin
      case (addr)
        3'h0: rdata = dlab ? dll : rx_data;  // RBR not implemented
        3'h1: rdata = dlab ? dlh : 8'h00;  // IER not implemented
        3'h3: rdata = lcr;
        3'h5: rdata = lsr;
        default: rdata = 8'h00;
      endcase
    end
  end

endmodule