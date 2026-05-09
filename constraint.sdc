# UART Controller Timing Constraints

# Clock constraint: 50 MHz (20 ns period)
create_clock -name clk -period 20.0 [get_ports clk]

# I/O delays (reasonable defaults for UART)
set_input_delay -clock clk -min 2.0 [get_ports {rst_n we re addr[*] wdata[*] cts_in dsr_in ri_in dcd_in}]
set_input_delay -clock clk -max 8.0 [get_ports {rst_n we re addr[*] wdata[*] cts_in dsr_in ri_in dcd_in}]

set_output_delay -clock clk -min 1.0 [get_ports {rdata[*] dtr rts out1 out2 irq}]
set_output_delay -clock clk -max 8.0 [get_ports {rdata[*] dtr rts out1 out2 irq}]

# Drive/load on I/O
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [get_ports {rst_n we re addr[*] wdata[*] cts_in dsr_in ri_in dcd_in}]
set_load 0.1 [get_ports {rdata[*] dtr rts out1 out2 irq}]
