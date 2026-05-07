package uart_verif_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_pkg::*;
    `uvm_analysis_imp_decl(_actual)
    `uvm_analysis_imp_decl(_expected)

    `include "verif/uart_seq_item.sv"
    `include "verif/uart_sequence.sv"
    `include "verif/uart_driver.sv"
    `include "verif/uart_monitor.sv"
    `include "verif/uart_scoreboard.sv"
    `include "verif/uart_agent.sv"
    `include "verif/uart_env.sv"
    `include "verif/uart_test.sv"

endpackage