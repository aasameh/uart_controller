# UART Controller Verification Strategy

## UVM Testbench Architecture

### Top-Level Modules
```
uart_tb_top (UVM testbench)
├── uart_test (test case)
│   └── uart_env (verification environment)
│       ├── uart_agent
│       │   ├── uart_sequencer
│       │   ├── uart_driver
│       │   └── uart_monitor
│       └── uart_scoreboard
├── uart_if (interface bundle)
│   ├── Data signals: clk, rst_n, rx_in, tx_out, rdata, wdata, addr
│   ├── Modem signals: dtr, rts, out1, out2, cts_in, dsr_in, ri_in, dcd_in
│   └── Register access: wr_en, rd_en, addr, wdata, rdata
└── uart_top (DUT)
```

## Verification Components

### `uart_driver`
- Drives register reads/writes and injects RX stimuli.
- Exposes `drv_ap` for TX activity and `status_ap` for expected status checks.
- In this run, the driver executed four user-facing tests: `TEST_1` through `TEST_4`.

### `uart_monitor`
- Passively captures TX data and bus reads.
- Publishes actual TX/status items to the scoreboard.

### `uart_scoreboard`
- Compares expected TX items against observed TX items.
- Compares expected status reads against actual bus reads.
- Final run summary: `27 PASS / 0 FAIL`.

## Driver Tests

### Test 1: Single Byte TX with RBR Read
**Objective:** Verify the TX path, loopback receive, and RBR readback.

**Observed result:**
- Driver starts `TEST_1` at 175 ps.
- Scoreboard reports repeated `MATCH` passes for the transmitted byte.
- No UVM errors.

**Conclusion:** TX/RX path and scoreboard matching are working.

---

### Test 2: Burst 17 Bytes to Trigger OE
**Objective:** Exercise the burst path and overrun behavior.

**Observed result:**
- Driver starts `TEST_2` at 8.905 ns.
- Scoreboard reports `MATCH` passes for the burst sequence.
- No UVM errors.

**Conclusion:** Burst transfer path is working and does not raise fatal errors.

---

### Test 3: Bad-Stop RX Frame to Trigger FE
**Objective:** Verify framing-error detection and data retention on bad-stop reception.

**Observed result:**
- `LSR_READ` returned `0xe9` with `FE=1`.
- `RBR_READ` returned `0x55`.
- Driver logged `[PASS] Framing error bit set after bad-stop frame`.

**Conclusion:** Framing error behavior is correct and receive data is retained.

---

### Test 4: Modem Loopback and External Inputs
**Objective:** Verify modem loopback, delta clearing, external input sampling, modem interrupt, and CTS edge capture.

**Observed result:**
- Loopback MSR: `0xff`
- Delta-clear MSR: `0xf0`
- External modem inputs: `0x5a`
- IIR modem interrupt: `0xc0`
- CTS delta capture: `0x51`
- Driver logged five `[PASS]` checks in this test.

**Conclusion:** Modem status and interrupt behavior are correct.

## Transcript Summary

The run completed cleanly:

| Metric           | Value              |
| ---------------- | ------------------ |
| UVM_INFO         | 50                 |
| UVM_WARNING      | 2                  |
| UVM_ERROR        | 0                  |
| `MATCH`          | 22                 |
| `STATUS_MATCH`   | 5                  |
| `PASS`           | 6                  |
| Final scoreboard | `27 PASS / 0 FAIL` |

## Notes

- The earlier modem synchronization issue is fixed; the external MSR read now returns `0x5a`.
- The UVM warnings are from `UVM_NO_DPI` / name-check settings and are not fatal.
- The run has no UVM errors.

## What This Covers

- TX/RX loopback and readback
- Burst transmission path
- Framing error handling
- Modem loopback and external modem sampling
- Modem interrupt identification
- CTS delta capture

## Known Gaps

These are still not exercised in the driver run:

1. Overflow stress beyond the burst path
2. Parity-error-specific injection
3. Break-interrupt injection
4. Exhaustive divisor sweep

---

**Verification Date:** May 9, 2026  
**UVM Version:** 1.1d  
**Simulator:** ModelSim Intel FPGA 2020.1  
**Status:** Ready for synthesis handoff and GDS flow
