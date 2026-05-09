# UART Controller Documentation

## Quick Links

- **[TEST_RESULTS.md](TEST_RESULTS.md)** — Final simulation results
- **[DESIGN.md](DESIGN.md)** — Register map, architecture, modem control
- **[VERIFICATION.md](VERIFICATION.md)** — Test methodology & UVM structure
- **screenshots/** — Annotated test evidence & waveforms

## Features

| Feature               | Status                                 |
| --------------------- | -------------------------------------- |
| TX/RX Data Path       | ✅ Working                              |
| 16-byte FIFOs         | ✅ Working                              |
| Baud Rate Divisor     | ✅ Functional (1-65535)                 |
| Modem Control (MCR)   | ✅ Working (DTR/RTS/OUT1/OUT2/LOOPBACK) |
| Modem Status (MSR)    | ✅ Working (CTS/DSR/RI/DCD + deltas)    |
| Interrupt Controller  | ✅ Working (IER/IIR + priority)         |
| Loopback Mode         | ✅ Working (MCR[4]=1)                   |
| External Modem Inputs | ✅ Stable (2-stage FF)                  |

Generated: May 9, 2026
