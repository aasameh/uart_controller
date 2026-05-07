onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock / Reset}
add wave -noupdate -radix binary /uart_tb_top/clk
add wave -noupdate -radix binary /uart_tb_top/rst_n
add wave -noupdate -divider {TX Interface}
add wave -noupdate -radix binary /uart_tb_top/uart_vif/tx_start
add wave -noupdate -radix hexadecimal /uart_tb_top/uart_vif/tx_data
add wave -noupdate -radix binary /uart_tb_top/uart_vif/tx_out
add wave -noupdate -radix binary /uart_tb_top/uart_vif/tx_busy
add wave -noupdate -radix binary /uart_tb_top/uart_vif/thre
add wave -noupdate -radix binary /uart_tb_top/uart_vif/temt
add wave -noupdate -divider Config
add wave -noupdate -radix hexadecimal /uart_tb_top/uart_vif/divisor
add wave -noupdate -radix binary /uart_tb_top/uart_vif/parity_en
add wave -noupdate -radix binary /uart_tb_top/uart_vif/parity_type
add wave -noupdate -radix binary /uart_tb_top/uart_vif/data_bits
add wave -noupdate -radix binary /uart_tb_top/uart_vif/stop_bits
add wave -noupdate -divider {TX Internals}
add wave -noupdate -radix binary /uart_tb_top/dut/tx/state
add wave -noupdate -radix binary /uart_tb_top/dut/tx/shift_reg
add wave -noupdate -radix unsigned /uart_tb_top/dut/tx/bit_cnt
add wave -noupdate -radix decimal /uart_tb_top/dut/tx/baud_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {start {305 ps} 1} {D0 {465 ps} 1} {D1 {625 ps} 1} {D2 {785 ps} 1} {D3 {945 ps} 1} {D4 {1105 ps} 1} {D5 {1265 ps} 1} {D6 {1425 ps} 1} {D7 {1585 ps} 1} {parity {1745 ps} 1} {stop {1905 ps} 1}
quietly wave cursor active 11
configure wave -namecolwidth 209
configure wave -valuecolwidth 53
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
WaveRestoreZoom {0 ps} {2441 ps}
