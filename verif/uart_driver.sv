class uart_driver extends uvm_driver #(uart_tx_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if uart_vif;
    uvm_analysis_port #(uart_tx_item) drv_ap;

    localparam [15:0] SIM_DIVISOR = 16;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_ap = new("drv_ap", this);
    endfunction

    task reg_write(input logic [2:0] addr, input logic [7:0] data);
        @(posedge uart_vif.clk);
        uart_vif.addr  <= addr;
        uart_vif.wdata <= data;
        uart_vif.wr_en <= 1;
        uart_vif.rd_en <= 0;
        @(posedge uart_vif.clk);
        uart_vif.wr_en <= 0;
    endtask

    task configure(uart_tx_item item);
        logic [7:0] lcr_val;
        lcr_val = {1'b1, 2'b00, item.parity_type, item.parity_en, item.stop_bits, item.data_bits};
        reg_write(3'h3, lcr_val);
        reg_write(3'h1, SIM_DIVISOR[15:8]);
        reg_write(3'h0, SIM_DIVISOR[7:0]);
        lcr_val = {1'b0, 2'b00, item.parity_type, item.parity_en, item.stop_bits, item.data_bits};
        reg_write(3'h3, lcr_val);
    endtask

    task run_phase(uvm_phase phase);
        uart_tx_item item;
        if (uart_vif == null)
            `uvm_fatal("NOVIF", "uart_vif not set before run_phase")

        uart_vif.wr_en <= 0;
        uart_vif.rd_en <= 0;
        uart_vif.addr  <= 0;
        uart_vif.wdata <= 0;

        wait(uart_vif.rst_n === 1'b1);
        repeat(5) @(posedge uart_vif.clk);
        reg_write(3'h3, 8'h8B); // DLAB=1, parity_en=1, odd, 8N1
        reg_write(3'h1, 8'h00); // DLH=0
        reg_write(3'h0, 8'd16); // DLL=16
        reg_write(3'h3, 8'h0B); // DLAB=0, parity_en=1, odd, 8N1
        wait(uart_vif.temt === 1'b1);

        forever begin
            seq_item_port.get_next_item(item);
            wait(uart_vif.temt === 1'b1);
            configure(item);
            repeat(2) @(posedge uart_vif.clk);
            drv_ap.write(item);
            reg_write(3'h0, item.data);
            @(posedge uart_vif.clk);
            wait(uart_vif.temt === 1'b1);
            seq_item_port.item_done();
        end
    endtask

endclass : uart_driver