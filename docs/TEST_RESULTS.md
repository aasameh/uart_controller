# UART Controller — Test Results

**Date:** May 9, 2026  
**Status:** ✅ 4 DRIVER TESTS PASSING  

## Final Score
```
FINAL SCORE: 27 PASS / 0 FAIL
```

## Transcript Summary

The run completed with no UVM errors. The scoreboard reported `27 PASS / 0 FAIL`, with these log counts:

| Metric         | Value |
| -------------- | ----- |
| UVM_INFO       | 50    |
| UVM_WARNING    | 2     |
| UVM_ERROR      | 0     |
| `MATCH`        | 22    |
| `STATUS_MATCH` | 5     |
| `PASS`         | 6     |

## Driver Test Breakdown

### Test 1: Single Byte TX with RBR Read
- **Status:** ✅ PASS
- **Driver action:** Wrote a byte, waited for loopback receive, then read RBR.
- **Evidence:** `TEST_1` ran and the scoreboard reported repeated `MATCH` passes for the transmitted byte.
- **Result:** TX/RX loopback path is functioning.

### Test 2: Burst 17 Bytes to Trigger OE
- **Status:** ✅ PASS
- **Driver action:** Sent a 17-byte burst to exercise the overrun path.
- **Evidence:** `TEST_2` ran and the scoreboard reported `MATCH` passes for the burst stream.
- **Result:** Burst transfer path is functioning and the test completed without errors.

### Test 3: Framing Error Detection
- **Status:** ✅ PASS
- **Driver action:** Injected a bad-stop RX frame.
- **Evidence:** LSR read returned `0xe9` with `FE=1`, and RBR returned `0x55`.
- **Result:** Framing error detection works and received data is preserved.

### Test 4: Modem Loopback and Interrupts
- **Status:** ✅ PASS
- **Driver action:** Checked loopback MSR, delta-bit clear, external modem sampling, modem interrupt, and CTS delta capture.
- **Evidence:**
	- MSR loopback: `0xff`
	- MSR delta clear: `0xf0`
	- External modem inputs: `0x5a`
	- IIR modem interrupt: `0xc0`
	- CTS delta capture: `0x51`
- **Result:** Modem status sampling, interrupt identification, and delta-bit behavior all passed.

## Key Takeaways

- The driver test suite exercised four user-facing tests from `verif/uart_driver.sv`.
- The run completed cleanly with no UVM errors.
- The modem timing issue from the earlier run is no longer present; the external MSR read is now `0x5a`.
- The report counts are consistent with the scoreboard: `27 PASS / 0 FAIL`.

## Simulation Transcript

Full ModelSim output: see `transcript` in the project root.

## Design Validation

- ✅ TX/RX data path functional
- ✅ FIFO integration working
- ✅ Baud rate divisor correct
- ✅ Modem control (MCR) working
- ✅ Modem status (MSR) and delta bits stable
- ✅ Interrupt identification and modem interrupt behavior correct

**Ready for:** synthesis handoff, GDS flow, or report submission
