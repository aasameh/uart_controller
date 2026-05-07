class uart_sequence extends uvm_sequence #(uart_tx_item);
  `uvm_object_utils(uart_sequence)

  function new(string name = "uart_sequence");
    super.new(name);
  endfunction

  task body();

  repeat (5) begin
    uart_tx_item item;
    item = uart_tx_item::type_id::create("item");
    item.data       = 8'hA5;
    item.parity_en  = 1;
    item.parity_type = 0;
    item.data_bits  = 2'b11;
    item.stop_bits  = 0;
    start_item(item);
    finish_item(item);
  end
  endtask
endclass : uart_sequence