`ifndef INTERFACE_PKG_SVH
`define INTERFACE_PKG_SVH

typedef enum logic [2:0] { 
    SINGLE = 3'b000,
    INCR = 3'b001,
    WRAP4 = 3'b010,
    INCR4 = 3'b011,
    WRAP8 = 3'b100,
    INCR8 = 3'b101,
    WRAP16 = 3'b110,
    INCR16 = 3'b111
} BURST_TYPES;

typedef enum logic [1:0] { 
    IDLE = 2'b00,
    BUSY = 2'b01,
    NONSEQ = 2'b10,
    SEQ = 2'b11
 } TRANS_TYPES;

 `endif