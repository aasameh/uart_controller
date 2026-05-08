# UART Controller Documentation

## Quick Links

- **[TEST_RESULTS.md](TEST_RESULTS.md)** — Final simulation results (5/5 PASS)
- **[DESIGN.md](DESIGN.md)** — Register map, architecture, modem control
- **[VERIFICATION.md](VERIFICATION.md)** — Test methodology & UVM structure
- **screenshots/** — Annotated test evidence & waveforms

## Key Facts

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

## Run Simulation

```powershell
cd c:\college\6th\projects\uart_controller
C:\intelFPGA\20.1\modelsim_ase\win32aloem\vsim.exe -c -do run_uart.do
```

Or create an alias:
```powershell
Set-Alias vsim 'C:\intelFPGA\20.1\modelsim_ase\win32aloem\vsim.exe'
vsim -c -do run_uart.do
```

## Next Steps

1. **Synthesis** → Quartus/Vivado RTL → netlists
2. **GDSII** → place & route
3. **Validation** → timing analysis, power estimation
4. **Documentation** → Add your annotated screenshots to `screenshots/`

---

Generated: May 9, 2026
