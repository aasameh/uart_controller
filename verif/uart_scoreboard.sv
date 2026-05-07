class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    // Actual items from monitor
    uvm_analysis_imp_actual   #(uart_tx_item, uart_scoreboard) actual_aie;
    // Expected items from driver
    uvm_analysis_imp_expected #(uart_tx_item, uart_scoreboard) expected_aie;

    uart_tx_item expected_q[$];

    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        actual_aie   = new("actual_aie",   this);
        expected_aie = new("expected_aie", this);
    endfunction

    // Called by driver — push expected item
    function void write_expected(uart_tx_item item);
        expected_q.push_back(item);
    endfunction

    // Called by monitor — compare against expected
    function void write_actual(uart_tx_item item);
        uart_tx_item exp;
        if (expected_q.size() == 0) begin
            `uvm_error("MISMATCH", "Received item with no expected items in queue")
            fail_count++;
            return;
        end
        exp = expected_q.pop_front();
        if (item.data      !== exp.data      ||
            item.parity_en !== exp.parity_en ||
            item.data_bits !== exp.data_bits ||
            item.stop_bits !== exp.stop_bits) begin
            `uvm_error("MISMATCH", $sformatf(
                "FAIL — got data=0x%0h parity_en=%0b data_bits=%0b stop_bits=%0b | expected data=0x%0h parity_en=%0b data_bits=%0b stop_bits=%0b",
                item.data, item.parity_en, item.data_bits, item.stop_bits,
                exp.data,  exp.parity_en,  exp.data_bits,  exp.stop_bits))
            fail_count++;
        end else begin
            `uvm_info("MATCH", $sformatf(
                "PASS — data=0x%0h parity_en=%0b data_bits=%0b stop_bits=%0b",
                item.data, item.parity_en, item.data_bits, item.stop_bits), UVM_LOW)
            pass_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "=== FINAL SCORE: %0d PASS / %0d FAIL ===",
            pass_count, fail_count), UVM_NONE)
    endfunction

endclass : uart_scoreboard