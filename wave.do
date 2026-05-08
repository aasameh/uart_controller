onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock / Reset}
add wave -noupdate -radix binary /uart_tb_top/clk
add wave -noupdate -radix binary /uart_tb_top/rst_n
add wave -noupdate -divider {Config / Status}
add wave -noupdate -radix hexadecimal /uart_tb_top/uart_vif/divisor
add wave -noupdate -radix binary /uart_tb_top/uart_vif/parity_en
add wave -noupdate -radix binary /uart_tb_top/uart_vif/parity_type
add wave -noupdate -radix binary /uart_tb_top/uart_vif/data_bits
add wave -noupdate -radix binary /uart_tb_top/uart_vif/stop_bits
add wave -noupdate -radix binary /uart_tb_top/uart_vif/dr
add wave -noupdate -radix binary /uart_tb_top/uart_vif/thre
add wave -noupdate -radix binary /uart_tb_top/uart_vif/temt
add wave -noupdate -divider {Test 3 (Framing Error)}
add wave -noupdate -radix binary /uart_tb_top/dut/rx_in
add wave -noupdate -radix binary /uart_tb_top/dut/loopback_en
add wave -noupdate -radix binary /uart_tb_top/dut/rx_raw_dr
add wave -noupdate -radix hexadecimal /uart_tb_top/dut/rx_raw_data
add wave -noupdate -radix binary /uart_tb_top/dut/rx_raw_framing_err
add wave -noupdate -radix binary /uart_tb_top/dut/rx_fifo_push
add wave -noupdate -radix binary /uart_tb_top/dut/rx_fifo_pop
add wave -noupdate -radix decimal /uart_tb_top/dut/rx_fifo_count
add wave -noupdate -radix hexadecimal /uart_tb_top/dut/rx_fifo_dout
add wave -noupdate -radix binary /uart_tb_top/dut/regs/lsr
add wave -noupdate -radix binary /uart_tb_top/dut/regs/oe
add wave -noupdate -radix binary /uart_tb_top/uart_vif/dr
add wave -noupdate -radix hexadecimal /uart_tb_top/uart_vif/rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{framing err} {1915 ps} 0} {start {215 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 280
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2409 ps}
