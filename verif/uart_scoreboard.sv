`uvm_analysis_imp_decl(_actual_status)
`uvm_analysis_imp_decl(_expected_status)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    // Actual items from monitor
    uvm_analysis_imp_actual   #(uart_tx_item, uart_scoreboard) actual_aie;
    // Expected items from driver
    uvm_analysis_imp_expected #(uart_tx_item, uart_scoreboard) expected_aie;

    uvm_analysis_imp_actual_status   #(uart_status_item, uart_scoreboard) actual_status_aie;
    uvm_analysis_imp_expected_status #(uart_status_item, uart_scoreboard) expected_status_aie;

    uart_tx_item expected_q[$];
    uart_status_item expected_status_q[$];

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
        actual_status_aie = new("actual_status_aie", this);
        expected_status_aie = new("expected_status_aie", this);
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

    function void write_expected_status(uart_status_item item);
        expected_status_q.push_back(item);
    endfunction

    function void write_actual_status(uart_status_item item);
        uart_status_item exp;
        if (expected_status_q.size() == 0) begin
            `uvm_error("STATUS_MISMATCH", $sformatf("Unexpected status item kind=%s addr=%0h data=0x%02h irq=%0b",
                item.kind, item.addr, item.data, item.irq))
            fail_count++;
            return;
        end
        exp = expected_status_q.pop_front();
        if (item.kind != exp.kind ||
            item.addr !== exp.addr ||
            item.data !== exp.data ||
            item.irq  !== exp.irq) begin
            `uvm_error("STATUS_MISMATCH", $sformatf(
                "FAIL — got kind=%s addr=%0h data=0x%02h irq=%0b | expected kind=%s addr=%0h data=0x%02h irq=%0b",
                item.kind, item.addr, item.data, item.irq,
                exp.kind,  exp.addr,  exp.data,  exp.irq))
            fail_count++;
        end else begin
            `uvm_info("STATUS_MATCH", $sformatf(
                "PASS — kind=%s addr=%0h data=0x%02h irq=%0b",
                item.kind, item.addr, item.data, item.irq), UVM_LOW)
            pass_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "=== FINAL SCORE: %0d PASS / %0d FAIL ===",
            pass_count, fail_count), UVM_NONE)
    endfunction

endclass : uart_scoreboard