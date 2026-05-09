# `uart_top` Physical Implementation Report

**Technology:** SKY130A · `sky130_fd_sc_hd`  
**Tool:** OpenLane v1.0.2 (ff5509f65b17bfa4068d5336495ab1718987ff69)  
**Synthesis:** Yosys 0.64+31  
**Run tag:** `uart_flow`  
**Total runtime:** 10m 12s (routing: 7m 11s)

---

## Flow Status

| Check | Result |
|---|---|
| Flow completion | ✅ Complete |
| Magic DRC | ✅ 0 violations |
| LVS | ✅ Clean (2198 nets matched) |
| Antenna (pin) | ✅ 0 violations |
| Antenna (net) | ✅ 0 violations |
| Setup timing | ✅ No violations |
| Hold timing | ✅ No violations |
| Max fanout | ⚠️ Violations present (see notes) |

---

## Area & Utilization

| Metric | Value |
|---|---|
| Die area | 0.053 mm² (214.36 × 212.16 µm) |
| Core area | 45,478.6 µm² |
| Cell utilization | 47.0% (target: 45%) |
| Cell density | 40,895 cells/mm² |
| Placement density | 0.5 |

---

## Cell Count

| Category | Count |
|---|---|
| Logic cells (post-synth) | 1,741 |
| Non-physical (logic) cells | 2,180 |
| Decap cells | 1,819 |
| Welltap cells | 640 |
| Fill cells | 948 |
| Diode cells | 7 |
| **Total cells** | **5,594** |

### Sequential Elements

| Cell type | Count |
|---|---|
| `sky130_fd_sc_hd__dfrtp_1` (DFF w/ reset) | 163 |
| `sky130_fd_sc_hd__edfxtp_1` (DFFE) | 304 |
| `sky130_fd_sc_hd__dfstp_2` (DFF w/ set) | 3 |
| **Total flip-flops** | **470** |
| Sequential area fraction | 64.1% |

### Combinational Highlights

| Cell type | Count |
|---|---|
| `nor2` | 403 |
| `a21oi` | 70 |
| `mux2` | 60 |
| `xor2` | 23 |
| `nand2` | 137 |
| `and3` | 26 |

---

## Timing

| Metric | Value |
|---|---|
| Target clock period | 20 ns (50 MHz) |
| Critical path delay | 1.89 ns |
| Theoretical max frequency | ~529 MHz |
| Setup WNS | 0.0 ns ✅ |
| Setup TNS | 0.0 ns ✅ |
| Hold WNS | 0.0 ns ✅ |
| Hold TNS | 0.0 ns ✅ |

---

## Routing

| Metric | Value |
|---|---|
| Total wire length | 75,695 µm |
| Total vias | 17,056 |
| DRC violations | 0 |
| Routing DRC shorts | 0 |
| XOR diff (Magic vs KLayout GDS) | 0 |

### Routing Layer Usage

| Layer | Usage |
|---|---|
| li1 (local interconnect) | 0.0% |
| met1 | 42.0% |
| met2 | 42.8% |
| met3 | 8.8% |
| met4 | 10.4% |
| met5 | 0.0% |

---

## Power (Typical Corner, tt 25°C 1.8V)

| Component | Power |
|---|---|
| Internal | 0.002 µW |
| Switching | 0.001 µW |
| Leakage | 13.8 pW |

---

## Configuration

| Parameter | Value |
|---|---|
| PDK | sky130A |
| Standard cell library | sky130_fd_sc_hd |
| Clock period | 20 ns |
| Synth strategy | AREA 0 |
| FP core utilization | 45% |
| FP aspect ratio | 1.0 |
| Placement target density | 0.5 |
| Max fanout constraint | 10 |
| PDN H-pitch | 153.18 µm |
| PDN V-pitch | 153.60 µm |

