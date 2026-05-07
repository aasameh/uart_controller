class uart_bus_item extends uvm_sequence_item;
  rand logic [2:0] addr;
  rand logic [7:0] wdata;
  rand logic wr_en;
  rand logic rd_en;
  rand logic [1:0] parity_type;

  constraint addr_c { addr < 3'h6; } // Only valid addresses
  constraint rw_c { wr_en + rd_en <= 1; }
  constraint parity_type_c { parity_type inside {0, 1}; }

  `uvm_object_utils(uart_bus_item)

  function new(string name = "uart_bus_item");
    super.new(name);
  endfunction
endclass : uart_bus_item

class uart_tx_item extends uvm_sequence_item;
  rand logic [7:0] data;
  rand logic parity_en;
  rand logic parity_type; // 0=odd, 1=even
  rand logic [1:0] data_bits; // 0=5 bits, 1=6 bits, 2=7 bits, 3=8 bits
  rand logic stop_bits; // 0=1 stop bit, 1=2 stop bits

  `uvm_object_utils(uart_tx_item)

  function new(string name = "uart_tx_item");
    super.new(name);
  endfunction
endclass : uart_tx_item