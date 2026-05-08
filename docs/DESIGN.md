# UART Controller Design Specification

## Register Map

| Addr | Name (DLAB=0) | Name (DLAB=1) | R/W | Bits        | Description                                   |
| ---- | ------------- | ------------- | --- | ----------- | --------------------------------------------- |
| 0    | RBR           | DLL           | R/W | [7:0]       | RX Buffer / Divisor Latch Low                 |
| 1    | IER           | DLH           | R/W | [3:0]/[7:0] | Interrupt Enable / Divisor Latch High         |
| 2    | IIR           | FCR           | R/W | [3:1]       | Interrupt ID / FIFO Control                   |
| 3    | LCR           | LCR           | R/W | [7:0]       | Line Control (word length, stop bits, parity) |
| 4    | MCR           | MCR           | R/W | [4:0]       | Modem Control                                 |
| 5    | LSR           | LSR           | R/O | [7:0]       | Line Status                                   |
| 6    | MSR           | MSR           | R/O | [7:0]       | Modem Status                                  |

### Register Details

#### RBR (Receive Buffer Register) — Address 0, Read-Only (when DLAB=0)
```
Bit [7:0]: Received data byte
```
Holds the oldest byte from the RX FIFO.

#### DLL (Divisor Latch Low) — Address 0, Read/Write (when DLAB=1)
```
Bit [7:0]: Divisor low byte
```
Used to set baud rate: `CLK_FREQ / (16 * DIVISOR) = BAUD_RATE`

#### IER (Interrupt Enable) — Address 1, Read/Write (when DLAB=0)
```
Bit [0]: RX Data Available interrupt enable
Bit [1]: TX FIFO Empty interrupt enable
Bit [2]: Line Status (parity/frame error) interrupt enable
Bit [3]: Modem Status interrupt enable
```

#### DLH (Divisor Latch High) — Address 1, Read/Write (when DLAB=1)
```
Bit [7:0]: Divisor high byte
```
High byte of 16-bit baud rate divisor.

#### IIR (Interrupt Identification Register) — Address 2, Read-Only
```
Bit [0]: Interrupt pending (0=pending, 1=not pending)
Bit [3:1]: Interrupt ID:
  - 000: Modem Status
  - 001: TX FIFO Empty (THRE)
  - 010: RX Data Available
  - 011: Line Status (parity/frame error)
```

Priority (highest to lowest):
1. **Line Status (011)** — Parity error, framing error, break detected
2. **RX Data (010)** — FIFO has data to read
3. **THRE (001)** — TX FIFO empty
4. **Modem (000)** — CTS/DSR/RI/DCD change

#### FCR (FIFO Control Register) — Address 2, Write-Only
```
Bit [0]: FIFO enable
Bit [1]: Clear RX FIFO
Bit [2]: Clear TX FIFO
Bit [3]: DMA mode select
```

#### LCR (Line Control Register) — Address 3, Read/Write
```
Bit [1:0]: Word length:
  - 00: 5 bits
  - 01: 6 bits
  - 10: 7 bits
  - 11: 8 bits
Bit [2]: Stop bits:
  - 0: 1 stop bit
  - 1: 1.5 or 2 stop bits
Bit [3]: Parity enable
Bit [4]: Even parity select (0=odd, 1=even)
Bit [5]: Stick parity
Bit [6]: Break enable
Bit [7]: Divisor Latch Access Bit (DLAB)
```

#### MCR (Modem Control Register) — Address 4, Read/Write
```
Bit [0]: DTR (Data Terminal Ready)
Bit [1]: RTS (Request To Send)
Bit [2]: OUT1 (auxiliary output 1)
Bit [3]: OUT2 (auxiliary output 2)
Bit [4]: LOOPBACK (0=normal, 1=loopback mode)
```

In loopback mode (MCR[4]=1):
- RTS → CTS (loopback)
- DTR → DSR (loopback)
- OUT1 → RI (loopback)
- OUT2 → DCD (loopback)

#### LSR (Line Status Register) — Address 5, Read-Only
```
Bit [0]: Data Ready (DR) — RX FIFO has data
Bit [1]: Overrun Error (OE) — RX FIFO overflow
Bit [2]: Parity Error (PE) — Invalid parity detected
Bit [3]: Framing Error (FE) — Missing stop bit
Bit [4]: Break Interrupt (BI) — Break signal detected
Bit [5]: TX FIFO Empty (THRE) — All data transmitted
Bit [6]: TX Complete (TEMT) — TX shift register empty
```

#### MSR (Modem Status Register) — Address 6, Read-Only
```
Bit [0]: Delta Clear-To-Send (DCTS) — CTS changed since last read
Bit [1]: Delta Data-Set-Ready (DDSR) — DSR changed since last read
Bit [2]: Trailing Edge Ring Indicator (TERI) — RI falling edge
Bit [3]: Delta Data-Carrier-Detect (DDCD) — DCD changed since last read
Bit [4]: Clear-To-Send (CTS) — Current CTS state
Bit [5]: Data-Set-Ready (DSR) — Current DSR state
Bit [6]: Ring Indicator (RI) — Current RI state
Bit [7]: Data-Carrier-Detect (DCD) — Current DCD state
```

**Delta bits [3:0]:** Latch on modem input change, clear on read.

## Architecture

### Top-Level Hierarchy
```
uart_top
├── uart_regs (register file + interrupt controller)
├── uart_tx (transmitter + TX FIFO)
├── uart_rx (receiver + RX FIFO)
└── [External modem inputs with 2-stage FF synchronizers]
```

### FIFO
- **Depth:** 16 bytes
- **Type:** Dual-clock (1 read port, 1 write port)
- **Occupancy:** Tracked via full/empty flags

### Baud Rate Generator
- **Divisor:** 16-bit (1 to 65535)
- **Baud:** `CLK_FREQ / (16 * DIVISOR)`
- Example: 50 MHz clock, divisor=325 → 9,615 baud

### Parity & Data Framing
- Configurable word length: 5-8 bits
- Configurable stop bits: 1 or 1.5/2
- Configurable parity: none, even, odd, stick

### Modem Control
- **Outputs:** DTR, RTS, OUT1, OUT2
- **Inputs (external):** CTS, DSR, RI, DCD
- **Loopback:** MCR[4]=1 routes outputs → inputs
- **Synchronization:** 2-stage FF prevents metastability

### Interrupt Priority Encoder
- Highest: Line Status (parity/frame error)
- Mid-high: RX Data Available
- Mid-low: TX FIFO Empty
- Lowest: Modem Status

### External Modem Input Synchronization
2-stage flip-flop synchronizers on all external modem inputs to prevent metastability:
```
cts_in → [FF] → [FF] → cts_sync (used in MSR logic)
dsr_in → [FF] → [FF] → dsr_sync
ri_in  → [FF] → [FF] → ri_sync
dcd_in → [FF] → [FF] → dcd_sync
```

## Test Coverage

| Feature                   | Tested | Status |
| ------------------------- | ------ | ------ |
| TX data transmission      | ✅ Yes  | ✅ Pass |
| RX data reception         | ✅ Yes  | ✅ Pass |
| FIFO overflow             | ✅ Yes  | ✅ Pass |
| Framing error detection   | ✅ Yes  | ✅ Pass |
| Baud rate divisor         | ✅ Yes  | ✅ Pass |
| Modem control (MCR)       | ✅ Yes  | ✅ Pass |
| Modem loopback            | ✅ Yes  | ✅ Pass |
| External modem inputs     | ✅ Yes  | ✅ Pass |
| Interrupt enable (IER)    | ✅ Yes  | ✅ Pass |
| Interrupt priority (IIR)  | ✅ Yes  | ✅ Pass |
| Modem status deltas (MSR) | ✅ Yes  | ✅ Pass |

---

**Specification Version:** 1.0  
**Last Updated:** May 9, 2026
