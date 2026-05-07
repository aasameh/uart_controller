class uart_test extends uvm_test;
    `uvm_component_utils(uart_test)

    uart_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        uart_sequence seq; // declaration FIRST before any statements
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = uart_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #1000ns;
        phase.drop_objection(this);
    endtask

endclass : uart_test