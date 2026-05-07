class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    virtual uart_if vif;
    uart_driver    driver;
    uart_monitor   monitor;
    uvm_sequencer #(uart_tx_item) sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not found")
        end
        driver    = uart_driver::type_id::create("driver", this);
        monitor   = uart_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer#(uart_tx_item)::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.uart_vif  = vif;
        monitor.uart_vif = vif;
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass : uart_agent