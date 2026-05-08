class uart_monitor extends uvm_component;
    `uvm_component_utils(uart_monitor)

    virtual uart_if uart_vif;
    uvm_analysis_port #(uart_tx_item) uart_ap;
    uvm_analysis_port #(uart_status_item) status_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uart_ap = new("uart_ap", this);
        status_ap = new("status_ap", this);
    endfunction

    task automatic run_phase(uvm_phase phase);
        logic [15:0] locked_divisor;

        if (uart_vif == null)
            `uvm_fatal("NOVIF", "uart_vif not set before run_phase")

        wait(uart_vif.rst_n === 1'b1);
        wait(uart_vif.tx_out === 1'b1);
        repeat(2) @(posedge uart_vif.clk);

        fork
            begin : tx_watch
                forever begin
                    uart_tx_item item;
                    int unsigned  num_bits;

                    item = uart_tx_item::type_id::create("item");

                    wait(uart_vif.tx_busy === 1'b0);
                    @(posedge uart_vif.tx_busy);
                    if (uart_vif.rst_n  !== 1'b1) continue;
                    if (uart_vif.tx_out !== 1'b0) continue;

                    locked_divisor = uart_vif.divisor;
                    if (locked_divisor == 0) continue;

                    item.parity_en   = uart_vif.parity_en;
                    item.parity_type = uart_vif.parity_type;
                    item.data_bits   = uart_vif.data_bits;
                    item.stop_bits   = uart_vif.stop_bits;
                    num_bits         = item.data_bits + 5;

                    repeat (locked_divisor/2) @(posedge uart_vif.clk);
                    if (uart_vif.tx_out !== 1'b0) continue;

                    for (int i = 0; i < num_bits; i++) begin
                        repeat (locked_divisor) @(posedge uart_vif.clk);
                        item.data[i] = uart_vif.tx_out;
                    end

                    uart_ap.write(item);
                end
            end

            begin : bus_watch
                forever begin
                    @(posedge uart_vif.clk);
                    if (uart_vif.rst_n !== 1'b1) continue;
                    if (uart_vif.rd_en && (uart_vif.addr == 3'h2 || uart_vif.addr == 3'h6)) begin
                        uart_status_item status;
                        status = uart_status_item::type_id::create("status");
                        status.kind = (uart_vif.addr == 3'h2) ? "IIR_READ" : "MSR_READ";
                        status.addr = uart_vif.addr;
                        status.data = uart_vif.rdata;
                        status.irq  = uart_vif.irq;
                        status_ap.write(status);
                    end
                end
            end
        join_none
    endtask

endclass : uart_monitor