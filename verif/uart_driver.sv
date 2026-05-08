class uart_driver extends uvm_driver #(uart_tx_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if uart_vif;
    uvm_analysis_port #(uart_tx_item) drv_ap;
    uvm_analysis_port #(uart_status_item) status_ap;

    localparam [15:0] SIM_DIVISOR = 16;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_ap = new("drv_ap", this);
        status_ap = new("status_ap", this);
    endfunction

    function void publish_status_expected(string kind, logic [2:0] addr, logic [7:0] data, logic irq);
        uart_status_item item;
        item = uart_status_item::type_id::create($sformatf("exp_%s", kind));
        item.kind = kind;
        item.addr = addr;
        item.data = data;
        item.irq  = irq;
        status_ap.write(item);
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

    task reg_read(input logic [2:0] addr, output logic [7:0] data);
        @(posedge uart_vif.clk);
        uart_vif.addr  <= addr;
        uart_vif.rd_en <= 1;
        uart_vif.wr_en <= 0;
        @(posedge uart_vif.clk);
        data = uart_vif.rdata;
        uart_vif.rd_en <= 0;
    endtask

    task rbr_read(output logic [7:0] byte_data);
        logic [7:0] rdata;
        reg_read(3'h0, rdata);
        byte_data = rdata;
        `uvm_info("RBR_READ", $sformatf("Read RBR = 0x%02X", rdata), UVM_LOW)
    endtask

    task lsr_read(output logic [7:0] lsr_data);
        logic [7:0] rdata;
        reg_read(3'h5, rdata);
        lsr_data = rdata;
        `uvm_info("LSR_READ", $sformatf("Read LSR = 0x%02X [DR=%b OE=%b PE=%b FE=%b BI=%b ERR=%b]",
            rdata, rdata[0], rdata[1], rdata[2], rdata[3], rdata[4], rdata[7]), UVM_LOW)
    endtask

    task msr_read(input logic [7:0] expected_msr, output logic [7:0] msr_data);
        logic [7:0] rdata;
        // Publish the expected bus read before performing it so the monitor can compare.
        publish_status_expected("MSR_READ", 3'h6, expected_msr, uart_vif.irq);
        reg_read(3'h6, rdata);
        msr_data = rdata;
        `uvm_info("MSR_READ", $sformatf("Read MSR = 0x%02X [DCTS=%b DDSR=%b TERI=%b DDCD=%b CTS=%b DSR=%b RI=%b DCD=%b]",
            rdata, rdata[0], rdata[1], rdata[2], rdata[3], rdata[4], rdata[5], rdata[6], rdata[7]), UVM_LOW)
    endtask

    task iir_read(input logic [7:0] expected_iir, output logic [7:0] iir_data);
        logic [7:0] rdata;
        publish_status_expected("IIR_READ", 3'h2, expected_iir, uart_vif.irq);
        reg_read(3'h2, rdata);
        iir_data = rdata;
        `uvm_info("IIR_READ", $sformatf("Read IIR = 0x%02X [pending=%b, id=%b]",
            rdata, ~rdata[0], rdata[3:1]), UVM_LOW)
    endtask

    task drive_rx_bad_stop_frame(input logic [7:0] data_byte);
        int unsigned bit_ticks;

        bit_ticks = (uart_vif.divisor == 0) ? 16 : uart_vif.divisor;

        // Idle line
        uart_vif.rx_in <= 1'b1;
        repeat (bit_ticks) @(posedge uart_vif.clk);

        // Start bit
        uart_vif.rx_in <= 1'b0;
        repeat (bit_ticks) @(posedge uart_vif.clk);

        // 8 data bits, LSB first
        for (int b = 0; b < 8; b++) begin
            uart_vif.rx_in <= data_byte[b];
            repeat (bit_ticks) @(posedge uart_vif.clk);
        end

        // Bad stop bit (force low) to trigger framing error
        uart_vif.rx_in <= 1'b0;
        repeat (bit_ticks) @(posedge uart_vif.clk);

        // Return to idle
        uart_vif.rx_in <= 1'b1;
        repeat (bit_ticks) @(posedge uart_vif.clk);
    endtask

    task run_phase(uvm_phase phase);
        logic [7:0] rbr_data, lsr_data, msr_data, iir_data;

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

        // Test 1: Single byte TX→RX→read
        // `uvm_info("TEST_1", "Single byte TX with RBR read", UVM_LOW)
        // repeat(5) begin
        //     uart_tx_item item;
        //     seq_item_port.get_next_item(item);
        //     wait(uart_vif.temt === 1'b1);
        //     configure(item);
        //     repeat(2) @(posedge uart_vif.clk);
        //     drv_ap.write(item);
        //     reg_write(3'h0, item.data);
        //     @(posedge uart_vif.clk);
        //     wait(uart_vif.temt === 1'b1);
        //     // Wait for RX to complete (dr should be high after loopback)
        //     repeat(100) @(posedge uart_vif.clk);
        //     if (uart_vif.dr) begin
        //         rbr_read(rbr_data);
        //         lsr_read(lsr_data);
        //         if (rbr_data === item.data)
        //             `uvm_info("PASS", $sformatf("RBR read OK: sent 0x%02X, got 0x%02X", item.data, rbr_data), UVM_LOW)
        //         else
        //             `uvm_error("FAIL", $sformatf("RBR mismatch: sent 0x%02X, got 0x%02X", item.data, rbr_data))
        //     end
        //     seq_item_port.item_done();
        // end

        // Test 2: Burst 17 bytes to trigger OE
        // `uvm_info("TEST_2", "Burst 17 bytes to trigger OE", UVM_LOW)
        // for (int i = 0; i < 17; i++) begin
        //     uart_tx_item exp_item;
        //     exp_item = uart_tx_item::type_id::create($sformatf("exp_burst_%0d", i));
        //     exp_item.data        = 8'hCC + i;
        //     exp_item.parity_en   = 1'b1;
        //     exp_item.parity_type = 1'b0;
        //     exp_item.data_bits   = 2'b11;
        //     exp_item.stop_bits   = 1'b0;
        //     drv_ap.write(exp_item);
        //     wait(uart_vif.temt === 1'b1);
        //     reg_write(3'h0, 8'hCC + i);
        //     repeat(10) @(posedge uart_vif.clk);
        // end

        // // Test 3: Isolated framing-error case (bad stop bit)
        // `uvm_info("TEST_3", "Inject bad-stop RX frame to trigger FE", UVM_LOW)

        // // Make sure loopback is off so this test is isolated to rx_in.
        // reg_write(3'h4, 8'h00); // MCR: loopback off
        // reg_write(3'h3, 8'h03); // LCR: 8N1, parity off, DLAB=0

        // drive_rx_bad_stop_frame(8'h55);

        // // Allow RX pipeline/FIFO push to settle
        // repeat(40) @(posedge uart_vif.clk);

        // lsr_read(lsr_data);
        // if (lsr_data[3])
        //     `uvm_info("PASS", "Framing error bit set after bad-stop frame", UVM_LOW)
        // else
        //     `uvm_error("FAIL", "Framing error bit not set in LSR")

        // if (uart_vif.dr) begin
        //     rbr_read(rbr_data);
        //     `uvm_info("TEST_3", $sformatf("RBR after FE frame = 0x%02X", rbr_data), UVM_LOW)
        // end

        // Test 4: Modem loopback + external status sampling
        `uvm_info("TEST_4", "Exercise modem loopback and external modem inputs", UVM_LOW)

        // External inputs low before loopback test
        uart_vif.cts_in = 1'b0;
        uart_vif.dsr_in = 1'b0;
        uart_vif.ri_in  = 1'b0;
        uart_vif.dcd_in = 1'b0;

        // Enable modem loopback with all outputs asserted.
        reg_write(3'h4, 8'h1F);
        repeat (6) @(posedge uart_vif.clk);
        msr_read(8'hFF, msr_data);
        if (msr_data === 8'hFF)
            `uvm_info("PASS", "Modem loopback MSR = 0xFF", UVM_LOW)
        else
            `uvm_error("FAIL", $sformatf("Modem loopback MSR expected 0xFF, got 0x%02X", msr_data))

        msr_read(8'hF0, msr_data);
        if (msr_data[7:4] === 4'hF && msr_data[3:0] == 4'h0)
            `uvm_info("PASS", "Modem loopback delta bits cleared after MSR read", UVM_LOW)
        else
            `uvm_error("FAIL", $sformatf("MSR delta bits not cleared: 0x%02X", msr_data))

        // Set external modem inputs while loopback is still on, so synchronizers settle first.
        uart_vif.cts_in = 1'b1;
        uart_vif.dsr_in = 1'b0;
        uart_vif.ri_in  = 1'b1;
        uart_vif.dcd_in = 1'b0;
        repeat (6) @(posedge uart_vif.clk);
        // Turn loopback off and sample external modem inputs from synchronized inputs.
        reg_write(3'h4, 8'h00);
        repeat (2) @(posedge uart_vif.clk); // Give synchronizers one more cycle to settle
        msr_read(8'h5A, msr_data);
        if (msr_data[7:4] === 4'b0101)
            `uvm_info("PASS", "External modem inputs sampled into MSR", UVM_LOW)
        else
            `uvm_error("FAIL", $sformatf("External modem MSR upper nibble expected 0b0101, got 0x%02X", msr_data))

        // Enable modem interrupt and prove the delta edge raises irq / clears on MSR read only.
        reg_write(3'h1, 8'h08); // IER[3] = modem status interrupt enable
        uart_vif.cts_in = 1'b0;
        repeat (4) @(posedge uart_vif.clk);
        uart_vif.cts_in = 1'b1;
        repeat (6) @(posedge uart_vif.clk);

        iir_read(8'hC0, iir_data);
        if (uart_vif.irq && (iir_data[0] == 1'b0) && (iir_data[3:1] == 3'b000))
            `uvm_info("PASS", "Modem interrupt asserted and IIR reports modem source", UVM_LOW)
        else
            `uvm_error("FAIL", $sformatf("Modem IRQ/IIR mismatch: irq=%b iir=0x%02X", uart_vif.irq, iir_data))

        msr_read(8'h51, msr_data);
        if (msr_data[0] == 1'b1)
            `uvm_info("PASS", "MSR delta bit captured for CTS edge", UVM_LOW)
        else
            `uvm_error("FAIL", $sformatf("Expected MSR delta on CTS edge, got 0x%02X", msr_data))

    endtask

endclass : uart_driver