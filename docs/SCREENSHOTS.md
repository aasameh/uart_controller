# Screenshots for UART Controller Documentation

Add your annotated screenshots here. Suggested captures:

## Test Evidence (from ModelSim Waveforms)

### 1. test3_framing_error.png
- **Caption:** "Framing Error Detection: Stop Bit = 0 Triggers LSR[4]"
- **Elements to circle:**
  - RX data frame with bad stop bit (0 instead of 1)
  - LSR register showing FE=1 (bit 4)
  - RBR with correct received data (0x55)
- **Location in test:** @ 2555 ns LSR read

### 2. test4_loopback_initial.png
- **Caption:** "Modem Loopback Mode: All Outputs Loop to Status (MCR=0x1F → MSR=0xFF)"
- **Elements to circle:**
  - MCR value written: 0x1F (all bits set including LOOPBACK)
  - MSR value read: 0xFF (all status bits asserted)
  - Signal path: DTR→DSR, RTS→CTS, OUT1→RI, OUT2→DCD
- **Location in test:** @ 2675 ns MSR loopback read

### 3. test4_delta_clear.png
- **Caption:** "Delta Bits Clear on MSR Read: Second Read Shows 0xF0 (Upper Nibble Only)"
- **Elements to circle:**
  - First MSR read: 0xFF (with delta bits)
  - Second MSR read: 0xF0 (deltas cleared)
  - Verify no input changes between reads
- **Location in test:** @ 2695 ns

### 4. test4_external_inputs.png
- **Caption:** "External Modem Inputs Synchronized: CTS=1, DSR=0, RI=1, DCD=0 → MSR=0x5A"
- **Elements to circle:**
  - External input signals: cts_in, dsr_in, ri_in, dcd_in values
  - 2-stage FF synchronizers settling
  - MSR value: 0x5A (expected = actual, stable)
  - **Note:** Bug was 0x5F (glitchy), fixed by setting inputs before disabling loopback
- **Location in test:** @ 2815 ns

### 5. test4_modem_interrupt.png
- **Caption:** "Modem Interrupt: IER[3]=1, CTS Edge Triggers IIR=0xC0, IRQ=1"
- **Elements to circle:**
  - IER value: 0x08 (bit 3 = modem interrupt enable)
  - CTS edge transition (1 → 0 transition in waveform)
  - IIR value: 0xC0 (pending=1, id=000=modem source, lowest priority)
  - IRQ signal: goes high when interrupt asserts
- **Location in test:** @ 2955 ns

### 6. test4_cts_delta.png
- **Caption:** "CTS Delta Captured: After CTS Edge, MSR Shows DCTS=1 (0x51)"
- **Elements to circle:**
  - CTS signal: previous toggle visible in history
  - MSR value: 0x51 (bits [7:4]=0101 with DCTS=1)
  - Delta bit [0]: =1 (captured the CTS change)
- **Location in test:** @ 2975 ns

## Overall Test Summary (Transcript Evidence)

### final_score.png
- **Caption:** "Final Verification Results: 5 PASS / 0 FAIL (All Tests Green)"
- **Elements to circle:**
  - FINAL SCORE line from transcript: "5 PASS / 0 FAIL"
  - STATUS_MATCH lines (x5) showing all register comparisons passed
  - No STATUS_MISMATCH or UVM_ERROR messages
- **Location:** Bottom of test output

---

## Optional: Waveform Captures

### waveform_tx_rx_data.png
- TX data output, RX data input, FIFO occupancy signals
- Shows clean data transmission/reception

### waveform_modem_control.png
- MCR bits (dtr, rts, out1, out2, loopback control)
- DTR, RTS, OUT1, OUT2 outputs
- CTS, DSR, RI, DCD inputs (looped and external)

### waveform_synchronizers.png
- External modem inputs: cts_in, dsr_in, ri_in, dcd_in (raw, noisy)
- Synchronized outputs: cts_sync, dsr_sync, ri_sync, dcd_sync (clean 2-stage FF delay)

### waveform_interrupt.png
- IER, IIR, IRQ signals
- Interrupt enable, ID, and IRQ output pulse

---

## How to Capture from ModelSim

1. Run simulation: `vsim -do run_uart.do`
2. After test completes, use **File → Print** to export waveform
3. Or use **View → Print** on specific signals
4. Annotate with circles, boxes, and captions in:
   - Paint
   - Photoshop
   - Preview (macOS)
   - Any image editor
5. Save as PNG in this `screenshots/` folder

---

**Note:** All 6 test evidence files above correspond directly to the 5 STATUS_MATCH + 6 driver PASS assertions in the test transcript.
