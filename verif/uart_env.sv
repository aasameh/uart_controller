class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agent      agent;
    uart_scoreboard scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = uart_agent::type_id::create("agent", this);
        scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Monitor -> scoreboard actual port
        agent.monitor.uart_ap.connect(scoreboard.actual_aie);
        // Driver -> scoreboard expected port
        agent.driver.drv_ap.connect(scoreboard.expected_aie);
    endfunction

endclass : uart_env