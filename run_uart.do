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
# Waveform setup — full TX transaction visible
# ============================================================
add wave -divider "Clock / Reset"
add wave -radix bin  /uart_tb_top/clk
add wave -radix bin  /uart_tb_top/rst_n

add wave -divider "TX Interface"
add wave -radix bin  /uart_tb_top/uart_vif/tx_start
add wave -radix hex  /uart_tb_top/uart_vif/tx_data
add wave -radix bin  /uart_tb_top/uart_vif/tx_out
add wave -radix bin  /uart_tb_top/uart_vif/tx_busy
add wave -radix bin  /uart_tb_top/uart_vif/thre
add wave -radix bin  /uart_tb_top/uart_vif/temt

add wave -divider "Config"
add wave -radix hex  /uart_tb_top/uart_vif/divisor
add wave -radix bin  /uart_tb_top/uart_vif/parity_en
add wave -radix bin  /uart_tb_top/uart_vif/parity_type
add wave -radix bin  /uart_tb_top/uart_vif/data_bits
add wave -radix bin  /uart_tb_top/uart_vif/stop_bits

add wave -divider "TX Internals"
add wave -radix bin  /uart_tb_top/dut/tx/state
add wave -radix hex  /uart_tb_top/dut/tx/shift_reg
add wave -radix dec  /uart_tb_top/dut/tx/bit_cnt
add wave -radix dec  /uart_tb_top/dut/tx/baud_cnt

add wave -divider "FIFO"
add wave -radix hex /uart_tb_top/dut/tx_fifo/data_in
add wave -radix bin /uart_tb_top/dut/tx_fifo/push
add wave -radix bin /uart_tb_top/dut/tx_fifo/pop
add wave -radix bin  /uart_tb_top/dut/tx_fifo/clear
add wave -radix hex  /uart_tb_top/dut/tx_fifo/data_out
add wave -radix bin  /uart_tb_top/dut/tx_fifo/empty
add wave -radix bin  /uart_tb_top/dut/tx_fifo/full
add wave -radix dec  /uart_tb_top/dut/tx_fifo/count

# ============================================================
# Run
# ============================================================
run -all

# ============================================================
# Coverage report
# ============================================================
# coverage report -detail -file coverage_report.txt

echo "=== DONE === check transcript for UVM_ERROR / MATCH messages"