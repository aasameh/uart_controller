# ============================================================
# UART UVM Simulation — ModelSim
# run from project root: vsim -do run_uart.do
# ============================================================

# Create and map work library
vlib work
vmap work work

# ============================================================
# Compile RTL
# ============================================================
vlog -sv -work work \
    rtl/uart_pkg.sv \
    rtl/uart_if.sv \
    rtl/uart_regs.sv \
    rtl/uart_fifo.sv \
    rtl/uart_tx.sv \
    rtl/uart_rx.sv \
    rtl/uart_top.sv

# ============================================================
# Compile Assertions
# ============================================================
#vlog -sv -work work \
#    tb/uart_assertions.sv \
#    tb/uart_rx_assertions.sv \
#    tb/uart_tx_assertions.sv

# ============================================================
# Compile UVM Testbench
# ============================================================
vlog -sv -work work \
    +incdir+C:/uvm-1.1d/src \
    +define+UVM_CMDLINE_NO_DPI \
    +define+UVM_NO_DPI \
    +define+UVM_NO_RELNOTES \
    C:/uvm-1.1d/src/uvm_pkg.sv \
    verif/uart_verif_pkg.sv \
    tb/uart_tb_top.sv
    

# ============================================================
# Simulate
# ============================================================
vsim -sv_seed random \
     -L work \
     +UVM_TESTNAME=uart_test \
     +UVM_VERBOSITY=UVM_LOW \
     work.uart_tb_top

# ============================================================
# Waveform setup — choose one preset to avoid clutter
# ============================================================
proc add_common_waves {} {
    add wave -divider "Clock / Reset"
    add wave -radix bin /uart_tb_top/clk
    add wave -radix bin /uart_tb_top/rst_n

    add wave -divider "Config / Status"
    add wave -radix hex /uart_tb_top/uart_vif/divisor
    add wave -radix bin /uart_tb_top/uart_vif/parity_en
    add wave -radix bin /uart_tb_top/uart_vif/parity_type
    add wave -radix bin /uart_tb_top/uart_vif/data_bits
    add wave -radix bin /uart_tb_top/uart_vif/stop_bits
    add wave -radix bin /uart_tb_top/uart_vif/dr
    add wave -radix bin /uart_tb_top/uart_vif/thre
    add wave -radix bin /uart_tb_top/uart_vif/temt
}

proc add_tx_waves {} {
    add wave -divider "TX"
    add wave -radix bin /uart_tb_top/uart_vif/tx_start
    add wave -radix hex /uart_tb_top/uart_vif/tx_data
    add wave -radix bin /uart_tb_top/uart_vif/tx_busy
    add wave -radix bin /uart_tb_top/uart_vif/tx_out
    add wave -radix bin /uart_tb_top/dut/tx/state
    add wave -radix hex /uart_tb_top/dut/tx/shift_reg
    add wave -radix dec /uart_tb_top/dut/tx/bit_cnt
    add wave -radix dec /uart_tb_top/dut/tx/baud_cnt
    add wave -radix bin /uart_tb_top/dut/tx_fifo_push
    add wave -radix bin /uart_tb_top/dut/tx_fifo_pop
    add wave -radix dec /uart_tb_top/dut/tx_fifo_count
    add wave -radix hex /uart_tb_top/dut/tx_fifo_dout
}

proc add_rx_waves {} {
    add wave -divider "RX"
    add wave -radix bin /uart_tb_top/dut/rx_raw_dr
    add wave -radix hex /uart_tb_top/dut/rx_raw_data
    add wave -radix bin /uart_tb_top/dut/rx_raw_parity_err
    add wave -radix bin /uart_tb_top/dut/rx_raw_framing_err
    add wave -radix bin /uart_tb_top/dut/rx_raw_break_int
    add wave -radix bin /uart_tb_top/dut/rx_fifo_push
    add wave -radix bin /uart_tb_top/dut/rx_fifo_pop
    add wave -radix dec /uart_tb_top/dut/rx_fifo_count
    add wave -radix hex /uart_tb_top/dut/rx_fifo_dout
    add wave -radix bin /uart_tb_top/dut/oe_set
    add wave -radix bin /uart_tb_top/dut/err_set

    add wave -divider "RX Status Latches"
    add wave -radix bin /uart_tb_top/dut/regs/oe
    add wave -radix bin /uart_tb_top/dut/regs/err_pending
    add wave -radix bin /uart_tb_top/dut/regs/lsr
    add wave -radix hex /uart_tb_top/dut/rdata
}

proc add_fifo_waves {} {
    add wave -divider "FIFO Internal"
    add wave -radix hex /uart_tb_top/dut/tx_fifo/data_in
    add wave -radix bin /uart_tb_top/dut/tx_fifo/push
    add wave -radix bin /uart_tb_top/dut/tx_fifo/pop
    add wave -radix bin /uart_tb_top/dut/tx_fifo/clear
    add wave -radix hex /uart_tb_top/dut/tx_fifo/data_out
    add wave -radix bin /uart_tb_top/dut/tx_fifo/empty
    add wave -radix bin /uart_tb_top/dut/tx_fifo/full
    add wave -radix dec /uart_tb_top/dut/tx_fifo/count

    add wave -radix hex /uart_tb_top/dut/rx_fifo/data_in
    add wave -radix bin /uart_tb_top/dut/rx_fifo/push
    add wave -radix bin /uart_tb_top/dut/rx_fifo/pop
    add wave -radix bin /uart_tb_top/dut/rx_fifo/clear
    add wave -radix hex /uart_tb_top/dut/rx_fifo/data_out
    add wave -radix bin /uart_tb_top/dut/rx_fifo/empty
    add wave -radix bin /uart_tb_top/dut/rx_fifo/full
    add wave -radix dec /uart_tb_top/dut/rx_fifo/count
}

proc add_loopback_waves {} {
    add wave -divider "Loopback / Regs"
    add wave -radix bin /uart_tb_top/dut/loopback_en
    add wave -radix bin /uart_tb_top/dut/tx_out
    add wave -radix bin /uart_tb_top/dut/dr
    add wave -radix hex /uart_tb_top/dut/rdata
}

proc add_modem_waves {} {
    add wave -divider "Modem"
    add wave -radix bin /uart_tb_top/uart_vif/dtr
    add wave -radix bin /uart_tb_top/uart_vif/rts
    add wave -radix bin /uart_tb_top/uart_vif/out1
    add wave -radix bin /uart_tb_top/uart_vif/out2
    add wave -radix bin /uart_tb_top/uart_vif/cts_in
    add wave -radix bin /uart_tb_top/uart_vif/dsr_in
    add wave -radix bin /uart_tb_top/uart_vif/ri_in
    add wave -radix bin /uart_tb_top/uart_vif/dcd_in
    add wave -radix bin /uart_tb_top/uart_vif/irq
    add wave -radix bin /uart_tb_top/dut/irq
    add wave -radix hex /uart_tb_top/dut/regs/ier
    add wave -radix hex /uart_tb_top/dut/regs/int_id
    add wave -radix bin /uart_tb_top/dut/regs/int_pending
    add wave -radix bin /uart_tb_top/dut/regs/mcr_reg
    add wave -radix bin /uart_tb_top/dut/regs/msr_inputs
    add wave -radix bin /uart_tb_top/dut/regs/msr_prev
    add wave -radix bin /uart_tb_top/dut/regs/msr_delta
    add wave -radix hex /uart_tb_top/dut/rdata
}

proc add_test1_waves {} {
    add wave -divider "Test 1"
    add wave -radix bin /uart_tb_top/uart_vif/tx_start
    add wave -radix hex /uart_tb_top/uart_vif/tx_data
    add wave -radix bin /uart_tb_top/uart_vif/tx_busy
    add wave -radix bin /uart_tb_top/uart_vif/tx_out
    add wave -radix bin /uart_tb_top/dut/loopback_en
    add wave -radix bin /uart_tb_top/dut/rx_raw_dr
    add wave -radix bin /uart_tb_top/dut/rx_fifo_push
    add wave -radix bin /uart_tb_top/dut/rx_fifo_pop
    add wave -radix hex /uart_tb_top/dut/rx_fifo_dout
    add wave -radix bin /uart_tb_top/uart_vif/dr
    add wave -radix hex /uart_tb_top/uart_vif/rdata
}

proc add_test2_waves {} {
    add wave -divider "Test 2 (Overrun)"
    add wave -radix bin /uart_tb_top/uart_vif/tx_start
    add wave -radix hex /uart_tb_top/uart_vif/tx_data
    add wave -radix bin /uart_tb_top/uart_vif/tx_busy
    add wave -radix bin /uart_tb_top/uart_vif/tx_out
    add wave -radix bin /uart_tb_top/dut/loopback_en

    add wave -radix bin /uart_tb_top/dut/rx_fifo_push
    add wave -radix bin /uart_tb_top/dut/rx_fifo_pop
    add wave -radix dec /uart_tb_top/dut/rx_fifo_count
    add wave -radix bin /uart_tb_top/dut/rx_fifo_full
    add wave -radix hex /uart_tb_top/dut/rx_fifo_dout

    add wave -radix bin /uart_tb_top/dut/oe_set
    add wave -radix bin /uart_tb_top/dut/regs/oe
    add wave -radix bin /uart_tb_top/dut/regs/lsr
    add wave -radix bin /uart_tb_top/uart_vif/dr
    add wave -radix hex /uart_tb_top/uart_vif/rdata
}

proc add_test3_waves {} {
    add wave -divider "Test 3 (Framing Error)"
    add wave -radix bin /uart_tb_top/dut/rx_in
    add wave -radix bin /uart_tb_top/dut/loopback_en
    add wave -radix bin /uart_tb_top/dut/rx_raw_dr
    add wave -radix hex /uart_tb_top/dut/rx_raw_data
    add wave -radix bin /uart_tb_top/dut/rx_raw_framing_err
    add wave -radix bin /uart_tb_top/dut/rx_fifo_push
    add wave -radix bin /uart_tb_top/dut/rx_fifo_pop
    add wave -radix dec /uart_tb_top/dut/rx_fifo_count
    add wave -radix hex /uart_tb_top/dut/rx_fifo_dout
    add wave -radix bin /uart_tb_top/dut/regs/lsr
    add wave -radix bin /uart_tb_top/dut/regs/oe
    add wave -radix bin /uart_tb_top/uart_vif/dr
    add wave -radix hex /uart_tb_top/uart_vif/rdata
}

# Pick one: test1, test2, test3, tx, rx, fifo, loopback, modem, all
set WAVE_PRESET "modem"

add_common_waves

switch -- $WAVE_PRESET {
    test1    { add_test1_waves }
    test2    { add_test2_waves }
    test3    { add_test3_waves }
    tx       { add_tx_waves }
    rx       { add_rx_waves }
    fifo     { add_fifo_waves }
    modem    {
        add_modem_waves
        add_loopback_waves
    }
    loopback {
        add_tx_waves
        add_rx_waves
        add_loopback_waves
    }
    all {
        add_tx_waves
        add_rx_waves
        add_fifo_waves
        add_loopback_waves
    }
    default {
        add_tx_waves
        add_rx_waves
    }
}

# ============================================================
# Run
# ============================================================
run -all

# ============================================================
# Coverage report
# ============================================================
# coverage report -detail -file coverage_report.txt

echo "=== DONE === check transcript for UVM_ERROR / MATCH messages"