package uart_pkg;
typedef enum logic [2:0] {
    TX_IDLE = 3'b000,
    TX_START = 3'b001,
    TX_DATA = 3'b010,
    TX_PARITY = 3'b011,
    TX_STOP = 3'b100
} tx_state_t;

typedef enum logic [2:0] {
    RX_IDLE = 3'b000,
    RX_START = 3'b001,
    RX_DATA = 3'b010,
    RX_CENTER = 3'b011,
    RX_PARITY = 3'b100,
    RX_STOP = 3'b101
} rx_state_t;

endpackage : uart_pkg